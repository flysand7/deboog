
package gui

VPanel :: struct {
    using element: Element,
    border:        Quad,
    gap:           int,
}

vpanel_create :: proc(parent: ^Element, flags: Element_Flags = {}) -> ^VPanel {
    flags := flags
    panel := element_create(parent, VPanel, flags)
    panel.msg_class = vpanel_message
    return panel
}

@(private="file")
vpanel_message :: proc(element: ^Element, message: Msg) -> int {
    panel := cast(^VPanel) element
    #partial switch msg in message {
        case Msg_Paint:
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

import "core:fmt"
@(private="file")
vpanel_layout :: proc(panel: ^VPanel, bounds: Rect, just_measure := false) -> int {
    // TODO(flysand): Apparently we weren't taking into account the right/bottom
    // borders of the panel.
    position := panel.border.t
    h_space  := bounds.r - bounds.l - quad_size_x(panel.border)
    v_space  := bounds.b - bounds.t - quad_size_y(panel.border)
    available := v_space
    fill     := 0
    for child in panel.children {
        if .Element_Destroy in child.flags {
            continue
        }
        if .Element_VFill in child.flags {
            fill += 1
        } else if available > 0 {
            height := element_message(child, Msg_Preferred_Height{width = h_space})
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
                width = element_message(child, Msg_Preferred_Width{height = per_fill})
            } else {
                width = element_message(child, Msg_Preferred_Width{})
            }
        }
        if .Element_VFill in child.flags {
            height = element_message(child, Msg_Preferred_Height{width = per_fill})
        } else {
            height = element_message(child, Msg_Preferred_Height{width = width})
            fmt.printf("Want height: %d\n", height)
        }
        rect := rect_make(
            bounds.l + panel.border.l + (h_space - width)/2,
            bounds.t + position,
            bounds.l + panel.border.l + (h_space + width)/2,
            bounds.t + height + position)
        if !just_measure {
            element_move(child, rect, false)
        }
        position += height + panel.gap
    }
    if len(panel.children) > 0 {
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
    return max_width + panel.border.t + panel.border.b
}
