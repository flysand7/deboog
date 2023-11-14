
package gui

import "core:strings"

Label :: struct {
    using element: Element,
    text: string,
}

label_create :: proc(parent: ^Element, flags: Element_Flags, text: string) -> ^Label {
    label := element_create(parent, Label, flags)
    label.text = strings.clone(text)
    label.msg_class = label_message
    return label
}

@(private)
label_message :: proc(element: ^Element, message: Message, di: int, dp: rawptr) -> int {
    label := cast(^Label) element
    #partial switch message {
        case .Destroy:
            delete(label.text)
        case .Paint:
            painter := cast(^Painter) dp
            foreground := u32(0xffffff)
            paint_string(painter, label.bounds, label.text, foreground)
        case .Layout_Get_Width:
            return len(label.text) * GLYPH_WIDTH
        case .Layout_Get_Height:
            return GLYPH_HEIGHT
    }
    return 0
}