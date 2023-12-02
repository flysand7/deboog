package glfw

// TODO: Integrations with vulkan and OpenGL
VkInstance       :: distinct rawptr
VkPhysicalDevice :: distinct rawptr

/*
    The major version number of the GLFW header for which these
    bindings are written. This is changed when the API is changed
    in non-compatible ways.
    
    You can use version numbers to verify that the API of the bindings
    matches the version of the library you are linking with.
*/
VERSION_MAJOR :: 3

/*
    The minor version number of the GLFW header for which these
    bindings are written. This number is changed when API is changed
    in backwards-compatible way.
*/
VERSION_MINOR :: 3

/*
    The revision number of the GLFW header for which these bindings
    are written. This number is changed when a bug fix release is
    made that does not contain API changes.
*/
VERSION_PATCH :: 8

/*
    Typed number "1".
*/
TRUE  :: true

/*
    Typed number "0".
*/
FALSE :: false

/*
    Key and button actions.

**Values:**
    - `.Release`: The key or mouse button was released.
    - `.Press`:   The key or mouse button was pressed.
    - `.Repeat`:  The key was held down until it repeated.
*/
Action :: enum i32 {
    Release = 0,
    Press   = 1,
    Repeat  = 2,
}

/*
    Joystick button states. See @(ref="Action").
*/
Joystick_Button_State :: enum u8 {
    Release = 0,
    Press   = 1,
}

/*
    Joystick hat states.
    
    Valid combinations of this bitset are:
    - Empty bitset `{}` -- (means centered)
    - Bitsets of one element (e.g. `{.Left}`)
    - Combinations of lateral directions (e.g. `{.Left, .Up}`)
*/
Hat_State :: bit_set[Hat_State_Bits; u8]
Hat_State_Bits :: enum {
    Up    = 0,
    Right = 1,
    Down  = 2,
    Left  = 3,
}

HAT_CENTERED   :: Hat_State{}
HAT_UP         :: Hat_State{.Up}
HAT_RIGHT      :: Hat_State{.Right}
HAT_DOWN       :: Hat_State{.Down}
HAT_LEFT       :: Hat_State{.Left}
HAT_RIGHT_UP   :: Hat_State{.Right, .Up}
HAT_RIGHT_DOWN :: Hat_State{.Right, .Down}
HAT_LEFT_UP    :: Hat_State{.Left,  .Up}
HAT_LEFT_DOWN  :: Hat_State{.Left,  .Down}

/*
    Keyboard keys.
    
    These key codes are inspired by *USB HID Usage Tables v1.12* (p. 53-60),
    but re-arranged to map to 7-bit ASCII for printable keys. The function
    keys are mapped to 256+ range.
    
    The naming of the key codes follow these rules:
    
    - The US keyboard layout is used.
    - Names of printable letter characters are used (e.g. `A`, `R`, etc)
    - Numeric characters are prefixed with `Key` (e.g. `Key0` for the "0" key)
    - For non-alphanumeric characters Unicode'ish names are used (e.g. `Left_Bracket`),
      except when they are shortened for brevity.
    - Keys that lack a clear US mapping are named `WORLD_*`
    - For non-printable keys custom names are used (e.g. `F4`, `Backspace`, etc)
*/
Key :: enum i32 {
    Space         = 32,
    Apostrophe    = 39,
    Comma         = 44,
    Minus         = 45,
    Period        = 46,
    Slash         = 47,
    Key0          = 48,
    Key1          = 49,
    Key2          = 50,
    Key3          = 51,
    Key4          = 52,
    Key5          = 53,
    Key6          = 54,
    Key7          = 55,
    Key8          = 56,
    Key9          = 57,
    Semicolon     = 59,
    Equal         = 61,
    A             = 65,
    B             = 66,
    C             = 67,
    D             = 68,
    E             = 69,
    F             = 70,
    G             = 71,
    H             = 72,
    I             = 73,
    J             = 74,
    K             = 75,
    L             = 76,
    M             = 77,
    N             = 78,
    O             = 79,
    P             = 80,
    Q             = 81,
    R             = 82,
    S             = 83,
    T             = 84,
    U             = 85,
    V             = 86,
    W             = 87,
    X             = 88,
    Y             = 89,
    Z             = 90,
    Left_Bracket  = 91,
    Backslash     = 92,
    Right_Bracket = 93,
    Grave_Accent  = 96,
    World1        = 161,
    World2        = 162,
    Escape        = 256,
    Enter         = 257,
    Tab           = 258,
    Backspace     = 259,
    Insert        = 260,
    Delete        = 261,
    Right         = 262,
    Left          = 263,
    Down          = 264,
    Up            = 265,
    Page_Up       = 266,
    Page_Down     = 267,
    Home          = 268,
    End           = 269,
    Caps_Lock     = 280,
    Scroll_Lock   = 281,
    Num_Lock      = 282,
    Print_Screen  = 283,
    Pause         = 284,
    F1            = 290,
    F2            = 291,
    F3            = 292,
    F4            = 293,
    F5            = 294,
    F6            = 295,
    F7            = 296,
    F8            = 297,
    F9            = 298,
    F10           = 299,
    F11           = 300,
    F12           = 301,
    F13           = 302,
    F14           = 303,
    F15           = 304,
    F16           = 305,
    F17           = 306,
    F18           = 307,
    F19           = 308,
    F20           = 309,
    F21           = 310,
    F22           = 311,
    F23           = 312,
    F24           = 313,
    F25           = 314,
    KP0           = 320,
    KP1           = 321,
    KP2           = 322,
    KP3           = 323,
    KP4           = 324,
    KP5           = 325,
    KP6           = 326,
    KP7           = 327,
    KP8           = 328,
    KP9           = 329,
    KP_Decimal    = 330,
    KP_Divide     = 331,
    KP_Multiply   = 332,
    KP_Subtract   = 333,
    KP_Add        = 334,
    KP_Enter      = 335,
    KP_Equal      = 336,
    Left_Shift    = 340,
    Left_Control  = 341,
    Left_Alt      = 342,
    Left_Suprt    = 343,
    Right_Shift   = 344,
    Right_Control = 345,
    Right_Alt     = 346,
    Right_Suprt   = 347,
    Menu          = 348, Last = Menu,
}

/*
    The key is unknown.
*/
KEY_UNKNOWN :: Key(-1)

/*
    Modifier key flags.

**Fields:**
    - `.Shift` - set when one of the Shift keys was held.
    - `.Control` - set when one of the Ctrl keys was held.
    - `.Super` - set when one of Super (aka Logo key (aka Windows key)) keys was pressed.
    - `.Caps_Lock` - set when caps lock key is enabled and @(ref=InputMode.Lock_Key_Mods)
       input mode flag was specified.
    - `.Num_Lock` - set when num lock key is enabled and @(ref=InputMode.Lock_Key_Mods)
       input mode flag was specified.
*/
Mod :: bit_set[Mod_Bits; i32]
Mod_Bits :: enum {
    Shift     = 0,
    Control   = 1,
    Alt       = 2,
    Super     = 3,
    Caps_Lock = 4,
    Num_Lock  = 5,
}

/*
    Mouse buttons.
*/
Mouse_Button :: enum i32 {
    Button1 = 0, Left   = Button1,
    Button2 = 1, Right  = Button2,
    Button3 = 2, Middle = Button3,
    Button4 = 3,
    Button5 = 4,
    Button6 = 5,
    Button7 = 6,
    Button8 = 7, Last = Button8,
}

/*
    Joystick IDs.
*/
Joystick :: enum i32 {
    Joystick1  = 0,
    Joystick2  = 1,
    Joystick3  = 2,
    Joystick4  = 3,
    Joystick5  = 4,
    Joystick6  = 5,
    Joystick7  = 6,
    Joystick8  = 7,
    Joystick9  = 8,
    Joystick10 = 9,
    Joystick11 = 10,
    Joystick12 = 11,
    Joystick13 = 12,
    Joystick14 = 13,
    Joystick15 = 14,
    Joystick16 = 15, Last = Joystick16,
}

/*
    Gamepad buttons.
*/
Gamepad_Button :: enum i32 {
    A            = 0, Cross    = A,
    B            = 1, Circle   = B,
    X            = 2, Square   = X,
    Y            = 3, Triangle = Y,
    Left_Bumper  = 4,
    Right_Bumper = 5,
    Back         = 6,
    Start        = 7,
    Guide        = 8,
    Left_Thumb   = 9,
    Right_Thumb  = 10,
    DPad_Up      = 11,
    DPad_Right   = 12,
    DPad_Down    = 13,
    DPad_Left    = 14, Last = DPad_Left,
}

/*
    Gamepad axes.
*/
Gamepad_Axis :: enum i32 {
    Left_X        = 0,
    Left_Y        = 1,
    Right_X       = 2,
    Right_Y       = 3,
    Left_Trigger  = 4,
    Right_Trigger = 5, Last = Right_Trigger,
}

/*
    GLFW Error codes.
*/
Error :: enum i32 {
    // No error has occured (Yay).
    No_Error              = 0,
    // GLFW has not been initialized. Initialize glfw before calling any function that requires
    // initialization.
    Not_Initialized       = 0x00010001,
    // No context is current for this thread.
    //
    // This occurs if a GLFW function was called that operates on the current OpenGL or OpenGL ES
    // context, but no context is current on the caller thread. An example of such a function is
    // @(ref=glfw_swap_interval).
    No_Current_Context    = 0x00010002,
    // One of the arguments to the function was an invalid enum value.
    // This shouldn't really happen since these bindings are supposed to give you only the correct.
    // enums. If you get these using this particular binding package, consider filing an issue
    // [On our tracker](https://github.com/flysand7/our/issues)
    Invalid_Enum          = 0x00010003,
    // One of the arguments to the function was an invalid value, for example requesting a 
    // non-existent OpenGL or OpenGL ES version like 2.7.
    Invalid_Value         = 0x00010004,
    // A bug in GLFW or the underlying operating system
    //
    // Report the bug to [GLFW Issue Tracker](https://github.com/glfw/glfw/issues).
    Out_Of_Memory         = 0x00010005,
    // GLFW could not find support for the requested API on the system.
    //
    // The installed graphics driver does not support the requested API, or does not support it via
    // the chosen context creation API. Examples are listed below. some pre-installed Windows
    // graphics drivers do not support
    //
    // OpenGL. AMD only supports OpenGL ES via EGL, while Nvidia and Intel only support it via WGL
    // or GLX extensions. MacOS does not provide OpenGL ES at all. The mesa EGL, OpenGL and OpenGL
    // ES libraries do not interface with Nvidia binary driver. Older graphics drivers do not
    // support Vulkan.
    Api_Unavailable       = 0x00010006,
    // The requested OpenGL or OpenGL ES version is not available on this
    // machine. Future versions return @(ref=Error.Invalid_Value), because GLFW doesn't know which
    // future versions will exist.
    Version_Unavailable   = 0x00010007,
    // A platform-specific error occured that does not match any of the more
    // specific categories.
    //
    // This is a GLFW and you should report it to
    // [GLFW Issue Tracker](https://github.com/glfw/glfw/issues)
    Platform_Error        = 0x00010008,
    // The requested format is not supported or available.
    //
    // If emitted during window creation, the requested pixel format is not supported, i.e.
    // one or more of the **hard constraints** did not match any of the available pixel formats.
    // See @(ref=Window_Hint) to know which constraints are hard constraints.
    //
    // If emitted during querying the clipboard, the contents of the clipboard could
    // not be converted to the requested format.
    Format_Unavailable    = 0x00010009,
    // The specified window does not have an OpenGL or OpenGL ES context.
    No_Window_Context     = 0x0001000a,
    // The specified standard cursor shape is not available, either because
    // the current platform cursor theme doesn't provide it or because it is not available on the
    // platform.
    Cursor_Unavailable    = 0x0001000b,
    // The requested feature is not provided by the platform, so GLFW
    // is unable to implement it. The documentation for each function notes if it could emit this
    // error.
    Feature_Unavailable   = 0x0001000c,
    // The requested feature is not implemented for the platform.
    // This one probably gets fixed in a future release... ;)
    Feature_Unimplemented = 0x0001000d,
    // If emitted during initialization, no matching platform was found. If
    // @(ref=Init_Hint.Platform) hint is set to @(ref=Platform.Any_Platform), GLFW could not detect
    // any of the platforms except for the `Null` platform. If set to a specific platform, it is
    // either not supported by the library binary or GLFW was not able to detect it.
    //
    // If emitted by a native access functions, GLFW was initialized for a different platform than
    // the function is for.
    //
    // Failure to detect any platform usually only happens on non-MacOS Unix systems, either when
    // no window system is running or the program was run from a terminal that does not have the
    // necessary environment variables. Fall back to a different platform is possible, or notify
    // the user that no usable platform was detected.
    //
    // Failure to detect platforms can also be caused if GLFW was not compiled with support for the
    // specific platform. The binaries provided by this package do have x11 and wayland support
    // compiled-in, so that's probably not gonna happen.
    Platform_Unavailable  = 0x0001000e,
}

/*
    Window creation hints.

**Hard and soft constraints**:

Some window hints are hard constraints. These must match the available capabilities *exactly*
for the window and context creation to succeed. The following hints are always hard constraints:

- `.Stereo`
- `.Doublebuffer`
- `.Client_API`
- `.Context_Creation_API`

The following additional hints are hard constraints when requesting an OpenGL context, but are
ignored when requesting an OpenGL ES context:

- `.OpenGL_Forward_Compat`
- `.OpenGL_Profile`

*/
Window_Hint :: enum i32 {
    // `bool` = `true`: Indicates whether the specified window has input focus.
    Focused                  = 0x00020001,
    // `bool` = `false`: Indicates whether the specified window is iconified (minimized).
    Iconified                = 0x00020002,
    // `bool` = `true`: Indicates whether the window can be resized.
    Resizable                = 0x00020003,
    // `bool` = `true`: Indicates whether the window is visible.
    Visible                  = 0x00020004,
    // `bool` = `true`: Indicates whether the window has decorations such as a border, a close
    // button etc.
    Decorated                = 0x00020005,
    // `bool` = `true`: Indicates whether the specified full screen window is iconified  (minimized) 
    // on focus loss, a close widget etc.
    Auto_Iconify             = 0x00020006,
    // `bool` = `false`: Indicates whether the specified window is floating, also called topmost, or
    // also known as *always-on-top*.
    Floating                 = 0x00020007,
    // `bool` = `false`: Indicates whether the specified window is maximized.
    Maximized                = 0x00020008,
    // `bool` = `true`: Specifies whether the cursor should be centered over newly-created full
    // screen windows.
    Center_Cursor            = 0x00020009,
    // `bool` = `false`: Specifies whether the window framebuffer will be transparent.
    // If enabled and supported by the system, the window framebuffer alpha channel will be used to
    // combine the framebuffer with the background. This does not affect window decorations.
    Transparent_Framebuffer  = 0x0002000a,
    // `bool`: Indicates whether the cursor is directly over the content area of the window with 
    // no other windows between.
    Hovered                  = 0x0002000b,
    // `bool` = `true`: Specifies whether the window will be given input focus when `show_window`
    // is called.
    Focus_On_Show            = 0x0002000c,
    // `bool` = `false`: Specifies whether the window is transparent to mouse input, letting
    // any mouse events pass through to whatever window is behind it. This is only supported for
    // undecorated windows. Decorated windows with this enabled will behave differently between
    // platforms.
    Mouse_Passthrough        = 0x0002000d,
    // `i32` = @(ref=ANY_POSITION): Specifies the initial x-coordinate of the placement of the
    // window in the screen space.
    Position_X               = 0x0002000e,
    // `i32` = @(ref=ANY_POSITION): Specifies the initial y-coordinate of the placement of the
    // window in the screen space.
    Position_Y               = 0x0002000f,
    // `i32` = `8`: Specify the desired bit depths of the red component of the
    // default framebuffer. A value @(ref=DONT_CARE) means that the application has no preference.
    Red_Bits                 = 0x00021001,
    // `i32` = `8`: Specify the desired bit depths of the green component of the
    // default framebuffer. A value @(ref=DONT_CARE) means that the application has no preference.
    Green_Bits               = 0x00021002,
    // `i32` = `8`: Specify the desired bit depths of the blue component of the
    // default framebuffer. A value @(ref=DONT_CARE) means that the application has no preference.
    Blue_Bits                = 0x00021003,
    // `i32` = `8`: Specify the desired bit depths of the alpha component of the
    // default framebuffer. A value @(ref=DONT_CARE) means that the application has no preference.
    Alpha_Bits               = 0x00021004,
    // `i32` = `24`: Specify the desired bit depths of the "depth" component of the
    // default framebuffer. A value @(ref=DONT_CARE) means that the application has no preference.
    Depth_Bits               = 0x00021005,
    // `i32` = `8`: Specify the desired bit depths of the "stencil" component of the
    // default framebuffer. A value @(ref=DONT_CARE) means that the application has no preference.
    Stencil_Bits             = 0x00021006,
    // `i32` = `0`: Specify the desired bit depths of the red components of the
    // accumulation buffer. A value @(ref=DONT_CARE) means that the application has no preference.
    Accum_Red_Bits           = 0x00021007,
    // `i32` = `0`: Specify the desired bit depths of the green components of the
    // accumulation buffer. A value @(ref=DONT_CARE) means that the application has no preference.
    Accum_Green_Bits         = 0x00021008,
    // `i32` = `0`: Specify the desired bit depths of the blue components of the
    // accumulation buffer. A value @(ref=DONT_CARE) means that the application has no preference.
    Accum_Blue_Bits          = 0x00021009,
    // `i32` = `0`: Specify the desired bit depths of the lpha components of the
    // accumulation buffer. A value @(ref=DONT_CARE) means that the application has no preference.
    Accum_Alpha_Bits         = 0x0002100a,
    // `i32` = `0`: Specified number of auxiliary buffers. A value of @(ref=DONT_CARE)
    // specifies that the application has no preference.
    Aux_Buffers              = 0x0002100b,
    // `bool` = `false`: Specifies whether to use OpenGL stereoscopic rendering.
    Stereo                   = 0x0002100c,
    // `i32` = `0`: Specifies the number of samples to use for multisampling. The value `0`
    // disables multisampling. The value @(ref=DONT_CARE) means the application has no preference.
    // This is a **hard constraint**
    Samples                  = 0x0002100d,
    // `bool` = `false`: Specifies whether the framebuffer should be sRGB capable.
    SRGB_Capable             = 0x0002100e,
    // `i32` = @(ref=DONT_CARE): Specifies the desired refresh rate for full-screen windows.
    // A value of @(ref=DONT_CARE) means the highest available refresh rate will be used.
    // For windowed-mode windows this hint is ignored.
    Refresh_Rate             = 0x0002100f,
    // `bool` = `true`: Specifies whether the framebuffer will be double buffered. This is a
    // **hard constraint**.
    Doublebuffer             = 0x00021010,
    // @(ref=Client_API) = @(ref=Client_Api.OpenGL_API): Specifies which client API to create the
    // context for. This is a **hard constraint**.
    Client_API               = 0x00022001,
    // `i32` = `1`:
    // Specify the client API version that the
    // created context must be compatible with. The exact behaviour of these hints depend on the
    // requested client API. While there's no way to ask the driver for a context of the highest
    // supported version, GLFW will attempt to provide this when you ask for a version 1.0 context,
    // which is the default value for these hints.
    // @(remark=opengl)
    //   These hints are **not hard constraints**, but creation will fail if OpenGL version of the
    //   created context is less than the one requested. It is therefore perfectly safe to use
    //   the default of the version 1.0 for legacy code and you will still get backwards-compatible
    //   contexts of version 3.0 and above when available.
    // @(remark=opengles)
    //   These hints are **not hard constraints**, but creation will fail if the OpenGL ES
    //   version of the context is less than the one requested. Additionally, OpenGL ES 1.x cannot
    //   be returned if 2.0 or later was requested, and vice versa. This is because OpenGL ES 3.x
    //   is backwards-compatible with OpenGL ES 2.0, but OpenGL ES 2.0 is not backwards-compatible
    //   with 1.x
    // @(remark=macos)
    //   The OS only supports core profile contexts for OpenGL versions 3.2 and later. Before
    //   creating an OpenGL context of version 3.2 or later you must set the `OpenGL_Profile` hint
    //   accordingly. OpenGL 3.0 and 3.1 contexts are not supported on all MacOS.
    Context_Version_Major    = 0x00022002,
    // `i32 = `0`: See @(ref=Window_Hint.Context_Version_Major)
    Context_Version_Minor    = 0x00022003,
    // `i32` = `0`: The revision number of the context.
    Context_Revision         = 0x00022004,
    // @(ref=Context_Robustness) = @(ref=Context_Robustness.No_Robustness): Specifies the
    // robustness strategy to be used by the context.
    Context_Robustness       = 0x00022005,
    // `bool` = `false`: Specifies whether the OpenGL context should be forward-compatible, i.e.
    // where all functionality deprecated in the requested version of OpenGL is removed. This must
    // only be used if the requested OpenGL version is 3.0 or above. If OpenGL ES is requested, this
    // hint is ignored.
    OpenGL_Forward_Compat    = 0x00022006,
    // `bool` = `false`: Specifies whether the context should be created in debug mode, which
    // may provide additional error and diagnostic reporting functionality.
    Context_Debug            = 0x00022007,
    // @(ref=OpenGL_Profile) = @(ref=OpenGL_Profile.Any_Profile): Specifies which OpenGL profile to
    // create the context for. If requesting an OpenGL version 3.2 or below, `.Any_Profile` must
    // be used. If OpenGL ES context is requested, this hint is ignored. If OpenGL context is
    // requested this hint is a **hard constraint**.
    OpenGL_Profile           = 0x00022008,
    // @(ref=Context_Release_Behavior) = @(ref=Context_Release_Behavior.Any): Specifies the release
    // behavior to be used by the context.
    Context_Release_Behavior = 0x00022009,
    // `bool` = `false`: Specifies whether errors should be generated by the context. If
    // enabled, the situations that would have generated errors instead cause unspecified behavior.
    Context_No_Error         = 0x0002200a,
    // Indicates the context creation API used
    // to create the window's context. This is a **hard constraint**. An extension loader library
    // that assumes it knows which API was used to create the current context may fail if you
    // change this hint. This can be resolved by having it load functions via
    // @(ref=get_proc_address).
    // @(remark=wayland):
    //   The EGL API is the native context creation API, so this hint will have no effect.
    // @(remark=x11):
    //   On some linux systems, creating contexts via both the native and EGL APIs in a single
    //   process will cause the application to segfault. Stick to one API or the other on linux
    //   for now.
    // @(remark=osmesa)
    //  As its name implies, an OpenGL context created with OSMesa does not update the window
    //  contents when its buffers are swapped. Use OpenGL functions or the OSMesa native access
    //  functions @(ref=get_os_mesa_color_buffer) and @(ref=get_os_mesa_depth_buffer) to retrieve
    //  the framebuffer's contents.
    Context_Creation_API     = 0x0002200b,
    // `bool` = `false`: Specifies whether the window content area should be resized based on the
    // monitor it is placed on. This includes the initial placement, when the window is created.
    Scale_To_Monitor         = 0x0002200c,
    // `bool` = `true`: Specifies whether to use full resolution framebuffers on retina displays.
    // Ignored on other platforms.
    Cocoa_Retina_Framebuffer = 0x00023001,
    // `cstring` = `""`: Specifies UTF-8 encoded name to use for autosaving the window frame, or
    // if empty disables frame autosaving for the window. This is ignored on other platforms.
    Cocoa_Frame_Name         = 0x00023002,
    // Specifies whether to use Automatic Graphics Switching, i.e.
    // to allow the system to choose the integrated CPU for the OpenGL context and move it between
    // GPUs if necessary or whether to force it to always run on discrete GPU. This only affects
    // systems with both integrated and discrete GPUs.    
    //
    // Simpler programs and tools may want to enable this to save power, while games and other
    // applications performing advanced rendering will want to leave it disabled.
    // 
    // A bundled application that wishes to participate in Automatic Graphics Switching should also
    // declare this in its `Info.plist` by setting the `NSSupportsAutomaticGraphicsSwitching` key
    // to `true`.
    Cocoa_Graphics_Switching = 0x00023003,
    // `cstring` = `""`: Specify the desired ASCII-encoded class of the ICCCM `WM_CLASS` window
    // property.
    X11_Class_Name           = 0x00024001,
    // `cstring` = `""`: Specify the desired ASCII-encoded instance name of the ICCCM `WM_CLASS`
    // window property.
    X11_Instance_Name        = 0x00024002,
    // `bool` = `false`: Specifies whether to allow access to the window menu via the Alt+space and
    // Alt-and-then-Space keyboard shortcuts. This is ignored on other platforms.
    Win32_Keyboard_Menu      = 0x00025001,
    // `cstring` = `""`: Allows setting `app_id`.
    Wayland_App_Id           = 0x00026001,
}

/*
    Possible values for the @(ref=Window_Hint.Client_API) hint.
*/
Client_API :: enum i32 {
    No_Api        = 0,
    OpenGL_API    = 0x00030001,
    OpenGL_ES_API = 0x00030002,
}

/*
    Possible values for the @(ref=Window_Hint.Context_Robustness) hint.
*/
Context_Robustness :: enum i32 {
    No_Robustness         = 0,
    No_Reset_Notification = 0x00031001,
    Lose_Context_On_Reset = 0x00031002,
}

/*
    Possible values for the @(ref=Window_Hint.Context_Release_Behavior) hint.
*/
Context_Release_Behavior :: enum i32 {
    // The default behavior of the context creation API will be used.
    Any   = 0,
    // The pipeline will be flushed whenever the context is released from being the current one.
    Flush = 0x00035001,
    // The pipeline will not be flushed on release.
    None  = 0x00035002,
}

/*
    Possible values for the @(ref=Window_Hint.Context_Creation_API) hint.
*/
Context_Creation_API :: enum i32 {
    Native = 0x00036001,
    EGL    = 0x00036002,
    OSMESA = 0x00036003,
}

/*
    Possible values for the @(ref=Window_Hint.OpenGL_Profile) hint.
*/
OpenGL_Profile :: enum i32 {
    Any_Profile    = 0,
    Core_Profile   = 0x00032001,
    Compat_Profile = 0x00032002,
}

/*
    The hints to be set before calling the @(ref=init) function that affect how GLFW behaves until
    termination. Init hints are set with @(ref=init_hint).
    
    Once GLFW has been initialized any further calls to @(ref=init_hint) are going to be ignored.
    
**Values:**
- `.Joystick_Hat_Buttons` (`bool`): Exposes joystick hats as buttons, for compatibility with earlier
    versions of GLFW that didn't have @(ref=get_joystick_hats).

- `.Angle_Platform` (@(ref=Angle_Platform)): Specifies the platform type (rendering
    backend) to request when using OpenGL ES and EGL via
    [ANGLE](https://chromium.googlesource.com/angle/angle/)

- `.Platform` (@(ref=Platform)): Specifies the platform to use for windowing and input.

- `.Cocoa_Chdir_Resources` (`bool`): Specifies whether to set the current directory of the
    application to the `Contents/Resources` subdirectory of the application's bundle, if present.

- `.Cocoa_Menubar` (`bool`): Specifies whether to create the menu bar and dock icon when GLFW is
    initialized. This applies whether the menu bar is created from a nib or manually by GLFW.

- `.X11_XCB_Vulkan_Surface` (`bool`): Specifies whether to prefer the `VK_KHR_xcb_surface`
    extension for creating Vulkan surfaces or whether to use the `VK_XHR_xlib_surface` extension.

- `.Wayland_Libdecor` (@(ref=Wayland_Libdecor)): Specifies whether to prefer using the libdecor
    library on wayland or to disable it.
*/
Init_Hint :: enum i32 {
    Joystick_Hat_Buttons   = 0x00050001,
    Angle_Platform         = 0x00050002,
    Platform               = 0x00050003,
    Cocoa_Chdir_Resources  = 0x00051001,
    Cocoa_Menubar          = 0x00051002,
    X11_XCB_Vulkan_Surface = 0x00052001,
    Wayland_Libdecor       = 0x00053001,
}

/*
    Possible values for the @(ref=Init_Hint.Angle_Platorm)
*/
Angle_Platform :: enum i32 {
    None     = 0x00037001,
    OpenGL   = 0x00037002,
    OpenGLES = 0x00037003,
    D3D9     = 0x00037004,
    D3D11    = 0x00037005,
    Vulkan   = 0x00037007,
    Metal    = 0x00037008,
}

/*
    Possible values for the @(ref=Init_Hint.Platform) hint.
*/
Platform :: enum i32 {
    Win32    = 0x00060001,
    Cocoa    = 0x00060002,
    Wayland  = 0x00060003,
    X11      = 0x00060004,
    Null     = 0x00060005,
}

/*
    Possible values for the @(ref=Init_Hint.Wayland_Libdecor) hint.
*/
Wayland_Libdecor :: enum i32 {
    Prefer  = 0x00038001,
    Disable = 0x00038002,
}

/*
    Possible values for @(ref=set_input_mode) function.
*/
Input_Mode :: enum i32 {
    // Specifies @(ref=Cursor_Mode) for the cursor.
    Cursor               = 0x00033001,
    // `bool`: Specifies whether to enable sticky keys. If sticky keys are enabled, it ensures that
    // when a key is pressed @(ref=get_key) returns @(ref=Action.Press) the next time the key is
    // pressed, even if the key had been released before the call. This is useful when you are only
    // interested in whether keys have been pressed, but not when or in which order.
    Sticky_Keys          = 0x00033002,
    // `bool`: Specifies whether to enable sticky mouse buttons. If sticky mouse buttons are
    // enabled,  a mouse button press will ensure that @(ref=get_mouse_button) returns
    // @(ref=Action.Press) even if the button was released before that. This is useful when you
    // are only interested in whether mouse buttons have been pressed, but not when or in which
    // order.
    Sticky_Mouse_Buttons = 0x00033003,
    // `bool`: If enabled, the callbacks that receive modifier bits will also have their 
    // @(ref=Mod_Bits.Caps_Lock) bit set if the event was generated with caps lock on and the
    // @(ref=Mod_Bits.Num_Lock) bit set if the event was generated with num lock on.
    Lock_Key_Mods        = 0x00033004,
    // `bool`: If enabled, the mouse events are generated raw (unscaled and unaccelerated).
    Raw_Mouse_Motion     = 0x00033005,
}

/*
    Cursor modes for special forms of mouse motion input. By default the mode is
    @(ref=Cursor_Mode.Normal). Meaning that a regular arrow cursor is used and the motion is not
    limited.
    
    The cursor modes can be set using the @(ref=set_input_mode) function.
*/
Cursor_Mode :: enum i32 {
    Normal   = 0x00034001,
    Hidden   = 0x00034002,
    Disabled = 0x00034003,
}

/*
    The cursor appearance (shape).
    
    Can be queried from the window system using @(ref=create_standard_cursor) function.
*/
Cursor_Shape :: enum i32 {
    Arrow     = 0x00036001,
    IBeam     = 0x00036002,
    Crosshair = 0x00036003,
    Hand      = 0x00036004,
    HResize   = 0x00036005,
    VResize   = 0x00036006,
}

/*
    Constants that specify joystick connection state.
*/
Connection_Event :: enum i32 {
    Connected    = 0x00040001,
    Disconnected = 0x00040002,
}

/*
    Used as a special value for window creation hints. Means that the application has no preference
    for the value of the specified hint.
*/
DONT_CARE :: -1

/*
    Specifies the window position recommended by the window system.
*/
ANY_POSITION :: 0x80000000
