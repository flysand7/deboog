
package gui

import "pesticider:prof"

Element_Flags :: bit_set[Element_Flags_Bits]
Element_Flags_Bits :: enum {
    // Destruction
    Element_Destroy,
    Element_Destroy_Descendent,
    // Element layout flags
    Element_HFill,
    Element_VFill,
    // Panel flags
    Panel_HLayout,
    Panel_VLayout,
    // Scrollable
    Scrollable,
}

Msg_Destroy :: struct {}
Msg_Paint   :: ^Painter
Msg_Layout  :: struct {}

Msg_Preferred_Width :: struct {
    height: Maybe(int),
}

Msg_Preferred_Height :: struct {
    width: Maybe(int),
}

Mouse_Button :: enum {
    Left,
    Middle,
    Right,
}

Mouse_Action :: enum {
    Press,
    Release,
}

Msg_Input_Clicked :: struct{
    pos: Vec,
}

Msg_Input_Drag :: struct{
    pos: Vec,
}

Msg_Input_Move :: struct{
    pos: Vec,
}

Msg_Input_Pressed :: struct{
    // TODO: The location of the mouse press?
}

Msg_Input_Hovered :: struct {
    // TODO: Element-relative coordinates of the mouse
}

Msg_Input_Click :: struct {
    button: Mouse_Button,
    action: Mouse_Action,
}

Msg_Input_Scroll :: struct {
    d: int,
}

Msg :: union {
    // Element is expected to free all if its associated data.
    Msg_Destroy,
    // Element uses these to react to it's state changes and update state
    // in accordance to that. For example button can react to the hover event,
    // change it's background color and redraw itself.
    Msg_Input_Move,
    Msg_Input_Drag,
    Msg_Input_Clicked,
    Msg_Input_Pressed,
    Msg_Input_Hovered,
    Msg_Input_Click,
    Msg_Input_Scroll,
    // In response to this event the element must issue draw commands to draw
    // itself.
    Msg_Paint,
    // This is handled by layout managers only -- it specifies when layout of
    // children elements needs to be re-calculated.
    Msg_Layout,
    // In response to this message element returns its preferred width.
    Msg_Preferred_Width,
    // In response to this message element returns its preferred width.
    Msg_Preferred_Height,
}

Message_Proc :: #type proc (element: ^Element, message: Msg) -> int

Element :: struct {
    parent:    ^Element,
    children:  [dynamic]^Element,
    flags:     Element_Flags,
    window:    ^Window,
    data:      rawptr,
    bounds:    Rect,
    clip:      Rect,
    msg_user:  Message_Proc,
    msg_class: Message_Proc,
}

element_create :: proc(parent: ^Element, $T: typeid, flags: Element_Flags = {}) -> ^T {
    element := new(T)
    element.flags = flags
    element.parent = parent
    if parent != nil {
        element.window = parent.window
        // The window is allowed to have only one child.
        if parent.window == cast(^Window) parent {
            if len(parent.children) == 1 {
                panic("Trying to add more children to window eh?")
            }
        }
        append(&parent.children, element)
    }
    return element
}

element_destroy :: proc(element: ^Element) {
    if .Element_Destroy in element.flags {
        return
    }
    element.flags |= {.Element_Destroy}
    for ancestor := element.parent; ancestor != nil; ancestor = ancestor.parent {
        ancestor.flags |= {.Element_Destroy_Descendent}
    }
    for child in element.children {
        element_destroy(child)
    }
}

element_message :: proc(element: ^Element, message: Msg) -> int {
    prof.event(#procedure)
    if element == nil {
        return 1
    }
    if _,ok := message.(Msg_Destroy); ok {
        if .Element_Destroy in element.flags {
            return 0
        }
    }
    if element.msg_user != nil {
        result := element.msg_user(element, message)
        if result != 0 {
            return result
        }
    }
    if element.msg_class != nil {
        result := element.msg_class(element, message)
        if result != 0 {
            return result
        }
    }
    return 0
}

element_move :: proc(element: ^Element, bounds: Rect, force_layout: bool) {
    prof.event(#procedure)
    old_clip := element.clip
    element.clip = rect_intersect(element.parent.clip, bounds)
    if  !rect_equals(element.bounds, bounds) ||
        !rect_equals(element.clip, old_clip) ||
        force_layout
    {
        element.bounds = bounds
        element_message(element, Msg_Layout{})
    }
}

element_find :: proc(element: ^Element, x, y: int) -> ^Element {
    prof.event(#procedure)
    for child in element.children {
        if rect_contains(child.clip, x, y) {
            return element_find(child, x, y)
        }
    }
    return element
}

element_find_scrollable :: proc(element: ^Element, x,y: int) -> ^Element {
    prof.event(#procedure)
    for child in element.children {
        if rect_contains(child.clip, x, y) {
            element := element_find_scrollable(child, x, y)
            if element != nil {
                return element
            }
        }
    }
    if .Scrollable in element.flags {
        return element
    } else {
        return nil
    }
}

element_repaint :: proc(element: ^Element, region: Maybe(Rect) = nil) {
    prof.event(#procedure)
    rect := region.? or_else element.bounds
    rect = rect_intersect(rect, element.clip)
    if !rect_valid(rect) {
        return
    }
    if rect_valid(element.window.dirty) {
        element.window.dirty = rect_union(element.window.dirty, rect)
    } else {
        element.window.dirty = rect
    }
}

@(private)
_element_paint :: proc(element: ^Element, painter: ^Painter) {
    prof.event(#procedure)
    clip := rect_intersect(element.clip, painter.clip)
    if !rect_valid(clip) {
        return
    }
    painter.clip = clip
    element_message(element, painter)
    for child in element.children {
        painter.clip = clip
        _element_paint(child, painter)
    }
}

@(private)
_element_destroy_now :: proc(element: ^Element) -> bool {
    prof.event(#procedure)
    if .Element_Destroy_Descendent in element.flags {
        element.flags &= ~{.Element_Destroy_Descendent}
        for idx := 0; idx < len(element.children); idx += 1 {
            if _element_destroy_now(element.children[idx]) {
                ordered_remove(&element.children, idx)
                idx -= 1
            }
        }
    }
    if .Element_Destroy in element.flags {
        element_message(element, Msg_Destroy{})
        if element.window.pressed == element {
            _window_set_pressed(element.window, nil, nil)
        }
        if element.window.hovered == element {
            element.window.hovered = element.window
        }
        delete(element.children)
        free(element)
        return true
    }
    return false
}
