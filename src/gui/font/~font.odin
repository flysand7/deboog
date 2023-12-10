package font

import stbi "vendor:stb/image"

import "core:testing"
import "core:fmt"

@(test, private)
test_packing :: proc(t: ^testing.T) {
    font, font_ok := font_load("/usr/share/fonts/noto/NotoSerif-Medium.ttf")
    if !font_ok {
        fmt.println("Failed to load a font")
        testing.fail_now(t)
    }
    glyphs: [dynamic]Glyph
    rune_ranges := []struct{start, end: rune}{
        { ' ',  '~' },          // ASCII
        { '\u00a0', '\u00ff' }, // Latin-1 supplement
        { '\u0100', '\u024f' }, // Latin-extended A and B
        { '\u0370', '\u03ff' }, // Greek
        { '\u0400', '\u04ff' }, // Cyrillic
    }
    for range in rune_ranges {
        for c in range.start ..= range.end {
            glyph, glyph_ok := font_glyph(font, c, 16)
            if glyph_ok {
                append(&glyphs, glyph)
            }
        }
    }
    bitmap_size_x := 4096
    bitmap_size_y := 4096
    bitmap := Bitmap {
        size_x = bitmap_size_x,
        size_y = bitmap_size_y,
        buffer = raw_data(make([]u8, bitmap_size_x * bitmap_size_y)),
        mono   = false,
    }
    pack_glyphs(bitmap, glyphs[:])
    write_status := stbi.write_bmp("test/font.bmp",
        auto_cast bitmap.size_x,
        auto_cast bitmap.size_y,
        1,
        bitmap.buffer,
    )
    if write_status == 0 {
        fmt.println("Failed to write font.jpg")
        testing.fail_now(t)
    }
}

@(test, private)
test_font :: proc(t: ^testing.T) {
    font, font_ok := font_load("/usr/share/fonts/noto/NotoSerif-Medium.ttf")
    if !font_ok {
        fmt.println("Failed to load a font")
        testing.fail_now(t)
    }
    glyph, glyph_ok := font_glyph(font, 'Q', 9)
    if !glyph_ok {
        fmt.println("Failed to load a glyph")
        testing.fail_now(t)
    }
    debug_print_glyph_to_console(glyph)
}

@(private)
debug_print_glyph_to_console :: proc(glyph: Glyph) {
    brightness_map := " .,;!v#"
    for y in 0 ..< glyph.bitmap.size_y {
        for x in 0 ..< glyph.bitmap.size_x {
            pixel: int
            if !glyph.bitmap.mono {
                pixel = auto_cast glyph.bitmap.buffer[x+y*glyph.bitmap.size_x]
            } else {
                pixel_byte := glyph.bitmap.buffer[(x+y*glyph.bitmap.size_x)/8]
                pixel = auto_cast (pixel_byte >> (cast(u8)x % 8))
            }
            brightness := int((cast(f32) pixel / 256.0) * cast(f32) len(brightness_map))
            fmt.printf("%c", cast(rune) brightness_map[brightness])
        }
        fmt.println()
    }
}


