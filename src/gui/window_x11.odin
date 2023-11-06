//+build linux, freebsd, openbsd
package gui

import "x11"

@(private)
_X11_Global :: struct {
    display:   ^x11.Display,
    visual:    ^x11.Visual,
    wm_delete: x11.Atom,
}

@(private)
_X11_Window :: struct {
    handle: x11.Window,
    image: ^x11.Image,
}

@(private)
_x11_initialize :: proc() {
    x11.default_error_handling(.Async_Log_Error)
    global.display,   _ = x11.open_display(nil)
    global.visual,    _ = x11.default_visual(global.display, 0)
    global.wm_delete, _ = x11.intern_atom(global.display, "WM_DELETE_WINDOW", false)
}

@(private)
_x11_window_create :: proc(title: cstring, width, height: int, flags: Element_Flags) -> ^Window {
    window := element_create(nil, Window, flags)
    append(&global.windows, window)
    // Set up the properties of window
    window.width = width
    window.height = height
    window.msg_class = _window_message_proc
    window.window = window
    // Initialize attributes
    window_attr: x11.Window_Attributes_Set
    x11.attribute_override_redirect(&window_attr, false)
    // Get the root window and proceed creating our window
    root_window, _ := x11.default_root_window(global.display)
    window.handle, _ = x11.create_window(
        global.display,
        root_window,
        0, 0, width, height,
        0, 0,
        .Input_Output,
        global.visual,
        &window_attr)
    // Allow the window to be closed
    x11.set_wm_protocols(global.display, window.handle, []x11.Atom{global.wm_delete})
    // Set the window title and mask for events we want to receive
    x11.store_name(global.display, window.handle, title)
    x11.select_input(global.display, window.handle, {
        .Substructure_Notify, .Structure_Notify,
        .Exposure,
        .Pointer_Motion,
        .Button_Press, .Button_Release,
        .Key_Press, .Key_Release,
        .Enter_Window, .Leave_Window,
        .Button_Motion,
        .Keymap_State,
        .Focus_Change,
        .Property_Change,
    })
    // Bring the window to front
    x11.map_raised(global.display, window.handle)
    // Create the backing buffer
    window.image, _ = x11.create_image(
        global.display,
        global.visual,
        24,
        .ZPixmap,
        0,
        nil,
        10, 10,
        32, 0)
    return window
}

@(private)
_x11_message_loop :: proc() {
    for !global.close {
        event: x11.Event
        x11.next_event(global.display, &event)
        _x11_handle_event(event)
    }
}

@(private)
_x11_end_paint :: proc(window: ^Window) {
    gc := x11.default_gc(global.display, 0)
    x11.put_image(global.display, window.handle, gc, window.image,
        window.dirty.l, window.dirty.t,
        window.dirty.l, window.dirty.t,
        window.dirty.r - window.dirty.l, window.dirty.b - window.dirty.t)
}

@(private)
_x11_handle_event :: proc(#by_ptr event: x11.Event) {
    #partial switch event.type {
    case .Client_Message:
        if cast(uint) event.xclient.data.l[0] == global.wm_delete {
            if len(global.windows) > 0 && global.windows[0].handle == event.xclient.window {
                global.close = true
            } else {
                close_window(_x11_find_window(event.xclient.window))
            }
        }
    case .Expose:
        window := _x11_find_window(event.xexpose.window)
        if window == nil {
            return
        }
        gc := x11.default_gc(global.display, 0)
        x11.put_image(global.display, window.handle, gc, window.image,
            0, 0, 0, 0, window.width, window.height)
    case .Configure_Notify:
        window: ^Window = _x11_find_window(event.xconfigure.window)
        if window == nil {
            global.close = true
            return
        }
        new_width := cast(int) event.xconfigure.width
        new_height := cast(int) event.xconfigure.height
        if window.width != new_width || window.height != new_height {
            window.width = new_width
            window.height = new_height
            resize(&window.pixels, new_width * new_height * size_of(u32))
            for &pixel in window.pixels {
                pixel = 0
            }
            window.image.width = cast(i32) new_width
            window.image.height = cast(i32) new_height
            window.image.stride = cast(i32) (new_width * size_of(u32))
            window.image.data = cast([^]u8) raw_data(window.pixels)
            // Set new window bounds and send the Layout message.
            window.bounds = rect_make2({0, 0}, {new_width, new_height})
            window.clip = rect_make2({0, 0}, {new_width, new_height})
            element_message(window, .Layout)
            _update_all()
        }
    case .Motion_Notify:
        window := _x11_find_window(event.xmotion.window)
        if window == nil {
            return
        }
        window.cursor_x = cast(int) event.xmotion.x
        window.cursor_y = cast(int) event.xmotion.y
        _window_input_event(window, .Mouse_Move)
    case .Leave_Notify:
        window := _x11_find_window(event.xmotion.window)
        if window == nil {
            return
        }
        if window.pressed == nil {
            window.cursor_x = -1
            window.cursor_y = -1
        }
        _window_input_event(window, .Mouse_Move)
    case .Button_Press, .Button_Release:
        window := _x11_find_window(event.xbutton.window)
        if window == nil {
            return
        }
        window.cursor_x = cast(int) event.xbutton.x
        window.cursor_y = cast(int) event.xbutton.y
        button := event.xbutton.button
        if event.type == .Button_Press {
            #partial switch button {
                case .Button1: _window_input_event(window, .Mouse_Left_Press)
                case .Button2: _window_input_event(window, .Mouse_Middle_Press)
                case .Button3: _window_input_event(window, .Mouse_Right_Press)
            }
        } else {
            #partial switch button {
                case .Button1: _window_input_event(window, .Mouse_Left_Release)
                case .Button2: _window_input_event(window, .Mouse_Middle_Release)
                case .Button3: _window_input_event(window, .Mouse_Right_Release)
            }
        }
    }
}

_x11_destroy_window :: proc(window: ^Window) {
    x11.destroy_window(global.display, window.handle)
}

@(private)
_x11_find_window :: proc(handle: x11.Window) -> ^Window {
    for w in global.windows {
        if w.handle == handle {
            return w
        }
    }
    return nil
}
