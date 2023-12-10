package font

import "src:gui/types"

Font :: struct {
    _handle:      rawptr, // Handle to the loaded font, library-specific code
    _use_count:   int,    // Refcount for UI
    units_per_em: int,
    ascender:     int,
    descender:    int,
    height:       int,
}

Glyph :: struct {
    bitmap: Bitmap,
    pos:    types.Vec,
    char:   rune,
}

Rune_Range :: struct {
    lo: rune,
    hi: rune,
}

Bitmap :: struct {
    buffer: [^]u8,
    size_x: int,
    size_y: int,
}

make_bitmap :: proc(size_x, size_y: int) -> Bitmap {
    return {
        buffer = raw_data(make([]u8, size_x * size_y)),
        size_x = size_x,
        size_y = size_y,
    }
}

pack_rune_ranges :: proc(
    bitmap:    Bitmap,
    font_path: cstring,
    ranges:    []Rune_Range,
    size_pt:   int,
) -> (map[rune]Rect, bool) {
    font, load_ok := load(font_path)
    if ! load_ok {
        return {}, false
    }
    defer _free(font)
    glyphs, glyphs_ok := glyphs(font, ranges, size_pt)
    if ! glyphs_ok {
        return {}, false
    }
    defer delete(glyphs)
    mapping := pack_glyphs(bitmap, glyphs[:])
    return mapping, true
}

