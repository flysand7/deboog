//+build linux, freebsd, openbsd
package gui

import "vendor:x11/xlib"
import "core:time"

@(private)
_X11_Global :: struct {
    display:   ^xlib.Display,
    visual:    ^xlib.Visual,
    root:      xlib.Window,
    wm_delete: xlib.Atom,
}

@(private)
_X11_Window :: struct {
    handle: xlib.Window,
    image: ^xlib.XImage,
}

@(private)
_x11_initialize :: proc() {
    global.display   = xlib.XOpenDisplay(nil)
    global.visual    = xlib.XDefaultVisual(global.display, 0)
    global.wm_delete = xlib.XInternAtom(global.display, "WM_DELETE_WINDOW", false)
}

@(private)
_x11_window_create :: proc(title: cstring, size_x, size_y: int, flags: Element_Flags) -> ^Window {
    window := element_create(nil, Window, flags)
    append(&global.windows, window)
    // Set up the properties of window
    window.size.x = size_x
    window.size.y = size_y
    window.msg_class = _window_message_proc
    window.window = window
    // Initialize attributes
    wattr := xlib.XSetWindowAttributes{}
    wmask := xlib.WindowAttributeMask{}
    wattr.override_redirect = false
    wmask |= {.CWOverrideRedirect}
    // Get the root window and proceed creating our window
    global.root = xlib.XDefaultRootWindow(global.display)
    window.handle = xlib.XCreateWindow(
        global.display,
        global.root,
        0, 0, cast(u32) size_x, cast(u32) size_y,
        0, 0,
        .InputOutput,
        global.visual,
        wmask, &wattr)
    // Allow the window to be closed
    xlib.XSetWMProtocols(global.display, window.handle, &global.wm_delete, 1)
    // Set the window title and mask for events we want to receive
    xlib.XStoreName(global.display, window.handle, title)
    xlib.XSelectInput(global.display, window.handle, {
        .SubstructureNotify, .StructureNotify,
        .Exposure,
        .PointerMotion,
        .ButtonPress, .ButtonRelease,
        .KeyPress, .KeyRelease,
        .EnterWindow, .LeaveWindow,
        .ButtonMotion,
        .KeymapState,
        .FocusChange,
        .PropertyChange,
    })
    // Bring the window to front
    xlib.XMapRaised(global.display, window.handle)
    // Create the backing buffer
    window.image = xlib.XCreateImage(
        global.display,
        global.visual,
        24,
        .ZPixmap,
        0,
        nil,
        10, 10,
        32, 0)
    // Set it to float
    _x11_window_set_floating(window.handle)
    return window
}

ANIMATION_FREQUENCY :: time.Second / cast(time.Duration) 60

@(private)
_x11_message_loop :: proc() {
    animation_counter: time.Duration
    last_frame_time := time.now()
    current_frame_time := time.now()
    for !global.close {
        last_frame_time = current_frame_time
        current_frame_time = time.now()
        animation_counter += time.diff(last_frame_time, current_frame_time)
        event: xlib.XEvent
        for xlib.XPending(global.display) > 0 {
            xlib.XNextEvent(global.display, &event)
            _x11_handle_event(event)
        }
        if animation_counter >= ANIMATION_FREQUENCY {
            if animation_tick(animation_counter) {
                _update_all()
            }
            animation_counter = 0
        }
    }
}

@(private)
_x11_end_paint :: proc(window: ^Window) {
    gc := xlib.XDefaultGC(global.display, 0)
    x := window.dirty.l
    y := window.dirty.t
    w := window.dirty.r - window.dirty.l
    h := window.dirty.b - window.dirty.t
    xlib.XPutImage(
        global.display,
        window.handle,
        gc,
        window.image,
        cast(i32) x, cast(i32) y,
        cast(i32) x, cast(i32) y,
        cast(u32) w, cast(u32) h,
    )
}

@(private)
_x11_handle_event :: proc(#by_ptr event: xlib.XEvent) {
    #partial switch event.type {
    case .ClientMessage:
        if cast(xlib.Atom) event.xclient.data.l[0] == global.wm_delete {
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
        gc := xlib.XDefaultGC(global.display, 0)
        xlib.XPutImage(
            global.display,
            window.handle,
            gc,
            window.image,
            0, 0, 0, 0,
            cast(u32) window.size.x,
            cast(u32) window.size.y,
        )
    case .ConfigureNotify:
        window: ^Window = _x11_find_window(event.xconfigure.window)
        if window == nil {
            global.close = true
            return
        }
        new_size := Vec {
            cast(int) event.xconfigure.width,
            cast(int) event.xconfigure.height,
        }
        if window.size != new_size {
            window.size = new_size
            resize(&window.pixels, new_size.x * new_size.y * size_of(u32))
            for &pixel in window.pixels {
                pixel = 0
            }
            // Create a new canvas for the window to draw on.
            window.image.width = cast(i32) new_size.x
            window.image.height = cast(i32) new_size.y
            window.image.bytes_per_line = cast(i32) (new_size.x * size_of(u32))
            window.image.data = cast([^]u8) raw_data(window.pixels)
            // Set new window bounds and send the Layout message.
            window.bounds = rect_make2({0, 0}, {new_size.x, new_size.y})
            window.clip = rect_make2({0, 0}, {new_size.x, new_size.y})
            element_message(window, Msg_Layout{})
            // Paint all elements on the new canvas.
            _update_all()
        }
    case .MotionNotify:
        window := _x11_find_window(event.xmotion.window)
        if window == nil {
            return
        }
        window.cursor.x = cast(int) event.xmotion.x
        window.cursor.y = cast(int) event.xmotion.y
        _window_input_event(window, Msg_Input_Move{})
    case .LeaveNotify:
        window := _x11_find_window(event.xmotion.window)
        if window == nil {
            return
        }
        if window.pressed == nil {
            window.cursor.x = -1
            window.cursor.y = -1
        }
        _window_input_event(window, Msg_Input_Move{})
    case .ButtonPress, .ButtonRelease:
        window := _x11_find_window(event.xbutton.window)
        if window == nil {
            return
        }
        window.cursor.x = cast(int) event.xbutton.x
        window.cursor.y = cast(int) event.xbutton.y
        button: Mouse_Button
        action: Mouse_Action = event.type == .ButtonPress? .Press : .Release
        #partial switch event.xbutton.button {
            case .Button1: button = .Left
            case .Button2: button = .Middle
            case .Button3: button = .Right
        }
        _window_input_event(window, Msg_Input_Click{
            action = action,
            button = button,
        })
    }
}

_x11_destroy_window :: proc(window: ^Window) {
    xlib.XDestroyWindow(global.display, window.handle)
}

@(private)
_x11_find_window :: proc(handle: xlib.Window) -> ^Window {
    for w in global.windows {
        if w.handle == handle {
            return w
        }
    }
    return nil
}

@(private)
_x11_window_set_floating :: proc(handle: xlib.Window) {
    net_wm_state_add := xlib.Atom(1)
    net_wm_state := xlib.XInternAtom(global.display, "_NET_WM_STATE", false)
    net_wm_state_above := xlib.XInternAtom(global.display, "_NET_WM_STATE_ABOVE", false)
    // Send event to WM to add floating state.
    event := xlib.XEvent{
        xclient = {
            type = .ClientMessage,
            window = handle,
            format = 32,
            message_type = net_wm_state,
            data = {
                l = {
                    cast(int) net_wm_state_add,
                    cast(int) net_wm_state_above,
                    0,
                    1,
                    0,
                },
            },
        },
    }
    event_mask: xlib.EventMask = {
        .SubstructureNotify,
        .SubstructureRedirect,
    }
    xlib.XSendEvent(global.display, global.root, false, event_mask, &event)
}
