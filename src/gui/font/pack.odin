package font

import "src:gui/types"

import "core:slice"

Rect :: types.Rect

pack_glyphs :: proc(bitmap: Bitmap, glyphs_: []Glyph) -> map[rune]Rect {
    mapping := make(map[rune]Rect, allocator = context.allocator)
    glyphs  := slice.clone(glyphs_, context.temp_allocator)
    slice.sort_by(glyphs, proc(a, b: Glyph) -> bool {
        return a.bitmap.size_y < b.bitmap.size_y
    })
    ymax  := 0
    xoffs := 0
    yoffs := 0
    for glyph in glyphs {
        if bitmap.size_y - glyph.bitmap.size_y <= 0 {
            panic("NOT ENOUGH SPACE")
        }
        if xoffs + glyph.bitmap.size_x > bitmap.size_x {
            yoffs += ymax
            xoffs = 0
            ymax  = 0
        }
        write_glyph_to_rect(bitmap, glyph.bitmap, xoffs, yoffs)
        mapping[glyph.char] = Rect {
            left   = cast(f32) (xoffs),
            top    = cast(f32) (yoffs),
            right  = cast(f32) (xoffs + glyph.bitmap.size_x),
            bottom = cast(f32) (yoffs + glyph.bitmap.size_y),
        }
        xoffs += glyph.bitmap.size_x
        ymax = max(ymax, glyph.bitmap.size_y)
    }
    return mapping
}

write_glyph_to_rect :: proc(dst_bitmap, src_bitmap: Bitmap, xoffs, yoffs: int) {
    for y in 0 ..< src_bitmap.size_y {
        for x in 0 ..< src_bitmap.size_x {
            src_pixel := src_bitmap.buffer[x + y*src_bitmap.size_x]
            dst_offs_x := xoffs + x
            dst_offs_y := yoffs + y
            // fmt.println(dst_offs_x, dst_offs_y)
            dst_bitmap.buffer[dst_offs_x + dst_offs_y * dst_bitmap.size_x] = src_pixel
        }
    }
}
