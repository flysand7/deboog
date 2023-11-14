
package gui

HPanel :: struct {
    using element: Element,
    border:        Rect,
    gap:           int,
}

hpanel_create :: proc(parent: ^Element, flags: Element_Flags = {}) -> ^HPanel {
    flags := flags
    panel := element_create(parent, HPanel, flags)
    panel.msg_class = hpanel_message
    return panel
}

@(private="file")
hpanel_message :: proc(element: ^Element, message: Message, di: int, dp: rawptr) -> int {
    panel := cast(^HPanel) element
    #partial switch message {
        case .Paint:
            painter := cast(^Painter) dp
            paint_box(painter, panel.bounds, 0x000000)
        case .Layout:
            hpanel_layout(panel, panel.bounds)
            element_repaint(panel)
        case .Layout_Get_Width:
            return hpanel_layout(panel, rect_make(0, 0, 0, di), just_measure = true)
        case .Layout_Get_Height:
            return hpanel_max_height(panel)
    }
    return 0
}

@(private="file")
hpanel_layout :: proc(panel: ^HPanel, bounds: Rect, just_measure := false) -> int {
    border1  := panel.border.l
    border2  := panel.border.t
    position := border1
    h_space  := bounds.r - bounds.l - panel.border.r - panel.border.l
    v_space  := bounds.b - bounds.t - panel.border.t - panel.border.b
    available := h_space
    fill     := 0
    for child in panel.children {
        if .Element_Destroy in child.flags {
            continue
        }
        if .Element_HFill in child.flags {
            fill += 1
        } else if available > 0 {
            width := element_message(child, .Layout_Get_Width, v_space)
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
        height := element_message(child, .Layout_Get_Height, 0)
        width := element_message(child, .Layout_Get_Width, height)
        rect := rect_make(
            bounds.l + position,
            border2 + (v_space - height) / 2 + bounds.t,
            bounds.l + width + position,
            border2 + (v_space + height) / 2 + bounds.t)
        if !just_measure {
            element_move(child, rect, false)
        }
        position += width + panel.gap
    }
    if len(panel.children) > 0 {
        position -= panel.gap
    }
    return position + border1
}

@(private="file")
hpanel_max_height :: proc(panel: ^HPanel) -> int {
    max_height := 0
    for child in panel.children {
        if .Element_Destroy in child.flags {
            continue
        }
        child_height := element_message(child, .Layout_Get_Height, 0)
        max_height = max(child_height, max_height)
    }
    h_border := panel.border.t + panel.border.b
    return max_height + h_border
}
