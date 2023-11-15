
package gui

Vec2i :: [2]int

/*
    Type for storing rectangles.
*/
Rect :: struct {
    l: int,
    t: int,
    r: int,
    b: int,
}

/*
    A 4-tuple of elements. Used for size-properties along
    all 4 sides of the rectangle, like padding, margins etc.
    It's different from a rectangle because the width of
    rectangle is (end - start), but here we calculate it as
    (start + end)
*/
Quad :: struct {
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

quad_make4 :: proc(l: int, r: int, t: int, b: int) -> Quad {
    return Quad {
        l = l,
        r = r,
        t = t,
        b = b,
    }
}

quad_make2 :: proc(x: int, y: int) -> Quad {
    return Quad {
        l = x,
        r = x,
        t = x,
        b = x,
    }
}

quad_make1 :: proc(a: int) -> Quad {
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

quad_size_x :: proc(q: Quad) -> int {
    return q.l + q.r
}

quad_size_y :: proc(q: Quad) -> int {
    return q.t + q.b
}

quad_size :: proc(q: Quad) -> Vec2i {
    return {
        q.l + q.r,
        q.t + q.b,
    }
}
