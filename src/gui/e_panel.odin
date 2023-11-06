
package gui

Panel :: struct {
    using element: Element,
}

panel_create :: proc(parent: ^Element, flags: Element_Flags) -> ^Panel {
    flags := flags
    panel := element_create(parent, Panel, flags)
    panel.msg_class = panel_message
    return panel
}

@(private)
panel_message :: proc(element: ^Element, message: Message, di: int, dp: rawptr) -> int {
    panel := cast(^Panel) element
    #partial switch message {
        case .Paint:
            painter := cast(^Painter) dp
            paint_box(painter, panel.bounds, 0x000000)
        case .Layout:
            panel_layout(panel, panel.bounds)
            element_repaint(panel)
        case .Layout_Get_Width:
            width: int
            if .Panel_HLayout in panel.flags {
                width = panel_layout(panel, rect_make(0, 0, 0, di), just_measure = true)
            } else {
                width = panel_measure_lateral(panel)
            }
            return width
        case .Layout_Get_Height:
            height: int
            if .Panel_HLayout in panel.flags {
                height = panel_measure_lateral(panel)
            } else {
                height = panel_layout(panel, rect_make(0, 0, di, 0), just_measure = true)
            }
            return height
    }
    return 0
}

@(private)
panel_layout :: proc(panel: ^Panel, bounds: Rect, just_measure := false) -> int {
    position := 0
    h_space := bounds.r - bounds.l
    v_space := bounds.b - bounds.t
    for child in panel.children {
        if .Panel_HLayout in panel.flags {
            height := element_message(child, .Layout_Get_Height, 0)
            width := element_message(child, .Layout_Get_Width, height)
            rect := rect_make(
                bounds.l + position,
                (v_space - height) / 2 + bounds.t,
                bounds.l + width + position,
                (v_space + height) / 2 + bounds.t)
            if !just_measure {
                element_move(child, rect, false)
            }
            position += width
        } else {
            width := element_message(child, .Layout_Get_Width, 0)
            height := element_message(child, .Layout_Get_Height, width)
            rect := rect_make(
                (h_space - width)/2 + bounds.l,
                bounds.t + position,
                (h_space + width)/2 + bounds.l,
                bounds.t + height + position)
            if !just_measure {
                element_move(child, rect, false)
            }
            position += height            
        }
    }
    return position
}

@(private)
panel_measure_lateral :: proc(panel: ^Panel) -> int {
    max_size := 0
    for child in panel.children {
        message := Message.Layout_Get_Height if .Panel_HLayout in panel.flags else .Layout_Get_Width
        child_size := element_message(child, message, 0)
        max_size = max(child_size, max_size)
    }
    return max_size
}
