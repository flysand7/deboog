
package gui

Element_Flags :: bit_set[Element_Flags_Bits]
Element_Flags_Bits :: enum {
    // Panel flags
    Panel_HLayout,
    Panel_VLayout,
}

Message :: enum {
    Update,
    Paint,
    // Mouse events
    Mouse_Move,
    Mouse_Drag,
    Mouse_Clicked,
    Mouse_Left_Press,
    Mouse_Left_Release,
    Mouse_Middle_Press,
    Mouse_Middle_Release,
    Mouse_Right_Press,
    Mouse_Right_Release,
    // Layout events
    Layout,
    Layout_Get_Width,
    Layout_Get_Height,
}

Update_Kind :: enum {
    Hovered,
    Pressed,
}

Message_Proc :: #type proc (element: ^Element, message: Message, di: int, dp: rawptr) -> int

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

element_message :: proc(element: ^Element, message: Message, di: int = 0, dp: rawptr = nil) -> int {
    if element == nil {
        return 1
    }
    if element.msg_user != nil {
        result := element.msg_user(element, message, di, dp)
        if result != 0 {
            return result
        }
    }
    if element.msg_class != nil {
        result := element.msg_class(element, message, di, dp)
        if result != 0 {
            return result
        }
    }
    return 0
}

element_move :: proc(element: ^Element, bounds: Rect, force_layout: bool) {
    old_clip := element.clip
    element.clip = rect_intersect(element.parent.clip, bounds)
    if  !rect_equals(element.bounds, bounds) ||
        !rect_equals(element.clip, old_clip) ||
        force_layout
    {
        element.bounds = bounds
        element_message(element, .Layout)
    }
}

element_find :: proc(element: ^Element, x, y: int) -> ^Element {
    for child in element.children {
        if rect_contains(child.clip, x, y) {
            return element_find(child, x, y)
        }
    }
    return element
}

element_repaint :: proc(element: ^Element, region: Maybe(Rect) = nil) {
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
    clip := rect_intersect(element.clip, painter.clip)
    if !rect_valid(clip) {
        return
    }
    painter.clip = clip
    element_message(element, .Paint, dp = cast(rawptr) painter)
    for child in element.children {
        painter.clip = clip
        _element_paint(child, painter)
    }
}
