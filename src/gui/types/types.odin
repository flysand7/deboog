/*
    In its own package to prevent circular imports.
*/
package gui_types

Rect :: struct {
    left:   f32,
    top:    f32,
    right:  f32,
    bottom: f32,
}

Quad :: struct {
    left:   f32,
    right:  f32,
    top:    f32,
    bottom: f32,
}

Vec :: [2]f32

Color :: [3]f32

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

rect_size :: proc(rect: Rect) -> Vec {
    return {
        rect.right - rect.left,
        rect.bottom - rect.top,
    }
}

rect_position :: proc(rect: Rect) -> Vec {
    return {
        rect.left,
        rect.top,
    }
}

quad_size :: proc(quad: Quad) -> Vec {
    return {
        quad.right + quad.left,
        quad.bottom + quad.top,
    }
}
