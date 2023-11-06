
package gui

Button :: struct {
    using element: Element,
    text: string,
}

button_create :: proc(parent: ^Element, flags: Element_Flags, text: string) -> ^Button {
    button := element_create(parent, Button, flags)
    button.text = text
    button.msg_class = _button_message
    return button
}

@(private)
_button_message :: proc (element: ^Element, message: Message, di: int, dp: rawptr) -> int {
    button := cast(^Button) element
    #partial switch message {
        case .Paint:
            painter := cast(^Painter) dp
            hovered := button.window.hovered == button
            pressed := button.window.pressed == button && button.window.hovered == button
            color_bg_normal := u32(0x000000)
            color_fg_normal := u32(0x777777)
            color_fg_active := u32(0xffffff)
            color_fg_press  := u32(0x444444)
            color_fg := color_fg_press  if pressed else
                        color_fg_active if hovered else
                        color_fg_normal
            paint_rect(painter, button.bounds, color_bg_normal, color_fg)
            paint_string(painter, button.bounds, button.text, color_fg)
        case .Update:
            element_repaint(button, nil)
        case .Layout_Get_Width:
            return 30 + len(button.text) * GLYPH_WIDTH
        case .Layout_Get_Height:
            return 15 + GLYPH_HEIGHT
            
    }
    return 0
}
