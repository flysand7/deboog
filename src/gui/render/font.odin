package gui_render

import fonts "src:gui/font"
import types "src:gui/types"

Packed_Font :: struct {
    face:    fonts.Font,
    mapping: map[rune]fonts.Mapped_Glyph,
    texture: Texture,
    size_x:  f32,
    size_y:  f32,
}

make_packed_font :: proc(filename: cstring, size, atlas_size: int) -> Packed_Font {
    font, font_ok := fonts.load(filename)
    assert(font_ok)
    bitmap := types.make_bitmap(atlas_size, atlas_size)
    mapping, mapping_ok := fonts.pack_rune_ranges(
        bitmap,
        font,
        []fonts.Rune_Range {
            {'\u0000', '\ud7ff'},
        },
        size,
    )
    assert(mapping_ok)
    texture := texture_from_bitmap(bitmap, 1, monochrome_alpha = true)
    return {
        face    = font,
        mapping = mapping,
        texture = texture,
        size_x  = cast(f32) bitmap.size_x,
        size_y  = cast(f32) bitmap.size_y,
    }
}

str :: proc(the_string: string, pos: Vec, scale: f32, color: Color, face: Packed_Font) {
    render_char :: char
    offs := f32(0)
    for r in the_string {
        char := face.mapping[r]
        char_size := rect_size(char.rect)
        char_size *= [2]f32 { face.size_x, face.size_y } * scale
        char_pos := pos + [2]f32 {
            +offs,
            -char.pos.y-char_size.y,
        }
        render_char(
            {char_pos.x, char_pos.y, char_pos.x + char_size.x, char_pos.y + char_size.y},
            char.rect,
            face.texture,
            color,
        )
        offs += char_size.x+5
    }
}

