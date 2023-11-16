
package gui

import "core:strings"
import "pesticider:prof"

Text_View :: struct {
    using _: Element,
    text: string,
}

text_view_create :: proc(parent: ^Element, flags: Element_Flags, text: string) -> ^Text_View {
    text_view := element_create(parent, Text_View, flags | {.Element_HFill})
    text_view.msg_class = text_view_message
    text_view.text = strings.clone(text)
    return text_view
}

@(private="file")
text_view_message :: proc(element: ^Element, message: Msg) -> int {
    text_view := cast(^Text_View) element
    #partial switch msg in message {
        case Msg_Destroy:
            delete(text_view.text)
        case Msg_Paint:
            prof.event(#procedure)
            text_bounds := element.bounds
            text := text_view.text
            for line in strings.split_lines_iterator(&text) {
                paint_string(msg, text_bounds, line, u32(0xffffff), false, false)
                text_bounds.t += GLYPH_HEIGHT
            }
        case Msg_Preferred_Width:
            if height, ok := msg.height.?; ok {
                return text_calc_width_given_height(text_view.text, height)
            } else {
                return 10
            }
        case Msg_Preferred_Height:
            if width, ok := msg.width.?; ok {
                return text_calc_height_given_width(text_view.text, width)
            } else {
                return 10
            }
    }
    return 0
}

// TODO(flysand): Handle special characters.

// TODO(flysand): Calculating the text width/height needs to take into
// account the wrapping mode. For now wrapping will be assumed to be No_Wrap.

@(private="file")
text_calc_width_given_height :: proc(text: string, height: int) -> int {
    text := text
    max_line_width := 0
    for line in strings.split_lines_iterator(&text) {
        max_line_width = max(max_line_width, len(line))
    }
    return max_line_width * GLYPH_WIDTH
}

@(private="file")
text_calc_height_given_width :: proc(text: string, width: int) -> int {
    lines_count := 1
    text := text
    for _ in strings.split_lines_iterator(&text) {
        lines_count += 1
    }
    return lines_count * GLYPH_HEIGHT
}
