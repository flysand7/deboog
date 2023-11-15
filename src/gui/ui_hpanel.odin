
package gui

HPanel :: struct {
    using element: Element,
    border:        Quad,
    gap:           int,
}

hpanel_create :: proc(parent: ^Element, flags: Element_Flags = {}) -> ^HPanel {
    flags := flags
    panel := element_create(parent, HPanel, flags)
    panel.msg_class = hpanel_message
    return panel
}

@(private="file")
hpanel_message :: proc(element: ^Element, message: Msg) -> int {
    panel := cast(^HPanel) element
    #partial switch msg in message {
        case Msg_Paint:
            paint_box(msg, panel.bounds, 0x000000)
        case Msg_Layout:
            hpanel_layout(panel, panel.bounds)
            element_repaint(panel)
        case Msg_Preferred_Width:
            return hpanel_layout(panel, rect_make(0, 0, 0, (msg.height.? or_else 0)), just_measure = true)
        case Msg_Preferred_Height:
            return hpanel_max_height(panel)
    }
    return 0
}

@(private="file")
hpanel_layout :: proc(panel: ^HPanel, bounds: Rect, just_measure := false) -> int {
    position := panel.border.l
    h_space  := rect_size_x(bounds) - quad_size_x(panel.border)
    v_space  := rect_size_y(bounds) - quad_size_y(panel.border)
    available := h_space
    fill     := 0
    for child in panel.children {
        if .Element_Destroy in child.flags {
            continue
        }
        if .Element_HFill in child.flags {
            fill += 1
        } else if available > 0 {
            width := element_message(child, Msg_Preferred_Width{height = v_space})
            available -= width
        }
    }
    if len(panel.children) > 0 {
        available -= (len(panel.children) - 1) * panel.gap
    }
    per_fill := 0
    if available > 0 && fill > 0 {
        per_fill = available / fill
    }
    for child in panel.children {
        if .Element_Destroy in child.flags {
            continue
        }
        // TODO(flysand): Forgot to handle the HFill flag.
        height := element_message(child, Msg_Preferred_Height{})
        width := element_message(child, Msg_Preferred_Width{height = height})
        rect := rect_make(
            bounds.l + position,
            bounds.t + (v_space - height) / 2 + bounds.t,
            bounds.l + width + position,
            bounds.t + (v_space + height) / 2 + bounds.t)
        if !just_measure {
            element_move(child, rect, false)
        }
        position += width + panel.gap
    }
    if len(panel.children) > 0 {
        position -= panel.gap
    }
    return position + panel.border.l
}

@(private="file")
hpanel_max_height :: proc(panel: ^HPanel) -> int {
    max_height := 0
    for child in panel.children {
        if .Element_Destroy in child.flags {
            continue
        }
        child_height := element_message(child, Msg_Preferred_Height{})
        max_height = max(child_height, max_height)
    }
    return max_height + quad_size_y(panel.border)
}
