package gui

import ft "shared:freetype"

import "core:log"
import "core:os"
import "core:fmt"
import "core:testing"

@(private="file") library: ft.Library
@(private="file") dpi :: Vec

// TODO: Load the font metrics.
Font :: struct {
    face: ft.Face,
}

Glyph :: struct {
    bitmap: [^]u8,
    size_x: int,
    size_y: int,
    mono:   bool,
    pos:    Vec,
}

@(init)
_ :: proc() {
    error := ft.init_free_type(&library)
    if error != nil {
        log.fatalf("Failed to initialize freetype")
        os.exit(1)
    }
}

load_font :: proc(path: cstring) -> (_font: Font, _ok: bool) #optional_ok {
    font := Font {}
    error := ft.new_face(library, path, 0, &font.face)
    if error == .Unknown_File_Format {
        log.errorf("Unknown file format: %s", path)
        return {}, false
    } else if error != nil {
        log.errorf("Error loading file format: %v", error)
        return {}, false
    }
    return font, true
}

font_glyph :: proc(font: Font, char: rune) -> (Glyph, bool) #optional_ok {
    index := ft.get_char_index(font.face, auto_cast char)
    if index == 0 {
        log.errorf("Unable to load character")
        return {}, false
    }
    size_error := ft.set_char_size(font.face, 64*10, 64*10, 300, 300)
    fmt.assertf(size_error == .Ok, "ft.set_char_size failed: %v", size_error)
    load_error := ft.load_glyph(font.face, index, {})
    if load_error != nil {
        log.errorf("Unable to load glyph for character")
        return {}, false
    }
    if font.face.glyph.format != .Bitmap {
        render_error := ft.render_glyph(font.face.glyph, .Normal)
        if render_error != nil {
            log.errorf("Unable to render glyph for character")
            return {}, false
        }
    }
    return Glyph {
        bitmap = font.face.glyph.bitmap.buffer,
        size_x = cast(int) font.face.glyph.bitmap.width,
        size_y = cast(int) font.face.glyph.bitmap.rows,
        mono = false,
        pos = {
            cast(f32) font.face.glyph.bitmap_left,
            cast(f32) font.face.glyph.bitmap_top,
        },
    }, true
}

@(private="file")
debug_print_glyph_to_console :: proc(glyph: Glyph) {
    brightness_map := " .,;!v#"
    for y in 0 ..< glyph.size_y {
        for x in 0 ..< glyph.size_x {
            pixel: int
            if !glyph.mono {
                pixel = auto_cast glyph.bitmap[x+y*glyph.size_x]
            } else {
                pixel_byte := glyph.bitmap[(x+y*glyph.size_x)/8]
                pixel = auto_cast (pixel_byte >> (cast(u8)x % 8))
            }
            brightness := int((cast(f32) pixel / 256.0) * cast(f32) len(brightness_map))
            fmt.printf("%c", cast(rune) brightness_map[brightness])
        }
        fmt.println()
    }
}

@(test, private)
test_fonts :: proc(t: ^testing.T) {
    font, font_ok := load_font("/usr/share/fonts/noto/NotoSerif-Medium.ttf")
    if !font_ok {
        fmt.println("Failed to load a font")
        os.exit(1)
    }
    glyph, glyph_ok := font_glyph(font, 'Q')
    if !glyph_ok {
        fmt.println("Failed to load a glyph")
        os.exit(1)
    }
    debug_print_glyph_to_console(glyph)
}
