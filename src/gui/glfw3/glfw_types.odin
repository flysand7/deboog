package glfw

/*
    Client API function pointer type.
    @(since=3.0)
*/
GL_Proc :: #type proc "c" ()

/*
    Vulkan API function pointer type.
    @(since=3.2)
*/
VK_Proc :: #type proc "c" ()

/*
    Opaque monitor object.
    @(since=3.0)
*/
Monitor :: struct {}

/*
    Opaque window object.
    @(since=3.0)
*/
Window  :: struct {}

/*
    Opaque cursor object.
    @(since=3.1)
*/
Cursor  :: struct {}

/*
    The function pointer type for error callbacks.

    @(lifetimes)
    The description string is valid until the callback returns.

    @(since=3.0)
*/
Error_Proc :: #type proc "c" (code: Error, description: cstring)

/*
    @(since=3.0)
    The function pointer type for window position callbacks.

    @(params)
    - window: The window that has moved.
    - pos_x: The new x-coordinate, in screen space, of the upper-left corner of the content area.
    - pos_y: The new y-coordinate, in screen space, of the upper-left corner of the content area.
*/
Window_Pos_Proc      :: #type proc "c" (window: ^Window, pos_x: i32, pos_y: i32)

/*
    The function pointer type for window size callbacks.

    @(params)
    - window: The window that was resized.
    - size_x: The new width, in screen coordinates, of the window.
    - size_y: The new height, in screen coordinates, of the window.
    
    @(since=1.0)
*/
Window_Size_Proc     :: #type proc "c" (window: ^Window, size_x: i32, size_y: i32)

/*
    The function pointer type for close callbacks.

    @(params)
    - window: The window that the user attempted to close.

    @(since=2.5)
*/
Window_Close_Proc    :: #type proc "c" (window: ^Window)

/*
    The function pointer type for window content refresh callbacks.
    
    @(params)
    - window: The window whose contents need to be refreshed.

    @(since=2.5)
*/
Window_Refresh_Proc  :: #type proc "c" (window: ^Window)

/*
    The function pointer type for window focus change callbacks.
    
    @(params)
    - window: The window which has gained or lost focus.
    - `focused`: `true` if the window gained focus, `false` if the window lost focus.
    
    @(since=3.0)
*/
Window_Focus_Proc    :: #type proc "c" (window: ^Window, focused: b32)

/*
    The function pointer type for window iconify callbacks.
    
    @(params)
    - window: The window which was iconified (minimized) or restored.
    - iconified: `true` if the window was iconified, `false` if it was restored.
    
    @(since=3.0)
*/
Window_Iconify_Proc  :: #type proc "c" (window: ^Window, iconified: b32)

/*
    @(since=3.0)
    The function pointer type for window maximize callbacks.
    
    @(params)
    - window: The window which was maximized or restored.
    - maximized: `true` if the window was maximized, `false` if it was restored.
*/
Window_Maximize_Proc :: #type proc "c" (window: ^Window, maximized: b32)

/*
    The function pointer type for framebuffer resize callbacks.
    
    @(params)
    - window: The window whose framebuffer was resized.
    - size_x: The new width, in pixels, of the new framebuffer.
    - size_y: The new height, in pixels, of the new framebuffer.
    
    @(since=3.0)
*/
Framebuffer_Size_Proc     :: #type proc "c" (window: ^Window, size_x: i32, size_y: i32)

/*
    The function pointer type for content scale callbacks.
    
    @(params)
    - window: The window whose content scale changed.
    - scale_x: The new x-axis content scale of the window.
    - scale_y: The new y-axis content scale of the window.
    
    @(since=3.3)
*/
Window_Content_Scale_Proc :: #type proc "c" (window: ^Window, scale_x: f32, scale_y: f32)

/*
    The function pointer type for mouse button callbacks.
    
    @(params)
    - window: The window that received the event.
    - button: The mouse button that was pressed/released
    - action: One of @(ref=Action.Press), @(ref=Action.Release).
    - mods: Bitset describing which modifier keys were held.
    
    @(since=1.0)
*/
Mouse_Button_Proc :: #type proc "c" (window: ^Window, button: Mouse_Button, action: Action, mods: Mod)

/*
    The function pointer type for cursor position callbacks.
    
    @(params)
    - window: The window that received the event.
    - pos_x: The new x-coordinate of the position of the cursor.
    - pos_y: The new y-coordinate of the position of the cursor.
    
    @(since=3.0)
*/
Cursor_Pos_Proc   :: #type proc "c" (window: ^Window, pos_x: f64, pos_y: f64)

/*
    The function pointer type for cursor enter/leave callbacks.
    
    @(params)
    - window: The window that received the event.
    - entered: `true` if the cursor has entered the window's content area, `false` if it left it.
    
    @(since=3.0)
*/
Cursor_Enter_Proc :: #type proc "c" (window: ^Window, entered: b32)

/*
    The function pointer type for cursor scroll callbacks.
    
    @(params)
    - window: The window that received the event.
    - offset_x: The scroll offset along the x-axis.
    - offset_y: The scroll offset along the y-axis.
    
    @(since=3.0)
*/
Scroll_Proc       :: #type proc "c" (window: ^Window, offset_x: f64, offset_y: f64)

/*
    The function pointer type for keyboard key callbacks.
    
    @(params)
    - window: The window that received the event.
    - key: The keyboard key that was pressed or released
    - scan: Platform-specific scancode of the key
    - action: One of @(ref=Action.Press), @(ref=Action.Release), @(ref=Action.Repeat).
    
    @(since=1.0)
*/
Key_Proc          :: #type proc "c" (window: ^Window, key: Key, scan: i32, action: Action, mods: Mod)

/*
    The function pointer type for Unicode character callbacks.
    
    @(params)
    - window: The window that received the event.
    - codepoint: The Unicode code point of the character.
    
    @(since=2.4)
*/
Char_Proc         :: #type proc "c" (window: ^Window, codepoint: rune)

/*
    The function pointer type for Unicode character input with modifiers callback.
    
    @(params)
    - window: The window that received the event.
    - codepoint: The unicode code point of the character.
    - mods: Bit field describing which modifier keys were pressed.
    
    @(since=3.1)
    @(deprecated="Scheduled for removal in GLFW version 4.0")
*/
Char_Mods_Proc    :: #type proc "c" (window: ^Window, codepoint: rune, mods: Mod)

/*
    The function pointer type for path drop callbacks.
    
    @(params)
    - window: The window that received the event.
    - path_count: The number of dropped path.
    - paths: A list of UTF-8 encoded file and/or directory path names.

    @(since=3.1)
*/
Drop_Proc         :: #type proc "c" (window: ^Window, path_count: i32, paths: [^]cstring)

/*
    The function pointer type for monitor configuration callbacks.
    
    @(params)
    - monitor: The monitor that was connected or disconnected.
    - event: @(ref=Connection_Event.Connected) if the monitor was connected,
        @(ref=Connection_Event.Disconnected) if it was disconnected.

    @(since=3.0)
*/
Monitor_Proc      :: #type proc "c" (monitor: ^Monitor, event: Connection_Event)

/*
    The function pointer type for joystick configuration callbacks.
    
    @(params)
    - jid: The joystick that was connected or disconnected.
    - event: @(ref=Connection_Event.Connected) if the joystick was connected,
        @(ref=Connection_Event.Disconnected) if it was disconnected.

    @(since=3.2)
*/
Joystick_Proc     :: #type proc "c" (jid: i32, event: Connection_Event)

/*
    Describes a single video mode.
    @(since=1.0)
*/
Video_Mode :: struct {
    // The width, in screen coordinates, of the video mode.
    width:        i32,
    // The height, in screen coordinates, of the video mode.
    height:       i32,
    // The bit depth of the red channel of the video mode.
    red_bits:     i32,
    // The bit depth of the green channel of the vidoe mode.
    green_bits:   i32,
    // The bit depth of the blue channel of the video mode.
    blue_bits:    i32,
    // The refresh rate, in hertz, of the video mode.
    refresh_rate: i32,
}

/*
    Describes the gamma ramp for a monitor.
    @(since=3.0)
*/
Gamma_Ramp :: struct {
    // An array of values describing the response of the red channel.
    red:   [^]u16,
    // An array of values describing the response of the green channel.
    green: [^]u16,
    // An array of values describing the response of the blue channel.
    blue:  [^]u16,
    // The number of elements in `red`, `green` and `blue` arrays.
    size:  u32,
}

/*
    Describes a single 2D image. See the documentation of each related function
    to see what the expected pixel format is.
    @(since=2.1)
*/
Image :: struct {
    // The width, in pixels of this image.
    width:  i32,
    // The height, in pixels of this image.
    height: i32,
    // The pixel data of this image, arranged left-to-right, top-to-bottom.
    pixels: [^]u8,
}

/*
    Describes the gamepad input state.
    @(since=3.3)
*/
Gamepad_State :: struct {
    // The state of each gamepad button. Either @(ref=Gamepad_Button.Press) or
    // @(ref=Gamepad_Button.Release)
    buttons: [Gamepad_Button]b8,
    // The states of each of the gamepad axes. All values are in the range
    // between -1.0 to 1.0 inclusive.
    axes:    [Gamepad_Axis]f32,
}

