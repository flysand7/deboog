
package gui

import "core:time"

Checkbox :: struct {
    using element: Element,
    checked: bool,
    color: Color_Property,
}

checkbox_create :: proc(parent: ^Element, flags: Element_Flags, checked := false) -> ^Checkbox {
    checkbox := element_create(parent, Checkbox, flags)
    checkbox.checked = checked
    checkbox.msg_class = checkbox_message
    checkbox.color = color_property(checkbox, 0x42c8f5)
    return checkbox
}

checkbox_message :: proc(element: ^Element, message: Msg) -> int {
    checkbox := cast(^Checkbox) element
    #partial switch msg in message {
        case Msg_Preferred_Width, Msg_Preferred_Height:
            return 25
        case Msg_Input_Clicked:
            checkbox.checked = !checkbox.checked
            new_color := checkbox.checked? u32(0x42c8f5) : u32(0x333333)
            animate(&checkbox.color, new_color, time.Second/6)
        case Msg_Input_Hovered, Msg_Input_Pressed:
            element_repaint(checkbox)
        case Msg_Paint:
            hovered := checkbox.window.hovered == checkbox
            pressed := checkbox.window.pressed == checkbox && checkbox.window.hovered == checkbox
            color_border := hovered? u32(0xffffff) : u32(0x777777)
            if pressed {
                color_border = u32(0x333333)
            }
            color_checked := u32(checkbox.color.value)
            color_back := u32(0x000000)
            paint_rect(msg, element.bounds, color_back, color_border)
            indent := 5
            rect := rect_make(
                element.bounds.l + indent,
                element.bounds.t + indent,
                element.bounds.r - indent,
                element.bounds.b - indent)
            paint_box(msg, rect, color_checked)
    }
    return 0
}
