
package gui

UNIX_GUI_WAYLAND :: #config(UNIX_GUI_WAYLAND, false)
OS_UNIX :: ODIN_OS == .Linux || ODIN_OS == .FreeBSD || ODIN_OS == .OpenBSD

global: Global_State = {}

when OS_UNIX {
    when UNIX_GUI_WAYLAND {
        _Platform_Window :: _Wayland_Window
        _Platform_Global :: _Wayland_Global
    } else {
        _Platform_Window :: _X11_Window
        _Platform_Global :: _X11_Global
    }
} else {
    _Platform_Window :: _Win32_Window
    _Platform_Global :: _Win32_Global
}

Global_State :: struct {
    using _: _Platform_Global,
    windows: [dynamic]^Window,
    close:   bool,
}

Window :: struct {
    using element: Element,
    using _:  _Platform_Window,
    pixels:   [dynamic]u32,
    width:    int,
    height:   int,
    dirty:    Rect,
    cursor_x: int,
    cursor_y: int,
    hovered:  ^Element,
    pressed:  ^Element,
    button:   Mouse_Button,
}

Mouse_Button :: enum {
    Left,
    Middle,
    Right,
}

initialize :: proc() {
    _platform_initialize()
}

window_create :: proc(title: cstring, width, height: int, flags: Element_Flags) -> ^Window {
    return _platform_window_create(title, width, height, flags)
}

message_loop :: proc() {
    _platform_message_loop()
}

close_window :: proc(window: ^Window) {
    if window == nil {
        return
    }
    when OS_UNIX {
        when UNIX_GUI_WAYLAND {
            _wayland_destroy_window(window)
        } else {
            _x11_destroy_window(window)
        }
    } else {
        _win32_destroy_window(window)
    }
    found_idx := -1
    for w, i in global.windows {
        if w == window {
            found_idx = i
        }
    }
    assert(found_idx != -1, "Closing window that doesn't exist!")
    free(global.windows[found_idx])
    unordered_remove(&global.windows, found_idx)
}

@(private)
_window_message_proc :: proc(element: ^Element, message: Message, di: int, dp: rawptr)->int {
    window := cast(^Window) element
    #partial switch message {
        case .Layout:
            if len(window.children) > 0 {
                element_move(window.children[0], window.bounds, false)
                element_repaint(window)
            }
        case:
    }
    return 1
}

@(private)
_window_input_event :: proc(window: ^Window, message: Message, di: int = 0, dp: rawptr = nil) -> int {
    if window.pressed != nil {
        if message == .Mouse_Move {
            element_message(window.pressed, .Mouse_Drag, di, dp)
        } else if message == .Mouse_Left_Release {
            if window.hovered == window.pressed {
                element_message(window.pressed, .Mouse_Clicked, di, dp)
            }
            element_message(window.pressed, message, di, dp)
            _window_set_pressed(window, nil, .Left)
        } else if message == .Mouse_Middle_Release {
            element_message(window.pressed, message, di, dp)
            _window_set_pressed(window, nil, .Middle)
        } else if message == .Mouse_Right_Release {
            element_message(window.pressed, message, di, dp)
            _window_set_pressed(window, nil, .Right)
        }
    }
    if window.pressed != nil {
        is_inside := rect_contains(window.pressed.clip, window.cursor_x, window.cursor_y)
        if is_inside && window.hovered == window {
            window.hovered = window.pressed
            element_message(window.pressed, .Update, cast(int) Update_Kind.Hovered)
        } else if !is_inside && window.hovered == window.pressed {
            window.hovered = window
            element_message(window.pressed, .Update, cast(int) Update_Kind.Hovered)
        }
    } else {
        hovered := element_find(window, window.cursor_x, window.cursor_y)
        if message == .Mouse_Move {
            element_message(hovered, .Mouse_Move)
        } else if message == .Mouse_Left_Press {
            _window_set_pressed(window, hovered, .Left)
            element_message(hovered, message, di, dp)
        } else if message == .Mouse_Middle_Press {
            _window_set_pressed(window, hovered, .Right)
            element_message(hovered, message, di, dp)
        } else if message == .Mouse_Right_Press {
            _window_set_pressed(window, hovered, .Middle)
            element_message(hovered, message, di, dp)
        }
        if hovered != window.hovered {
            prev_hovered := window.hovered
            window.hovered = hovered
            element_message(prev_hovered, .Update, cast(int) Update_Kind.Hovered)
            element_message(window.hovered, .Update, cast(int) Update_Kind.Hovered)
        }
    }
    _update_all()
    return 1
}

@(private)
_window_set_pressed :: proc(window: ^Window, element: ^Element, button: Mouse_Button) {
    previous := window.pressed
    window.pressed = element
    window.button = button
    if previous != nil {
        element_message(previous, .Update, cast(int) Update_Kind.Pressed)
    }
    if element != nil {
        element_message(element, .Update, cast(int) Update_Kind.Pressed)
    }
}

@(private)
_update_all :: proc() {
    for idx := 0; idx < len(global.windows); idx += 1 {
        window := global.windows[idx]
        if _element_destroy_now(window) {
            unordered_remove(&global.windows, idx)
            idx -= 1
        }
        if !rect_valid(window.dirty) {
            continue
        }
        painter: Painter
        painter.width = window.width
        painter.height = window.height
        painter.pixels = cast([^]u32) raw_data(window.pixels)
        painter.clip = rect_intersect(window.bounds, window.dirty)
        _element_paint(window, &painter)
        _platform_end_paint(window)
        window.dirty = rect_make({}, {})
    }
}


@(private)
_platform_initialize :: proc() {
    when OS_UNIX {
        when UNIX_GUI_WAYLAND {
            _wayland_initialize()
        } else {
            _x11_initialize()
        }
    } else when ODIN_OS == .windows {
        _win32_initialize()
    }
}

@(private)
_platform_window_create :: proc(title: cstring, width, height: int, flags: Element_Flags) -> ^Window {
    when OS_UNIX {
        when UNIX_GUI_WAYLAND {
            return _wayland_window_create(title, width, height, flags)
        } else {
            return _x11_window_create(title, width, height, flags)
        }
    } else {
        return _win32_window_create(title, width, height, flags)
    }
}

@(private)
_platform_message_loop :: proc() {
    when OS_UNIX {
        when UNIX_GUI_WAYLAND {
            _wayland_message_loop()
        } else {
            _x11_message_loop()
        }
    } else {
        _win32_message_loop()
    }
}

@(private)
_platform_end_paint :: proc(window: ^Window) {
    when OS_UNIX {
        when UNIX_GUI_WAYLAND {
            _wayland_end_paint(window)
        } else {
            _x11_end_paint(window)
        }
    } else {
        _win32_end_paint(window)
    }
}