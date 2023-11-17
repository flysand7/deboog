
package gui

import math "core:math"
import math_ease "core:math/ease"
import "core:intrinsics"
import "core:time"

Ease_Fn :: math_ease.Ease

@(private="file") animations_scalar: [dynamic]Animation(int)
@(private="file") animations_color:  [dynamic]Animation(u32)

/*
    This is the data used by the animation engine to manage the animations.
    
    First, it needs to know which element to signal when its properties are
    being updated. Of course this makes the assumption that properties are
    not shared between the elements.
    
    Secondly, it needs to know whether the property is already being animated.
    If it is being animated, we can find it in the list of animations and
    reschedule the animation from there. Otherwise we need to create a new
    animation.
    
    The third thing it needs is the in-flight value that will be used by
    the components for various reasons like painting themselves.
*/
@(private="file")
Property :: struct($T: typeid) {
    owner:        ^Element,
    animation_id: int,
    value:        T,
}

Scalar_Property :: Property(int)
Color_Property  :: Property(u32)

/*
    This animation descriptor defines what needs to be animated and how
    it needs to be animated.
    
    Animation has two polymorphic types attached to it: one for the type
    of the property it animates and the other for the animation state.
*/
Animation :: struct($T: typeid) {
    property: ^Property(T),
    ease_fn:  Ease_Fn,
    progress: f32,
    duration: f32,
    start:    T,
    final:    T,
}

scalar_property :: proc(owner: ^Element, value: int) -> Scalar_Property {
    return Scalar_Property {
        owner = owner,
        animation_id = -1,
        value = value,
    }
}

property_animation_target :: proc(property: Property($T)) -> (T, bool) {
    if property.animation_id == -1 {
        return 0, false
    }
    animations := animation_array_for_property(type_of(property), T)
    animation := &(animations^)[property.animation_id]
    return animation.final, true
}

color_property :: proc(owner: ^Element, value: u32) -> Color_Property {
    return Color_Property {
        owner = owner,
        animation_id = -1,
        value = value,
    }    
}

animate :: proc(property: ^Property($T), final: T, duration: time.Duration, ease_fn := Ease_Fn.Cubic_In_Out) {
    animations := animation_array_for_property(type_of(property^), T)
    if property.animation_id >= 0 {
        animation := &(animations^)[property.animation_id]
        animation.ease_fn = ease_fn
        animation.progress = 0
        animation.duration = f32(duration) / f32(time.Second)
        animation.start = property.value
        animation.final = final
    } else {
        property.animation_id = len(animations^)
        append(animations, Animation(T) {
            property = property,
            ease_fn  = ease_fn,
            progress = 0,
            duration = f32(duration) / f32(time.Second),
            start    = property.value,
            final    = final,
        })
    }
}

@(private)
animation_tick :: proc(dt: time.Duration) -> bool {
    animated := false
    animated ||= animation_tick_for(Scalar_Property, int, dt)
    animated ||= animation_tick_for(Color_Property, u32, dt)
    return animated
}

@(private="file")
animation_tick_for :: #force_inline proc($P: typeid, $T: typeid, dt: time.Duration)->bool {
    animations := animation_array_for_property(P, T)
    something_got_animated := false
    for idx := 0; idx < len(animations^); idx += 1 {
        animation := &animations[idx]
        property := animation.property
        t := animation.progress / animation.duration
        if t >= 1 {
            // Animation completed, let's delete it!
            property.animation_id = -1
            unordered_remove(animations, idx)
            idx -= 1
            continue
        }
        animation.progress += cast(f32) dt / f32(time.Second)
        when P == Scalar_Property {
            property.value = interp_scalar(animation.start, animation.final, t, animation.ease_fn)
        } else when P == Color_Property {
            property.value = interp_color(animation.start, animation.final, t, animation.ease_fn)
        } else {
            #panic("Unknown property type")
        }
        element_repaint(property.owner)
        element_message(property.owner, Msg_Animation_Notify{property = property})
        something_got_animated = true
    }
    return something_got_animated
}

@(private="file")
animation_array_for_property :: #force_inline proc($P: typeid, $T: typeid) -> ^[dynamic]Animation(T) {
    when P == Scalar_Property {
        return &animations_scalar
    } else when P == Color_Property {
        return &animations_color
    } else {
        #panic("Unknown property type")
    }
}

@(private="file")
interp_scalar :: proc(start, end: int, t: f32, ease_fn: Ease_Fn) -> int {
    start := cast(f32) start
    end   := cast(f32) end
    t1 := math_ease.ease(ease_fn, t)
    return cast(int) math.round((1-t1)*start + t1*end)
}

@(private="file")
interp_color :: proc(start, end: u32, t: f32, ease_fn: Ease_Fn) -> u32 {
    start := ciexyz_from_u32(start)
    end   := ciexyz_from_u32(end)
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
