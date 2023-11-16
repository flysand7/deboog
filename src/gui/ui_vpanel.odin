
package gui

import "pesticider:prof"

@(private="file")
Scrollbar :: struct {
    using element: Element,
    scroll: int,
    total:  int,
}

@(private="file")
scrollbar_create :: proc(parent: ^Element, flags: Element_Flags = {}) -> ^Scrollbar {
    scrollbar := element_create(parent, Scrollbar, flags)
    scrollbar.msg_class = scrollbar_message
    return scrollbar
}

SCROLL_SPINDLE_HEIGHT :: 20

@(private="file")
scrollbar_message :: proc(element: ^Element, message: Msg) -> int {
    scrollbar := cast(^Scrollbar) element
    #partial switch msg in message {
    case Msg_Input_Clicked:
        percentage := cast(f32)(msg.pos.y - element.bounds.t) / cast(f32) rect_size_y(scrollbar.bounds)
        if percentage < 0 {
            percentage = 0
        } else if percentage > 1 {
            percentage = 1
        }
        scrollbar.scroll = cast(int) (percentage * cast(f32) scrollbar.total)
        // element_repaint(scrollbar)
        element_message(scrollbar.parent, Msg_Layout{})
    case Msg_Input_Drag:
        percentage := cast(f32)(msg.pos.y - element.bounds.t) / cast(f32) rect_size_y(scrollbar.bounds)
        if percentage < 0 {
            percentage = 0
        } else if percentage > 1 {
            percentage = 1
        }
        scrollbar.scroll = cast(int) (percentage * cast(f32) scrollbar.total)
        // element_repaint(scrollbar)
        element_message(scrollbar.parent, Msg_Layout{})
    case Msg_Paint:
        prof.event(#procedure)
        percentage := scrollbar_percentage(scrollbar)
        offset_y := scrollbar.bounds.t + cast(int) (cast(f32) rect_size_y(scrollbar.bounds) * percentage)
        paint_box(msg, scrollbar.bounds, 0xffffff)
        paint_box(msg, rect_make4(scrollbar.bounds.l, offset_y, scrollbar.bounds.r, offset_y + SCROLL_SPINDLE_HEIGHT), 0xff0000)
    }
    return 0
}

@(private="file")
scrollbar_percentage :: proc(scrollbar: ^Scrollbar) -> f32 {
    if scrollbar.total != 0.0 {
        return f32(scrollbar.scroll) / f32(scrollbar.total)
    } else {
        return 0.0
    }
}

VPanel :: struct {
    using element: Element,
    border:        Quad,
    gap:           int,
}

vpanel_create :: proc(parent: ^Element, flags: Element_Flags = {}) -> ^VPanel {
    panel := element_create(parent, VPanel, flags)
    panel.msg_class = vpanel_message
    // Create a child scrollbar. The panel will always have it
    // as its first child.
    _ = scrollbar_create(panel)
    return panel
}

@(private="file")
vpanel_message :: proc(element: ^Element, message: Msg) -> int {
    panel := cast(^VPanel) element
    #partial switch msg in message {
        case Msg_Paint:
            prof.event(#procedure)
            paint_box(msg, panel.bounds, 0x000000)
        case Msg_Layout:
            vpanel_layout(panel, panel.bounds)
            element_repaint(panel)
        case Msg_Preferred_Width:
            return vpanel_max_width(panel)
        case Msg_Preferred_Height:
            return vpanel_layout(panel, rect_make(0, 0, (msg.width.? or_else 0), 0), just_measure = true)
    }
    return 0
}

SCROLLBAR_WIDTH :: 20

@(private="file")
vpanel_layout :: proc(panel: ^VPanel, bounds: Rect, just_measure := false) -> int {
    position := panel.border.t
    space_x  := rect_size_x(bounds) - quad_size_x(panel.border) - SCROLLBAR_WIDTH
    space_y  := rect_size_y(bounds) - quad_size_y(panel.border)
    fills_count := 0
    total_y := 0
    for child in panel.children[1:] {
        if .Element_Destroy in child.flags {
            continue
        }
        if .Element_VFill in child.flags {
            fills_count += 1
        } else {
            height := element_message(child, Msg_Preferred_Height{width = space_x})
            total_y += height
        }
    }
    if len(panel.children) > 1 {
        total_y += (len(panel.children) - 2) * panel.gap
    }
    per_fill := 0
    if total_y < space_y && fills_count > 0 {
        per_fill = (space_y - total_y) / fills_count
    }
    // Check to see if we need a scrollbar and make a space for it.
    if !just_measure {
        if total_y > space_y {
            scrollbar := cast(^Scrollbar) panel.children[0]
            if scrollbar.total != total_y {
                // TODO(flysand): If the layout changed, we'll need to change the %
                // of the space we had scrolled. In the future this needs to be done
                // in a different way where we use offsets to particular elements to
                // see what had changed.
                scrollbar.scroll = cast(int) (f32(total_y) * scrollbar_percentage(scrollbar))
            }
            scrollbar.total = total_y
            scrollbar_bounds := Rect {
                l = bounds.r - SCROLLBAR_WIDTH,
                t = bounds.t,
                r = bounds.r,
                b = bounds.b,
            }
            element_move(scrollbar, scrollbar_bounds, false)
        }
    }
    // Layout the other children.
    for child in panel.children[1:] {
        if .Element_Destroy in child.flags {
            continue
        }
        width := 0
        height := 0
        if .Element_HFill in child.flags {
            width = space_x
        } else {
            if .Element_VFill in child.flags {
                width = element_message(child, Msg_Preferred_Width{height = per_fill})
            } else {
                width = element_message(child, Msg_Preferred_Width{})
            }
        }
        if .Element_VFill in child.flags {
            height = element_message(child, Msg_Preferred_Height{width = per_fill})
        } else {
            height = element_message(child, Msg_Preferred_Height{width = width})
        }
        if !just_measure {
            scrollbar := cast(^Scrollbar) panel.children[0]
            rect := rect_make(
                bounds.l + panel.border.l + (space_x - width)/2,
                bounds.t + position - scrollbar.scroll,
                bounds.l + panel.border.l + (space_x + width)/2,
                bounds.t + position - scrollbar.scroll + height)
            element_move(child, rect, false)
        }
        position += height + panel.gap
    }
    if len(panel.children) > 1 {
        position -= panel.gap
    }
    return position + panel.border.t
}

@(private="file")
vpanel_max_width :: proc(panel: ^VPanel) -> int {
    max_width := 0
    for child in panel.children {
        if .Element_Destroy in child.flags {
            continue
        }
        child_width := element_message(child, Msg_Preferred_Width{})
        max_width = max(child_width, max_width)
    }
    return max_width + quad_size_x(panel.border)
}
