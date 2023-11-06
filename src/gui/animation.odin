
package gui

import math "core:math"
import math_ease "core:math/ease"
import "core:time"

Ease_Fn :: math_ease.Ease

animations_scalar: [dynamic]Scalar_Animation
animations_color:  [dynamic]Color_Animation

/*
    These represent handles to the properties that may be animated.
    If `animation_id` is negative, that means no animation is taking
    place. This value is used by the animation engine to figure out
    whether a new animation needs to be created or an existing one
    can be re-used.
*/
Scalar_Property :: struct {
    owner:        ^Element,
    animation_id: int,
    value:        int,
}

Color_Property :: struct {
    owner:        ^Element,
    animation_id: int,
    value:        u32,
}

/*
    These animation descriptors define what needs to be animated and how
    it needs to be animated.
*/
Scalar_Animation :: struct {
    property: ^Scalar_Property,
    ease_fn:  Ease_Fn,
    progress: f32,
    duration: f32,
    start:    f32,
    final:    f32,
}

Color_Animation :: struct {
    property: ^Color_Property,
    ease_fn:  Ease_Fn,
    progress: f32,
    duration: f32,
    start:    [3]f32,
    final:    [3]f32,
}

scalar_property :: proc(owner: ^Element, value: int) -> Scalar_Property {
    return Scalar_Property {
        owner = owner,
        value = value,
        animation_id = -1,
    }
}

color_property :: proc(owner: ^Element, value: u32) -> Color_Property {
    return Color_Property {
        owner = owner,
        value = value,
        animation_id = -1,
    }
}

animate_scalar :: proc(property: ^Scalar_Property,
    final: int, duration: time.Duration, ease_fn := Ease_Fn.Cubic_In_Out)
{
    if property.animation_id >= 0 {
        animation := &animations_scalar[property.animation_id]
        animation.ease_fn = ease_fn
        animation.progress = 0
        animation.duration = cast(f32) duration
        animation.start = cast(f32) property.value
        animation.final = cast(f32) final
    } else {
        property.animation_id = len(animations_scalar)
        append(&animations_scalar, Scalar_Animation {
            property = property,
            ease_fn  = ease_fn,
            progress = 0,
            duration = cast(f32) duration,
            start    = cast(f32) property.value,
            final    = cast(f32) final,
        })
    }
}

animate_color :: proc(property: ^Color_Property,
    final: u32, duration: time.Duration, ease_fn := Ease_Fn.Cubic_In_Out)
{
    if property.animation_id >= 0 {
        // Another animation in-progress, just overwrite it.
        animation := &animations_color[property.animation_id]
        animation.ease_fn = ease_fn
        animation.progress = 0
        animation.duration = cast(f32) duration
        animation.start = ciexyz_from_u32(property.value)
        animation.final = ciexyz_from_u32(final)
    } else {
        animation := Color_Animation {
            property = property,
            ease_fn  = ease_fn,
            progress = 0,
            duration = cast(f32) duration,
            start    = ciexyz_from_u32(property.value),
            final    = ciexyz_from_u32(final),
        }
        property.animation_id = len(animations_color)
        append(&animations_color, animation)
    }
}

@(private)
animation_tick :: proc(dt: time.Duration) -> bool {
    something_got_animated := false
    for idx := 0; idx < len(animations_scalar); idx += 1 {
        animation := &animations_scalar[idx]
        property := animation.property
        t := animation.progress / animation.duration
        if t >= 1 {
            // Animation completed, let's delete it!
            property.animation_id = -1
            unordered_remove(&animations_scalar, idx)
            idx -= 1
            continue
        }
        animation.progress += cast(f32) dt
        property.value = interp_scalar(animation.start, animation.final, t, animation.ease_fn)
        element_repaint(property.owner)
        something_got_animated = true
    }
    for idx := 0; idx < len(animations_color); idx += 1 {
        animation := &animations_color[idx]
        property := animation.property
        t := animation.progress / animation.duration
        if t >= 1 {
            property.animation_id = -1
            unordered_remove(&animations_color, idx)
            idx -= 1
            continue
        }
        animation.progress += cast(f32) dt
        property.value = interp_color(animation.start, animation.final, t, animation.ease_fn)
        element_repaint(property.owner)
        something_got_animated = true
    }
    return something_got_animated
}

@(private)
interp_scalar :: proc(start, end: f32, t: f32, ease_fn: Ease_Fn) -> int {
    t1 := math_ease.ease(ease_fn, t)
    return cast(int) math.round((1-t1)*start + t*end)
}

@(private)
interp_color :: proc(start, end: [3]f32, t: f32, ease_fn: Ease_Fn) -> u32 {
    t1 := math_ease.ease(ease_fn, t)
    xyz := (1-t1)*start + t*end
    return u32_from_ciexyz(xyz)
}

@(private)
ciexyz_from_u32 :: proc(color: u32) -> [3]f32 {
    // Part 1: sRGB -> XYZ
    r := (cast(f32) ((color >> 16) & 0xff)) / 255.0
    g := (cast(f32) ((color >> 8) & 0xff)) / 255.0
    b := (cast(f32) ((color) & 0xff)) / 255.0
    if r > 0.04045 {
        r = math.pow((r + 0.055) / 1.055, 2.4)
    } else {
        r = 12.92
    }
    if g > 0.04045 {
        g = math.pow((g + 0.055) / 1.055, 2.4)
    } else {
        g /= 12.92
    }
    if b > 0.04045 {
        b = math.pow((b + 0.055) / 1.055, 2.4)
    } else {
        b /= 12.92
    }
    r *= 100
    g *= 100
    b *= 100
    x := r * 0.4124 + g * 0.3576 + b * 0.1805
    y := r * 0.2126 + g * 0.7152 + b * 0.0722
    z := r * 0.0193 + g * 0.1192 + b * 0.9505
    return [3]f32{x, y, z}
}

@(private)
u32_from_ciexyz :: proc(xyz: [3]f32) -> u32 {
    X := xyz[0] / 100.0
    Y := xyz[1] / 100.0
    Z := xyz[2] / 100.0
    // Part 2: XYZ -> sRGB
    r := X* 3.2406 + Y*-1.5372 + Z*-0.4986
    g := X*-0.9689 + Y* 1.8758 + Z* 0.0415
    b := X* 0.0557 + Y*-0.2040 + Z* 1.0570
    if r > 0.0031308 {
        r = 1.055 * math.pow(r, 1/2.4) - 0.055
    } else {
        r *= 12.92
    }
    if g > 0.0031308 {
        g = 1.055 * math.pow(g, 1/2.4) - 0.055
    } else {
        g *= 12.92
    }
    if b > 0.0031308 {
        b = 1.055 * math.pow(b, 1/2.4) - 0.055
    } else {
        b *= 12.92
    }
    sr := cast(u32) (r * 255) & 0xff
    sg := cast(u32) (g * 255) & 0xff
    sb := cast(u32) (b * 255) & 0xff
    return sb | (sg << 8) | (sr << 16)
}
