package gui

import "core:log"
import "core:runtime"

import glfw "glfw3"

Window :: struct {
    handle:  ^glfw.Window,
    root:    ^Widget,
    size:    Vec,
    visible: bool,
    focused: bool,
    hovered: bool,
    closing: bool,
    cursor:  Vec,
    wx_pressed: ^Widget,
    wx_hovered: ^Widget,
    wxs_layout: [dynamic]^Widget,
    wxs_paint:  [dynamic]^Widget,
}

// Windowing-library abstractions

@(private="file")
saved_context: runtime.Context // Use for callbacks to get back the context

window_create :: proc(size_x: i32, size_y: i32, title: cstring) -> ^Window {
    glfw.default_window_hints()
    when ODIN_DEBUG {
        glfw.window_hint(.Context_Debug)
    }
    // Doesn't work with all window managers.
    glfw.window_hint(.Floating, true)
    // If you want your window to be floating by default you should set it up with your window
    // manager to display windows with "floating" class name as floating. It doesn't work by default
    glfw.window_hint(.X11_Instance_Name, "pesticider")
    glfw.window_hint(.X11_Class_Name, "floating")
    glfw.window_hint(.Context_Version_Major, 3)
    glfw.window_hint(.Context_Version_Minor, 3)
    glfw.window_hint(.OpenGL_Profile, glfw.OpenGL_Profile.Core_Profile)
    handle := glfw.create_window(
        size_x,
        size_y,
        title,
    )
    if handle == nil {
        log.fatalf("Unable to create a window.")
    }
    glfw.set_window_iconify_callback(handle, glfw_window_iconify_callback)
    glfw.set_window_focus_callback(handle, glfw_focus_callback)
    glfw.set_cursor_enter_callback(handle, glfw_cursor_enter_callback)
    glfw.set_framebuffer_size_callback(handle, glfw_framebuffer_size_callback)
    glfw.set_key_callback(handle, glfw_key_callback)
    glfw.set_mouse_button_callback(handle, glfw_mouse_button_callback)
    glfw.set_cursor_pos_callback(handle, glfw_cursor_pos_callback)
    glfw.set_scroll_callback(handle, glfw_scroll_callback)
    glfw.set_drop_callback(handle, glfw_drop_callback)
    glfw.set_window_close_callback(handle, glfw_window_close_callback)
    window := new(Window)
    window.handle = handle
    if g.root_window == nil {
        g.root_window = window
    }
    append(&g.windows, window)
    glfw.set_window_user_pointer(handle, window)
    return window
}

@(private)
window_destroy :: proc(window: ^Window) {
    glfw.destroy_window(window.handle)
}

@(private)
should_close :: proc() -> bool {
    return cast(bool) glfw.window_should_close(g.root_window.handle)
}

@(private)
windows_init :: proc() {
    saved_context = context
    major, minor, patch := glfw.get_version()
    log.infof("GLFW binary version: %d.%d.%d", major, minor, patch)
    glfw.set_error_callback(glfw_error_callback)
    glfw.init()
}

@(private)
windows_fini :: proc() {
    glfw.terminate()
    g.root_window = nil
}

@(private)
windows_wait_events :: proc() {
    glfw.wait_events()
}

@(private)
windows_wait_events_timeout :: proc(timeout: f64) {
    glfw.wait_events_timeout(timeout)
}

@(private)
get_time :: proc() -> f64 {
    return glfw.get_time()
}

// Glfw-specific functions

@(private="file")
glfw_error_callback :: proc "c" (code: glfw.Error, description: cstring) {
    context = saved_context
    log.errorf("GLFW Error %v: %s", code, description)
}

@(private="file")
glfw_window_iconify_callback :: proc "c" (handle: ^glfw.Window, iconified: b32) {
    window := cast(^Window) glfw.get_window_user_pointer(handle)
    window.visible = !iconified
}

@(private="file")
glfw_focus_callback :: proc "c" (handle: ^glfw.Window, focused: b32) {
    window := cast(^Window) glfw.get_window_user_pointer(handle)
    window.focused = cast(bool) focused
}

@(private="file")
glfw_cursor_enter_callback :: proc "c" (handle: ^glfw.Window, entered: b32) {
    window := cast(^Window) glfw.get_window_user_pointer(handle)
    window.hovered = !! entered
}

@(private="file")
glfw_framebuffer_size_callback :: proc "c" (handle: ^glfw.Window, size_x: i32, size_y: i32) {
    context = saved_context
    window := cast(^Window) glfw.get_window_user_pointer(handle)
    window.size = {
        cast(f32) size_x,
        cast(f32) size_y,
    }
    push_window_event(window, Event_Size {
        size = {
            cast(f32) size_x,
            cast(f32) size_y,
        },
    })
}

@(private="file")
glfw_key_callback :: proc "c" (
    handle: ^glfw.Window,
    key: glfw.Key,
    scan: i32,
    action: glfw.Action,
    mods: glfw.Mod,
) {
    _ = cast(^Window) glfw.get_window_user_pointer(handle)
    // Do nothing for now.
}

@(private="file")
glfw_mouse_button_callback :: proc "c" (
    handle: ^glfw.Window,
    button: glfw.Mouse_Button,
    action: glfw.Action,
    mods: glfw.Mod,
) {
    context = saved_context
    window := cast(^Window) glfw.get_window_user_pointer(handle)
    conv_action: Action
    conv_button: Mouse_Button
    #partial switch action {
    case .Press:   conv_action = .Press
    case .Release: conv_action = .Release
    case: return
    }
    #partial switch button {
    case .Left:    conv_button = .Left
    case .Middle:  conv_button = .Mid
    case .Right:   conv_button = .Right
    case .Button4: conv_button = .Mouse4
    case .Button5: conv_button = .Mouse5
    case: return
    }
    push_window_event(window, Event_Press {
        action = conv_action,
        button = conv_button,
    })
}

@(private="file")
glfw_cursor_pos_callback :: proc "c" (handle: ^glfw.Window, pos_x: f64, pos_y: f64) {
    context = saved_context
    window := cast(^Window) glfw.get_window_user_pointer(handle)
    push_window_event(window, Event_Move {
        pos = {
            cast(f32) pos_x,
            cast(f32) pos_y,
        },
    })
}

@(private="file")
glfw_scroll_callback :: proc "c" (handle: ^glfw.Window, scroll_x: f64, scroll_y: f64) {
    context = saved_context
    window := cast(^Window) glfw.get_window_user_pointer(handle)
    push_window_event(window, Event_Scroll {
        scroll = {
            cast(f32) scroll_x,
            cast(f32) scroll_y,
        },
    })
}

@(private="file")
glfw_drop_callback :: proc "c" (handle: ^glfw.Window, path_count: i32, paths: [^]cstring) {
    _ = cast(^Window) glfw.get_window_user_pointer(handle)
    _ = paths[:path_count]
}

@(private="file")
glfw_window_close_callback :: proc "c" (handle: ^glfw.Window) {
    window := cast(^Window) glfw.get_window_user_pointer(handle)
    window.closing = true
}
