
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
label_message :: proc(element: ^Element, message: Msg) -> int {
    label := cast(^Label) element
    #partial switch msg in message {
        case Msg_Destroy:
            delete(label.text)
        case Msg_Paint:
            foreground := u32(0xffffff)
            paint_string(msg, label.bounds, label.text, foreground)
        case Msg_Preferred_Width:
            return len(label.text) * GLYPH_WIDTH
        case Msg_Preferred_Height:
            return GLYPH_HEIGHT
    }
    return 0
}