package font

import ft "freetype"

import "src:gui/types"

import "core:log"
import "core:os"
// import "core:fmt"
import "core:slice"
import "core:unicode"

@(private="file") library: ft.Library
@(private="file") monitor_dpi: types.Vec = {300, 300}

@(init)
_ :: proc() {
    error := ft.init_free_type(&library)
    if error != nil {
        log.fatalf("Failed to initialize freetype")
        os.exit(1)
    }
}

tell_monitor_dpi :: proc(dpi: types.Vec) {
    monitor_dpi = dpi
}

load :: proc(path: cstring) -> (_font: Font, _ok: bool) #optional_ok {
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

_free :: proc(font: Font) {
    ft.done_face(ft_face(font))
}

glyph :: proc(font: Font, char: rune, size_pt: int) -> (Glyph, bool) #optional_ok {
    index := ft.get_char_index(ft_face(font), auto_cast char)
    if index == 0 {
        log.errorf("Unable to load character")
        return {}, false
    }
    load_error := ft.load_glyph(ft_face(font), index, {})
    if load_error != nil {
        log.errorf("Unable to load glyph for character")
        return {}, false
    }
    if ft_face(font).glyph.format != .Bitmap {
        render_error := ft.render_glyph(ft_face(font).glyph, .Normal)
        if render_error != nil {
            log.errorf("Unable to render glyph for character")
            return {}, false
        }
    }
    orig_buffer := ft_face(font).glyph.bitmap.buffer
    orig_size_x := cast(int) ft_face(font).glyph.bitmap.width
    orig_size_y := cast(int) ft_face(font).glyph.bitmap.rows
    orig_size := orig_size_x * orig_size_y
    cloned := slice.clone(slice.from_ptr(orig_buffer, orig_size))
    return Glyph {
        bitmap = {
            buffer = raw_data(cloned),
            size_x = orig_size_x,
            size_y = orig_size_y,
        },
        pos = {
            cast(f32) ft_face(font).glyph.bitmap_left,
            cast(f32) ft_face(font).glyph.bitmap_top,
        },
        char = char,
    }, true
}

glyphs :: proc(font: Font, ranges: []Rune_Range, size_pt: int) -> (
    [dynamic]Glyph, bool,
) #optional_ok
{
    size_error := ft.set_char_size(
        ft_face(font),
        auto_cast (64*16),
        auto_cast (64*16),
        auto_cast 300,
        auto_cast 300,
    )
    if size_error != nil {
        return {}, false
    }
    glyphs := make([dynamic]Glyph, len(ranges))
    for range in ranges {
        for c in range.lo ..= range.hi {
            glyph, glyph_ok := glyph(font, c, 16)
            if glyph_ok {
                append(&glyphs, glyph)
            } else {
                if unicode.is_print(c) {
                    delete(glyphs)
                    return {}, false
                }
            }
        }
    }
    return glyphs, true
}

@(private="file")
ft_face :: proc(font: Font) -> ft.Face {
    return cast(ft.Face) font._handle
}
