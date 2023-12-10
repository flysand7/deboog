package font

import "src:gui/types"

Font :: struct {
    _handle:      rawptr, // Used by the font library to track the loaded font.
    _use_count:   int,    // Used by the renderer to count when the font should be unloaded.
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

Bitmap :: struct {
    buffer: [^]u8,
    size_x: int,
    size_y: int,
    mono:   bool,
}
