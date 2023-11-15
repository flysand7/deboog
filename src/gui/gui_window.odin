
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
    size:     Vec,
    dirty:    Rect,
    cursor:   Vec,
    hovered:  ^Element,
    pressed:  ^Element,
    button:   Mouse_Button,
}

initialize :: proc() {
    _platform_initialize()
}

window_create :: proc(title: cstring, size_x, size_y: int, flags: Element_Flags) -> ^Window {
    return _platform_window_create(title, size_x, size_y, flags)
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
_window_message_proc :: proc(element: ^Element, message: Msg)->int {
    window := cast(^Window) element
    #partial switch msg in message {
        case Msg_Layout:
            if len(window.children) > 0 {
                element_move(window.children[0], window.bounds, false)
                element_repaint(window)
            }
        case:
    }
    return 1
}

@(private)
_window_input_event :: proc(window: ^Window, message: Msg) -> int {
    if window.pressed != nil {
        #partial switch msg in message {
        case Msg_Input_Move:
            element_message(window.pressed, Msg_Input_Drag{})
        case Msg_Input_Click:
            if msg.button == .Left {
                if window.hovered == window.pressed {
                    element_message(window.pressed, Msg_Input_Clicked{})
                }
            }
            element_message(window.pressed, message)
            _window_set_pressed(window, nil, msg.button)
        }
    }
    if window.pressed != nil {
        is_inside := rect_contains(window.pressed.clip, window.cursor.x, window.cursor.y)
        if is_inside && window.hovered == window {
            window.hovered = window.pressed
            element_message(window.pressed, Msg_Input_Hovered{})
        } else if !is_inside && window.hovered == window.pressed {
            window.hovered = window
            element_message(window.pressed, Msg_Input_Hovered{})
        }
    } else {
        hovered := element_find(window, window.cursor.x, window.cursor.y)
        #partial switch msg in message {
        case Msg_Input_Move:
            element_message(hovered, Msg_Input_Move{})
            if hovered != window.hovered {
                prev_hovered := window.hovered
                window.hovered = hovered
                element_message(prev_hovered, Msg_Input_Hovered{})
                element_message(window.hovered, Msg_Input_Hovered{})
            }
        case Msg_Input_Click:
            _window_set_pressed(window, hovered, msg.button)
            element_message(hovered, message)
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
        element_message(previous, Msg_Input_Pressed{})
    }
    if element != nil {
        element_message(element, Msg_Input_Pressed{})
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
        painter.size = window.size
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
