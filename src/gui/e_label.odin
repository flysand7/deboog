
package gui

Label :: struct {
    using element: Element,
    text: string,
}

label_create :: proc(parent: ^Element, flags: Element_Flags, text: string) -> ^Label {
    label := element_create(parent, Label, flags)
    label.text = text
    label.msg_class = label_message
    return label
}

@(private)
label_message :: proc(element: ^Element, message: Message, di: int, dp: rawptr) -> int {
    label := cast(^Label) element
    if message == .Paint {
        painter := cast(^Painter) dp
        foreground := u32(0xffffff)
        paint_string(painter, label.bounds, label.text, foreground)
    }
    return 0
}