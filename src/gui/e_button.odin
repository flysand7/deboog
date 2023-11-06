
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
            pressed := button.window.pressed == button && button.window.hovered == button
            color_bg_normal := u32(0x000000)
            color_fg_normal := u32(0xdddddd)
            color_fg_active := u32(0xffffff)
            color_fg := color_fg_normal if !pressed else color_fg_active
            paint_rect(painter, button.bounds, color_bg_normal, color_fg_normal)
            paint_string(painter, button.bounds, button.text, color_fg_normal)
        case .Update:
            element_repaint(button, nil)
    }
    return 0
}
