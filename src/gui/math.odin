package gui

import "core:math"

Vec :: [2]f32

Rect :: struct {
    l: f32,
    t: f32,
    r: f32,
    b: f32,
}

/*
    A 4-tuple of elements. Used for size-properties along
    all 4 sides of the rectangle, like padding, margins etc.
    It's different from a rectangle because the width of
    rectangle is (end - start), but here we calculate it as
    (start + end)
*/
Quad :: struct {
    l: f32,
    t: f32,
    r: f32,
    b: f32,
}

rect_make4 :: proc(l,t,r,b: f32) -> Rect {
    rect: Rect
    rect.l = l
    rect.t = t
    rect.r = r
    rect.b = b
    return rect
}

rect_make2 :: proc(tl: Vec, br: Vec) -> Rect {
    rect: Rect
    rect.l = tl.x
    rect.t = tl.y
    rect.r = br.x
    rect.b = br.y
    return rect
}

rect_make :: proc {
    rect_make4,
    rect_make2,
}

rect_valid :: proc(rect: Rect)->bool {
    if rect.l < rect.r && rect.t < rect.b {
        return true
    }
    return false
}

rect_intersect :: proc(a, b: Rect) -> Rect {
    rect: Rect = ---
    rect.l = max(a.l, b.l)
    rect.r = min(a.r, b.r)
    rect.t = max(a.t, b.t)
    rect.b = min(a.b, b.b)
    return rect
}

rect_union :: proc(a, b: Rect) -> Rect {
    rect: Rect = ---
    rect.l = min(a.l, b.l)
    rect.r = max(a.r, b.r)
    rect.t = min(a.t, b.t)
    rect.b = max(a.b, b.b)
    return rect
}

rect_equals :: proc(a, b: Rect) -> bool {
    if a.l == b.l && a.r == b.r && a.t == b.t && a.b == b.b {
        return true
    }
    return false
}

rect_contains_point :: proc(a: Rect, x, y: f32) -> bool {
    if a.l <= x && x < a.r && a.t <= y && y < a.b {
        return true
    }
    return false
}

rect_contains_vec2i :: proc(a: Rect, v: Vec) -> bool {
    if a.l <= v.x && v.x < a.r && a.t <= v.y && v.y < a.b {
        return true
    }
    return false
}

rect_contains :: proc {
    rect_contains_point,
    rect_contains_vec2i,
}

rect_l :: proc(r: Rect) -> f32 {
    return r.l
}

rect_t :: proc(r: Rect) -> f32 {
    return r.t
}

rect_r :: proc(r: Rect) -> f32 {
    return r.r
}

rect_b :: proc(r: Rect) -> f32 {
    return r.b
}

rect_size_x :: proc(r: Rect) -> f32 {
    return r.r - r.l
}

rect_size_y :: proc(r: Rect) -> f32 {
    return r.b - r.t
}

rect_size :: proc(r: Rect) -> Vec {
    return Vec {
        r.r - r.l,
        r.b - r.t,
    }
}

rect_round :: proc(r: Rect) -> Rect {
    return Rect {
        math.round(r.l),
        math.round(r.t),
        math.round(r.r),
        math.round(r.b),
    }
}

quad_make4 :: proc(l: f32, t: f32, r: f32, b: f32) -> Quad {
    return Quad {
        l = l,
        t = t,
        r = r,
        b = b,
    }
}

quad_make2 :: proc(x: f32, y: f32) -> Quad {
    return Quad {
        l = x,
        t = y,
        r = x,
        b = y,
    }
}

quad_make1 :: proc(a: f32) -> Quad {
    return Quad {
        l = a,
        r = a,
        t = a,
        b = a,
    }
}

quad_make :: proc {
    quad_make4,
    quad_make2,
    quad_make1,
}

quad_l :: proc(q: Quad) -> f32 {
    return q.l
}

quad_r :: proc(q: Quad) -> f32 {
    return q.r
}

quad_t :: proc(q: Quad) -> f32 {
    return q.t
}

quad_b :: proc(q: Quad) -> f32 {
    return q.b
}

quad_size_x :: proc(q: Quad) -> f32 {
    return q.l + q.r
}

quad_size_y :: proc(q: Quad) -> f32 {
    return q.t + q.b
}

quad_size :: proc(q: Quad) -> Vec {
    return {
        q.l + q.r,
        q.t + q.b,
    }
}

quad_round :: proc(q: Quad) -> Quad {
    return Quad {
        math.round(q.l),
        math.round(q.t),
        math.round(q.r),
        math.round(q.b),
    }
}