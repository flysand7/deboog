
package gui

Vec2i :: [2]int

Rect :: struct {
    l: int,
    t: int,
    r: int,
    b: int,
}

rect_make4 :: proc(l,t,r,b: int) -> Rect {
    rect: Rect
    rect.l = l
    rect.t = t
    rect.r = r
    rect.b = b
    return rect
}

rect_make2 :: proc(tl: Vec2i, br: Vec2i) -> Rect {
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

rect_contains_point :: proc(a: Rect, x, y: int) -> bool {
    if a.l <= x && x < a.r && a.t <= y && y < a.b {
        return true
    }
    return false
}

rect_contains_vec2i :: proc(a: Rect, v: Vec2i) -> bool {
    if a.l <= v.x && v.x < a.r && a.t <= v.y && v.y < a.b {
        return true
    }
    return false
}

rect_contains :: proc {
    rect_contains_point,
    rect_contains_vec2i,
}
