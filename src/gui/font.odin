package gui

import ft "shared:freetype"

import "core:log"
import "core:os"
import "core:fmt"
import "core:testing"

@(private="file") library: ft.Library
@(private="file") monitor_dpi: Vec = {96, 96}

Font :: struct {
    _handle:      ft.Face, // Used by the font library to track the loaded font.
    _use_count:   int,     // Used by the renderer to count when the font should be unloaded.
    units_per_em: int,
    ascender:     int,
    descender:    int,
    height:       int,
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

font_tell_monitor_dpi :: proc(dpi: Vec) {
    monitor_dpi = dpi
}

font_load :: proc(path: cstring) -> (_font: Font, _ok: bool) #optional_ok {
    face := ft.Face {}
    error := ft.new_face(library, path, 0, &face)
    if error == .Unknown_File_Format {
        log.errorf("Unknown file format: %s", path)
        return {}, false
    } else if error != nil {
        log.errorf("Error loading file format: %v", error)
        return {}, false
    }
    return Font {
        _handle      = face,
        ascender     = auto_cast face.ascender,
        descender    = auto_cast face.descender,
        height       = auto_cast face.height,
        units_per_em = auto_cast face.units_per_em,
    }, true
}

font_free :: proc(font: Font) {
    ft.done_face(font._handle)
}

font_glyph :: proc(font: Font, char: rune, size_pt: int) -> (Glyph, bool) #optional_ok {
    index := ft.get_char_index(font._handle, auto_cast char)
    if index == 0 {
        log.errorf("Unable to load character")
        return {}, false
    }
    size_error := ft.set_char_size(
        font._handle,
        auto_cast (64*size_pt),
        auto_cast (64*size_pt),
        auto_cast monitor_dpi.x,
        auto_cast monitor_dpi.y,
    )
    fmt.assertf(size_error == .Ok, "ft.set_char_size failed: %v", size_error)
    load_error := ft.load_glyph(font._handle, index, {})
    if load_error != nil {
        log.errorf("Unable to load glyph for character")
        return {}, false
    }
    if font._handle.glyph.format != .Bitmap {
        render_error := ft.render_glyph(font._handle.glyph, .Normal)
        if render_error != nil {
            log.errorf("Unable to render glyph for character")
            return {}, false
        }
    }
    return Glyph {
        bitmap = font._handle.glyph.bitmap.buffer,
        size_x = cast(int) font._handle.glyph.bitmap.width,
        size_y = cast(int) font._handle.glyph.bitmap.rows,
        mono = false,
        pos = {
            cast(f32) font._handle.glyph.bitmap_left,
            cast(f32) font._handle.glyph.bitmap_top,
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
    font, font_ok := font_load("/usr/share/fonts/noto/NotoSerif-Medium.ttf")
    if !font_ok {
        fmt.println("Failed to load a font")
        os.exit(1)
    }
    glyph, glyph_ok := font_glyph(font, 'Q', 9)
    if !glyph_ok {
        fmt.println("Failed to load a glyph")
        os.exit(1)
    }
    debug_print_glyph_to_console(glyph)
}
