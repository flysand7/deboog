
package gui

VPanel :: struct {
    using element: Element,
    border:        Rect,
    gap:           int,
}

vpanel_create :: proc(parent: ^Element, flags: Element_Flags = {}) -> ^VPanel {
    flags := flags
    panel := element_create(parent, VPanel, flags)
    panel.msg_class = vpanel_message
    return panel
}

@(private="file")
vpanel_message :: proc(element: ^Element, message: Message, di: int, dp: rawptr) -> int {
    panel := cast(^VPanel) element
    #partial switch message {
        case .Paint:
            painter := cast(^Painter) dp
            paint_box(painter, panel.bounds, 0x000000)
        case .Layout:
            vpanel_layout(panel, panel.bounds)
            element_repaint(panel)
        case .Layout_Get_Width:
            return vpanel_max_width(panel)
        case .Layout_Get_Height:
            return vpanel_layout(panel, rect_make(0, 0, di, 0), just_measure = true)
    }
    return 0
}

@(private="file")
vpanel_layout :: proc(panel: ^VPanel, bounds: Rect, just_measure := false) -> int {
    border1  := panel.border.t
    border2  := panel.border.l
    position := border1
    h_space  := bounds.r - bounds.l - panel.border.r - panel.border.l
    v_space  := bounds.b - bounds.t - panel.border.t - panel.border.b
    available := v_space
    fill     := 0
    for child in panel.children {
        if .Element_Destroy in child.flags {
            continue
        }
        if .Element_VFill in child.flags {
            fill += 1
        } else if available > 0 {
            height := element_message(child, .Layout_Get_Height, h_space)
            available -= height
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
        width := 0
        height := 0
        if .Element_HFill in child.flags {
            width = h_space
        } else {
            if .Element_VFill in child.flags {
                // TODO(flysand): This seems wrong.
                width = element_message(child, .Layout_Get_Width, per_fill)
            } else {
                width = element_message(child, .Layout_Get_Width, 0)
            }
        }
        if .Element_VFill in child.flags {
            height = element_message(child, .Layout_Get_Height, per_fill)
        } else {
            height = element_message(child, .Layout_Get_Height, width)
        }
        rect := rect_make(
            border2 + (h_space - width)/2 + bounds.l,
            bounds.t + position,
            border2 + (h_space + width)/2 + bounds.l,
            bounds.t + height + position)
        if !just_measure {
            element_move(child, rect, false)
        }
        position += height + panel.gap
    }
    if len(panel.children) > 0 {
        position -= panel.gap
    }
    return position + border1
}

@(private="file")
vpanel_max_width :: proc(panel: ^VPanel) -> int {
    max_width := 0
    for child in panel.children {
        if .Element_Destroy in child.flags {
            continue
        }
        child_width := element_message(child, .Layout_Get_Width, 0)
        max_width = max(child_width, max_width)
    }
    return max_width + panel.border.t + panel.border.b
}
