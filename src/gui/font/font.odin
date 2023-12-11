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
    bitmap: types.Bitmap,
    pos:    types.Vec,
    char:   rune,
}

Mapped_Glyph :: struct {
    pos:    types.Vec,
    char:   rune,
    rect:   types.Rect,
}

Rune_Range :: struct {
    lo: rune,
    hi: rune,
}

pack_rune_ranges :: proc(
    bitmap:    types.Bitmap,
    font_path: cstring,
    ranges:    []Rune_Range,
    size_pt:   int,
) -> (map[rune]Mapped_Glyph, bool) {
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

