
package gui

import "core:slice"

import "pesticider:prof"

Painter :: struct {
    clip:   Rect,
    pixels: [^]u32,
    size:   Vec,
}

@(export)
paint_box :: proc(painter: ^Painter, bounds: Rect, color: u32) #no_bounds_check {
    rect := rect_intersect(bounds, painter.clip)
    for y in rect.t ..< rect.b {
        for x in rect.l ..< rect.r {
            painter.pixels[x + y*painter.size.x] = color
        }
    }
}

paint_rect :: proc(painter: ^Painter, bounds: Rect, bg: u32, fg: u32) #no_bounds_check {
    prof.event(#procedure)
    paint_box(painter, bounds, bg)
    paint_box(painter, rect_make(bounds.l,   bounds.t,   bounds.r,   bounds.t+1), fg)
    paint_box(painter, rect_make(bounds.l,   bounds.t,   bounds.l+1, bounds.b),   fg)
    paint_box(painter, rect_make(bounds.l,   bounds.b-1, bounds.r,   bounds.b),   fg)
    paint_box(painter, rect_make(bounds.r-1, bounds.t,   bounds.r,   bounds.b),   fg)
}

paint_string :: proc(painter: ^Painter, bounds: Rect, str: string, color: u32, hcenter := true, vcenter := true) {
    prof.event(#procedure)
    clip := rect_intersect(bounds, painter.clip)
    x := bounds.l
    y := bounds.t
    if vcenter {
        y = (rect_size_y(bounds) - GLYPH_HEIGHT) / 2 + bounds.t
    }
    if hcenter {
        x = (rect_size_x(bounds) - GLYPH_WIDTH*len(str)) / 2 + bounds.l
    }
    // NOTE(flysand): We're not printing unicode so no reason to use foreach-style loop.
    for str_idx in 0 ..< len(str) { #no_bounds_check {
        c := str[str_idx]
        if c > 0x7f {
            c = '?'
        }
        char_rect := rect_intersect(clip, rect_make(x, y, x+8, y+16))
        data := (slice.to_bytes(font))[cast(int)c * 16:]
        for i in char_rect.t ..< char_rect.b {
            byte := data[i - y]
            for j in char_rect.l ..< char_rect.r {
                if (byte & (1 << cast(uint)(j - x))) != 0 {
                    painter.pixels[i*painter.size.x + j] = color
                }
            }
        }
        x += GLYPH_WIDTH
    }}
}
