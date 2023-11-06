
package x11

/*
    Helper type to initialize window attributes.
*/
Window_Attributes_Set :: struct {
    set: X_Set_Window_Attributes,
    mask: X_Attribute_Mask,
}

attribute_back_pixmap :: proc(wa: ^Window_Attributes_Set, pixmap: Pixmap) -> ^Window_Attributes_Set {
    wa.mask |= {.Back_Pixmap}
    wa.set.back_pixmap = pixmap
    return wa
}

attribute_back_pixel :: proc(wa: ^Window_Attributes_Set, pixel: uint) -> ^Window_Attributes_Set {
    wa.mask |= {.Back_Pixel}
    wa.set.back_pixel = pixel
    return wa
}

attribute_border_pixmap :: proc(wa: ^Window_Attributes_Set, pixmap: Pixmap) -> ^Window_Attributes_Set {
    wa.mask |= {.Border_Pixmap}
    wa.set.border_pixmap = pixmap
    return wa
}

attribute_border_pixel :: proc(wa: ^Window_Attributes_Set, pixel: uint) -> ^Window_Attributes_Set {
    wa.mask |= {.Border_Pixel}
    wa.set.border_pixel = pixel
    return wa
}

attribute_bit_gravity :: proc(wa: ^Window_Attributes_Set, gravity: Gravity) -> ^Window_Attributes_Set {
    wa.mask |= {.Bit_Gravity}
    wa.set.bit_gravity = gravity
    return wa
}

attribute_win_gravity :: proc(wa: ^Window_Attributes_Set, gravity: Gravity) -> ^Window_Attributes_Set {
    wa.mask |= {.Win_Gravity}
    wa.set.win_gravity = gravity
    return wa
}

attribute_backing_store :: proc(wa: ^Window_Attributes_Set, store: Backing_Store) -> ^Window_Attributes_Set {
    wa.mask |= {.Backing_Store}
    wa.set.backing_store = store
    return wa
}

attribute_backing_planes :: proc(wa: ^Window_Attributes_Set, planes: uint) -> ^Window_Attributes_Set {
    wa.mask |= {.Backing_Planes}
    wa.set.backing_planes = planes
    return wa
}

attribute_backing_pixel :: proc(wa: ^Window_Attributes_Set, pixel: uint) -> ^Window_Attributes_Set {
    wa.mask |= {.Backing_Pixel}
    wa.set.backing_pixel = pixel
    return wa
}

attribute_save_under :: proc(wa: ^Window_Attributes_Set, save_under: bool) -> ^Window_Attributes_Set {
    wa.mask |= {.Save_Under}
    wa.set.save_under = cast(b32) save_under
    return wa
}

attribute_event_mask :: proc(wa: ^Window_Attributes_Set, event_mask: Event_Mask) -> ^Window_Attributes_Set {
    wa.mask |= {.Event_Mask}
    wa.set.event_mask = event_mask
    return wa
}

attribute_dont_propagate :: proc(wa: ^Window_Attributes_Set, dont_propagate: Event_Mask) -> ^Window_Attributes_Set {
    wa.mask |= {.Dont_Propagate}
    wa.set.dont_propagate = dont_propagate
    return wa
}

attribute_override_redirect :: proc(wa: ^Window_Attributes_Set, override_redirect: bool) -> ^Window_Attributes_Set {
    wa.mask |= {.Override_Redirect}
    wa.set.override_redirect = cast(b32) override_redirect
    return wa
}

attribute_colormap :: proc(wa: ^Window_Attributes_Set, colormap: Colormap) -> ^Window_Attributes_Set {
    wa.mask |= {.Colormap}
    wa.set.colormap = colormap
    return wa
}

attribute_cursor :: proc(wa: ^Window_Attributes_Set, cursor: Cursor) -> ^Window_Attributes_Set {
    wa.mask |= {.Cursor}
    wa.set.cursor = cursor
    return wa
}
