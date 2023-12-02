package glfw

/*
    Sets the specified init hint to the desired value.
    
    The values set for these hints are never reset by GLFW, but they only take effect during
    initialization. Once GLFW has been initialized, any values you set will be ignored until the
    library is terminated and initialized again.
    
    Some hints are platform-specific. Other platforms will ignore them. Setting these hints
    requires no platform-specific headers or functions.
    
    See @(ref=Init_Hint) for which type each hint expects.
    
    @(parameters)
    - hint: The hint to set.
    - value: The value of the init hint.
    
    @(errors)
    - @(ref=Error.Invalid_Enum)
    - @(ref=Error.Invalid_Value)
    
    @(thread_safety=main_thread_only)
    @(since=3.3)
*/
init_hint :: proc {
    init_hint_b32,
    init_hint_platform,
    init_hint_angle_platform,
    init_hint_wayland_libdecor,
}

// @(hide)
@(private)
init_hint_b32 :: proc "contextless" (hint: Init_Hint, value: b32) {
    glfwInitHint(hint, cast(i32) value)
}

// @(hide)
@(private)
init_hint_angle_platform :: proc "contextless" (hint: Init_Hint, value: Angle_Platform) {
    glfwInitHint(hint, cast(i32) value)
}

// @(hide)
@(private)
init_hint_platform :: proc "contextless" (hint: Init_Hint, value: Platform) {
    glfwInitHint(hint, cast(i32) value)
}

// @(hide)
@(private)
init_hint_wayland_libdecor :: proc "contextless" (hint: Init_Hint, value: Wayland_Libdecor) {
    glfwInitHint(hint, cast(i32) value)
}

/*
    This function initializes the GLFW library. Before most GLFW functions can be used, GLFW must
    be initialized, and before an application terminates GLFW, it should be terminated in order to
    free any resources allocated during or after initialization.
    
    If this function fails, it calls @(ref=terminate) before returning. If it succeeds, you should
    call @(ref=terminate) before the application exits.
    
    Additional calls to this function after successful initialization but before termination will
    return `true` immediately.
    
    The @(ref=Init_Hint.Platform) controls which platforms are considered during initialization.
    This also depends on which platforms the library was compiled to support.
    
    @(returns)
    1. `true` if successful, `false` if an error occured (See @(ref=Error)).
    
    @(errors)
    - @(ref=Errors.Platform_Unavailable)
    - @(ref=Errors.Platform_Error)
    
    @(remark=darwin)
    On MacOS, this function will change the current directory of the application to the
    `Contents/Resources` subdirectory of the application's bundle, if present. This can be disabled
    with the @(ref=Init_Hint.Cocoa_Chdir_Resources) init hint.
    
    @(remark=darwin)
    On MacOS this function will create the main menu and dock icon for the application. If GLFW
    finds a `MainMenu.nib`, it is loaded and assumed to contain a menu bar. Otherwise a minimal
    menu bar is created manually with common comments like `Hide`, `Quit` and `About`. The `About`
    entry opens a minimal "about" dialog with information from application's bundle. The menu bar
    and dock icon can be disabled entirely with the @(ref=Init_Hint.Cocoa_Menubar) init hint.
    
    @(remark=x11)
    With x11 this function will set the `LC_CTYPE` category of the application's locale according
    to the current environment if that category is still `"C"`. This is because the `"C"` locale
    breaks the Unicode text input.
    
    @(thread_safety=main_thread_only)
    @(since=1.0)
*/
init :: proc "contextless" () -> b32 {
    return glfwInit()
}

/*
    Terminates the GLFW library.
    
    This function destroyes all remaining windows and cursors, restores any modified gamma ramps
    and frees any other allocated resources. Once this function is called, you must again call
    @(ref=init) successfully before you will be able to use most GLFW functions.
    
    See @(ref=init) for when this function should and should not be called.
    
    @(errors)
    - @(ref=Errors.Platform_Error)
    
    @(reentrancy)
    This function must not be called from a callback.
    
    @(warning)
    The contexts of any remaining windows must not be current on any other thread, when this
    function is called.
    
    @(thread_safety=main_thread_only)
    @(since=1.0)
*/
terminate :: proc "contextless" () {
    glfwTerminate()
}

/*
    This function retrieves the major, minor and revision numbers of the GLFW library. It is
    intended for when you are using GLFW as a shared library and want to ensure that you are using
    the minimum required version.
    
    @(returns)
    1. GLFW major version number
    2. GLFW minor version number
    3. GLFW revision number
    
    @(errors)
    - None.
*/
get_version :: proc "contextless" () -> (i32, i32, i32) {
    major: i32 = ---
    minor: i32 = ---
    patch: i32 = ---
    glfwGetVersion(&major, &minor, &patch)
    return major, minor, patch
}

/*
    Returns a string describing the compile-time configuration.
    
    This function returns the compile-time generated version string of the GLFW library binary.
    It describes the version, platforms, compiler and any platform or operating system specific
    compile-time options.
    
    **Do not use** the version string to parse the GLFW library version. The @(ref=get_version)
    function provides the version in numerical format.
    
    **Do not use** the version string to parse the supported platforms. The
    @(ref=platforms_supported) function lets you query platform support.
    
    @(errors)
    - None.

    @(since=3.0)
*/
get_version_string :: proc "contextless" () -> cstring {
    return glfwGetVersionString()
}

/*
    @(since=3.3)
    Returns and clears the last error for the calling thread.
    
    This functions returns and clears the error code (@(ref=Error)) of the last error that occurred
    on the calling thread and a UTF-8 encoded human-readable description of it. If no error has
    occurred since the last call, it returns @(ref=Error.No_Error) (`nil`) and the returned string
    is `nil`.
    
    @(returns)
    1. The GLFW error code.
    2. The human-readable description of the error.
    
    @(errors)
    - None.
    
    @(lifetimes)
    - description: Allocated and freed by GLFW. You should not free it yourself. It is
    guaranteed to be valid only until the next error occurs or the library is terminated.
    
    @(remark)
    This function may be called before @(ref=init)
    
    @(thread_safety=safe)
    @(since=3.3)
*/
get_error :: proc "contextless" () -> (Error, cstring) {
    description: cstring = ---
    error_code := glfwGetError(&description)
    return error_code, description
}

/*
    Sets the error callback.
    
    This function sets the error callback, which is called with the error code and a human-readable
    error description each time a GLFW error occurs.
    
    The error code is set before the callback is called. Calling @(ref=get_error) from the error
    callback will return the same value as the error code argument.
    
    The error callback is called on the thread where the error occurred. If you are using GLFW
    from multiple threads, your error callback needs to be written accordingly.
    
    Because the description string may have been generated specifically for that error, it is not
    guaranteed to be valid after the callback has returned. If you wish to use the description
    string after the callback returns you would need to make a copy.
    
    Once set, the error callback remains set, even after the library has been terminated.
    
    @(params)
    - callback: The new callback or `nil` to remove the currently-set callback.

    @(returns)
    1. The previously-set callback or `nil` if no callback was set.
    
    @(remark)
    This function may be called before @(ref=init)
    
    @(thread_safety=main_thread_only)
    @(include=Error_Proc)
    @(since=3.0)
*/
set_error_callback :: proc "contextless" (callback: Error_Proc) -> Error_Proc {
    return glfwSetErrorCallback(callback)
}

/*
    Returns the currently conntected monitors.
    
    This function returns an array of handles for all currently connected monitors. The primary
    monitor is always first in the returned array. If no monitors were found, this function returns
    an empty slice (`nil`).
    
    @(returns)
    - The slice of monitor handles. The length of the slice is `0` if no monitors were found.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    
    @(lifetimes)
    - The returned array is allocated and freed by GLFW. You should not free it yourself. It is
    guaranteed to be valid only until the monitor configuration changes or the library is
    terminated.
    
    @(thread_safety=main_only)
    @(since=3.0)
*/
get_monitors :: proc "contextless" () -> []^Monitor {
    count: i32 = ---
    monitors := glfwGetMonitors(&count)
    return monitors[:count]
}

/*
    Returns the primary monitor.
    
    This function returns the primary monitor. This is usually the monitor where elements like
    the task bar or global menu are located.
    
    @(returns)
    - The primary monitor or `nil` if no monitors were found.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
get_primary_monitor :: proc "contextless" () -> ^Monitor {
    return glfwGetPrimaryMonitor()
}

/*
    Returns the position of the monitor's viewport on the virtual screen.
    
    This function returns the position, in screen coordinates of the upper-left corner of the
    specified monitor.
    
    @(params)
    - monitor: The monitor to query.
    
    @(returns)
    1. The x-coordinate of the monitor's viewport on the virtual screen.
    2. The y-coordinate of the monitor's viewport on the virtual screen.
    
    @(errors)
    - @(ref=Errors.Not_Initialized)
    - @(ref=Errors.Platform_Error)
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
get_monitor_pos :: proc "contextless" (monitor: ^Monitor) -> (i32, i32) {
    pos_x: i32 = ---
    pos_y: i32 = ---
    glfwGetMonitorPos(monitor, &pos_x, &pos_y)
    return pos_x, pos_y
}

/*
    Retrieves the work area of the monitor.
    
    This function returns the position, in screen coordinates, of the upper-left corner of the work
    area of the specified monitor, along with the size of the work area in screen coordinates. The
    work area is defined as the area of the monitor not occluded by the window system task bar where
    present. If no task bar exists, then the work area is the monitor resolution in screen
    coordinates.
    
    @(params)
    - monitor: The monitor to query.
    
    @(returns)
    1. The x-coordinate of the work area.
    2. The y-coordinate of the work area.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    
    @(thread_safety=main_thread_only)
    @(since=3.3)
*/
get_monitor_workarea :: proc "contextless" (monitor: ^Monitor) -> (i32, i32, i32, i32) {
    pos_x: i32 = ---
    pos_y: i32 = ---
    size_x: i32 = ---
    size_y: i32 = ---
    glfwGetMonitorWorkarea(monitor, &pos_x, &pos_y, &size_x, &size_y)
    return pos_x, pos_y, size_x, size_y
}

/*
    Returns the physical size of the monitor.
    
    This function returns the size, in millimetres, of the display area of the specified monitor.
    
    Some platforms do not provide accurate monitor size information, either because monitor's
    [EDID](https://en.wikipedia.org/wiki/Extended_display_identification_data) data is incorrect,
    or because the driver does not report it accurately.
    
    @(params)
    - monitor: The monitor to query.
    
    @(returns)
    1. The width of the monitor, in millimetres, of the monitor's display area.
    2. The height of the monitor, in millimetres, of the monitor's display area.
    
    @(errors)
    - @(ret=Error.Not_Initialized)
    
    @(remark=win32)
    On Windows 8 and earlier the physical size is calculated from the current resolution and system
    DPI instead of querying the monitor EDID data.
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
get_monitor_physical_size :: proc "contextless" (monitor: ^Monitor) -> (i32, i32) {
    size_x_mm: i32 = ---
    size_y_mm: i32 = ---
    glfwGetMonitorPhysicalSize(monitor, &size_x_mm, &size_y_mm)
    return size_x_mm, size_y_mm
}

/*
    Retrieves the content scale for the specified monitor.
    
    This function retrieves the content scale for the specified monitor. The content scale is the
    ratio between the current DPI and the platfom's default DPI. This is especially important for
    text and any UI elements. If the pixel dimensions of your UI scaled by this value look
    reasonable on your monitor, it should appear at a reasonable size on other monitors regardless
    of their DPI and scaling settings. This relies on the system DPI and scaling settings being
    somewhat correct.
    
    The content scale may depend on both the monitor resolution, pixel density and on the user
    settings. It may be very different from the raw DPI calculated from the physical size and the
    current resolution.
    
    @(params)
    - monitor: The monitor to query.
    
    @(returns)
    1. The x-axis of the content scale.
    2. The y-axis of the content scale.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    
    @(thread_safety=main_thread_only)
    @(since=3.3)
*/
get_monitor_content_scale :: proc "contextless" (monitor: ^Monitor) -> (f32, f32) {
    scale_x: f32 = ---
    scale_y: f32 = ---
    glfwGetMonitorContentScale(monitor, &scale_x, &scale_y)
    return scale_x, scale_y
}

/*
    Returns the name of the specified monitor.
    
    This function returns a human-readable name, encoded as UTF-8, of the specified monitor. The
    name typically reflects the make and model of the monitor and is not guaranteed to be unique
    among the connected monitors.
    
    @(params)
    - monitor: The monitor to query
    
    @(returns)
    1. The UTF-8 encoded name of the monitor, or `nil` if an error occurred.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    
    @(lifetimes)
    The returned string is allocated and freed by GLFW. You should not free it yourself. It is
    valid only until the specified monitor is disconnected or the library is terminated.
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
get_monitor_name :: proc "contextless" (monitor: ^Monitor) -> cstring {
    return glfwGetMonitorName(monitor)
}

/*
    Sets the user pointer of the specified monitor.
    
    This function sets the user-defined pointer of the specified monitor. The current value is
    retained until the monitor is disconnected. The initial value is `nil`.
    
    @(params)
    - monitor: The monitor whose pointer to set.
    - pointer: The new pointer value to set.
    
    @(reentrancy)
    This function may be called from the monitor callback, or even for a monitor that is being
    disconnected.
    
    @(thread_safety=safe)
    @(since=3.3)
*/
set_monitor_user_pointer :: proc "contextless" (monitor: ^Monitor, pointer: rawptr) {
    glfwSetMonitorUserPointer(monitor, pointer)
}

/*
    Returns the user pointer of the specified monitor.
    
    This function returns the current value of the user-defined pointer of the specified monitor.
    The initial value is `nil`.
    
    @(params)
    - monitor: The monitor whose pointer to return
    
    @(returns)
    1. The user pointer of the specified monitor
    
    @(reentrancy)
    This function may be called from the monitor callback, or even for a monitor that is being
    disconnected.
    
    @(thread_safety=safe)
    @(since=3.3)
*/
get_monitor_user_pointer :: proc "contextless" (monitor: ^Monitor) -> rawptr {
    return glfwGetMonitorUserPointer(monitor)
}

/*
    Sets the monitor configuration callback.
    
    This function sets the monitor configuration callback, or removes the currently-set callback.
    This callback function will be called when a monitor is connected or disconnected from the
    system.
    
    @(params)
    - callback: The new callback, or `nil` to remove the currently-set callback.
    
    @(returns)
    1. The previously-set callback or `nil` if no callback was set or the library had not been
    initialized
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
set_monitor_callback :: proc "contextless" (callback: Monitor_Proc) -> Monitor_Proc {
    return glfwSetMonitorCallback(callback)
}

/*
    Returns the available video modes for the specified monitor.
    
    This function returns a slice of all video modes supported by the specified monitor. The
    returned array is sorted in ascending order, first by color bit depth (the sum of all
    components), then by resolution area (the product of components), then resolution width
    and finally by refresh rate.
    
    @(params)
    - monitor: The monitor to query
    
    @(returns)
    1. The slice of video modes. In case error occured returns a zero-length `nil` slice.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    
    @(lifetimes)
    - The returned array is allocated and freed by GLFW. You should not free it yourself. It is
    valid until the specified monitor is disconnected, if this function is called again for that
    monitor, or if the library is terminated.
    
    @(thread_safety=main_thread_only)
    @(since=1.0)
*/
get_video_modes :: proc "contextless" (monitor: ^Monitor) -> []Video_Mode {
    count: i32 = ---
    modes := glfwGetVideoModes(monitor, &count)
    return modes[:count]
}

/*
    Returns the current mode of the specified monitor.
    
    This function returns the current video mode of the specified monitor. If you have created a
    full-screen window for that monitor, the return value will depend on whether that window is
    iconified.
    
    @(params)
    - monitor: The monitor to query
    
    @(returns)
    - The current mode of the monitor, or `nil` if an error occurred.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
get_video_mode :: proc "contextless" (monitor: ^Monitor) -> ^Video_Mode {
    return glfwGetVideoMode(monitor)
}

/*
    Generates a gamma ramp and sets it for the specified monitor.
    
    This function generates an appropriately-sized gamma ramp from the specified exponent and then
    calls @(ref=set_gamma_ramp) with it. The value `gamma` must be a finite number greater than
    zero.
    
    The software controlled gamma ramp is applied *in addition* to the hardware gamma correction,
    which today is usually an approximation of sRGB gamma. This means that setting a perfectly
    linear ramp, or gamma `1.0`, will produce the default (sRGB-like) behaviour.
    
    For gamma-correct rendering with OpenGL or OpenGL ES see @(ref=Window_Hint.SRGB_Capable) hint.
    
    @(params)
    - monitor: The monitor whose gamma ramp to set
    - gamma: The desired exponent
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Invalid_Value)
    - @(ref=Error.Platform_Error)
    - @(ref=Error.Feature_Unavailable)
    
    @(remark=wayland)
    Under wayland gamma handling is a priviliged protocol, this function will this never be
    implemented and emits @(ref=Error.Feature_Unavailable)
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
set_gamma :: proc "contextless" (monitor: ^Monitor, gamma: f32) {
    glfwSetGamma(monitor, gamma)
}

/*
    Returns the current gamma ramp for the specified monitor.
    
    This function returns the current gamma ramp of the specified monitor.
    
    @(params)
    - monitor: The monitor to query.
    
    @(returns)
    - The current gamma ramp or `nil` if an error occurred.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    - @(ref=Error.Feature_Unavailable)
    
    @(remark=wayland)
    Under wayland gamma handling is a priviliged protocol, this function will this never be
    implemented and emits @(ref=Error.Feature_Unavailable)
    
    @(pointer_lifetime)
    The returned structure and its arrays are allocated and freed by GLFW. You should not free them
    yourself. They are valid until the specified monitor is disconnected, this function is called
    again for that monitor or the library is terminated.
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
get_gamma_ramp :: proc "contextless" (monitor: ^Monitor) -> ^Gamma_Ramp {
    return glfwGetGammaRamp(monitor)
}

/*
    Sets the current gamma ramp for the specified monitor.
    
    This function sets the current gamma ramp for the specified monitor. The original gamma ramp
    for that monitor is saved by GLFW the first time this function is called and is restored by
    @(ref=terminate) function.
    
    The software-controlled gamma ramp is applied *in addition* to the hardware gamma correction,
    which today is usually an approximation of sRGB gamma. This means that setting a perfectly
    linear ramp, or gamma 1.0, will produce the default (usually sRGB-like) behavior.
    
    For gamma-correct rendering with OpenGL or OpenGL ES, see @(ref=Window_Hint.SRGB_Capable)
    window hint.
    
    @(params)
    - monitor: The monitor whose gamma ramp to ramp.
    - gamma_ramp: The gamma ramp to use.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    - @(ref=Error.Feature_Unavailable) (see remarks)
    
    @(remark)
    The size of the specified gamma ramp should match the size of the current ramp for that monitor.
    
    @(remark=win32)
    The gamma ramp size must be 256
    
    @(remark=wayland)
    Gamma handling is a privileged protocool, this function will thus never be implemented and
    emits @(ref=Error.Feature_Unavailable)
    
    @(lifetimes)
    The specified gamma ramp is copied before this function returns.
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
set_gamma_ramp :: proc "contextless" (monitor: ^Monitor, gamma_ramp: ^Gamma_Ramp) {
    glfwSetGammaRamp(monitor, gamma_ramp)
}

/*
    Resets all window hints to their default values.
    
    This function resets all window hints to their default values.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
default_window_hints :: proc "contextless" () {
    glfwDefaultWindowHints()
}

/*
    Sets the specified window hint to the desired value.
    
    This function sets hints for the next call to @(ref=create_window). The hints, once set retain
    their value until changed by a call to this function or @(ref=default_window_hints), or until
    the library is terminated.
    
    This function is a polymorphic variant accepting hints of integer, boolean, string and various
    enumeration types. You have to ensure you are calling the correct variant. In order to see
    which variant is expected for any specific value of hint, see @(ref=Window_Hint).
    
    This function does not check whether the specified hint values are valid. If you set hints to
    invalid values, this will instead be reported by the next call to @(ref=create_window).
    
    Some hints are platform-specific. These may be set on any platform, but they will only affect
    their specific platform. Other platforms will ignore them.
    
    @(params)
    - hint: The hint to set.
    - value: The value to set the hint to.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Invalid_Enum)
    
    @(lifetimes)
    If you provide string as a parameter, the string is copied.
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
window_hint :: proc {
    window_hint_i32,
    window_hint_b32,
    window_hint_cstring,
    window_hint_opengl_profile,
}

// @(hide)
@(private)
window_hint_i32 :: proc "contextless" (hint: Window_Hint, value: i32) {
    glfwWindowHint(hint, value)
}

// @(hide)
@(private)
window_hint_b32 :: proc "contextless" (hint: Window_Hint, value: b32) {
    glfwWindowHint(hint, cast(i32) value)
}

// @(hide)
@(private)
window_hint_cstring :: proc "contextless" (hint: Window_Hint, value: cstring) {
    glfwWindowHintString(hint, value)
}

// @(hide)
@(private)
window_hint_opengl_profile :: proc "contextless" (hint: Window_Hint, profile: OpenGL_Profile) {
    glfwWindowHint(hint, cast(i32) profile)
}

/*
    Creates the window and its associated context.
    
    This function creates a window and it's associated OpenGL and OpenGL ES context. Most of the
    options controlling how the window and its context should be created are specified with window
    hints (see @(ref=window_hint)).
    
    Successfull creation does not change which context is current. Before you can use the newly
    created context you need to make it current (see @(ref=make_context_current)).
    
    The meaning of the `share` parameter is as follows: Object sharing is implemented by the
    operating system and the graphics driver. On the platforms where it is possible to choose which
    types of objects are shared, GLFW requests that all types are shared. You might want to see
    the relevant chapters of the [OpenGL](https://www.opengl.org/registry/) and
    [OpenGL ES](https://www.khronos.org/opengles/) docs for more information. The name and number
    of the chapter varies between versions and API's but at times has been named *Shared Objects
    and multiple contexts*.
    
    The created window, the framebuffer and the context may differ from what you requested. Not all
    parameters and hints are hard constraints. In order to see the list of hard constraints, see
    @(ref=Window_Hint). The list of soft constraints includes the size of the window, especially
    for full screen windows. To query the actual attributes of the created window, framebuffer and
    context see @(ref=get_window_attrib), @(ref=get_window_size) and @(ref=get_framebuffer_size).
    
    To create a full screen window, you need to specify the monitor the window will cover. If no
    monitor is specified, the window will be windowed mode. Unless you have a way for the user to
    choose a specific monitor, it is recommended that you pick the primary monitor. In order to
    query available monitors see @(ref=get_monitors)
    
    For full-screen windows, the specified size becomes the resolution of the window's desired
    *video mode*. As long as a full-screen window is not iconified (minimized)m the supported video
    mode most closely matching the desired video mode is set for the specified monitor.
    
    By default, newly created windows use the placement recommended by the window system. To create
    the window at a specific position, set the @(ref=Window_Hint.Position_X) and
    @(ref=Window_Hint.Position_Y) window hints before creation. To restore the default behaviour
    set either or both hints back to @(ref=ANY_POSITION).
    
    As long as at least one full-screen window is not iconified (minimized), the screensaver is
    prohibited from starting.
    
    Window systems put limits on window sizes. Very large or very small window dimensions. You
    might want to check the actual window size after creation.
    
    The *swap interval* is not set during window creation and the initial value may vary depending
    on the driver settings and defaults.
    
    @(params)
    - size_x: The desired width, in screen coordinates, of the window. Must be greater than zero.
    - size_y: The desired height, in screen coordinates, of the window. Must be greater than zero.
    - title: The initial, UTF-8 encoded window title.
    - monitor: The monitor to use for full-screen mode, or `nil` for windowed mode.
    - share: The window whose to share context resources with, or `nil` to not share resources.
    
    @(returns)
    - window: The handle to the created window, or `nil` if an error occurred.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Invalid_Enum)
    - @(ref=Error.Invalid_Value)
    - @(ref=Error.Api_Unavailable)
    - @(ref=Error.Version_Unavailable)
    - @(ref=Error.Format_Unavailable)
    - @(ref=Error.Platform_Error)
    
    @(remark=win32)
    Window creation will fail if the microsoft GDI software OpenGL implementation is the only one
    available.
    
    @(remark=macos)
    The GLFW window has no icon, as it is not a document window, but the dock icon will be the same
    as the application bundle's icon. For more information on bundles see the
    [Bundle Programming Guide](https://developer.apple.com/library/mac/documentation/CoreFoundation/Conceptual/CFBundles/)
    in the Mac Developer Library.
    
    @(remark=macos)
    On OSX 10.10 and later, the window frame will not be rendered at full resolution on Retina
    displays unless the @(ref=Window_Hint.Cocoa_Retina_Framebuffer) hint is set to `true`. And
    the `NSHighResolutionCapable` key is enabled in the applications bundle's `Info.plist`. For
    more information, see
    [High Resolution Guidelines for OS X](https://developer.apple.com/library/mac/documentation/GraphicsAnimation/Conceptual/HighResolutionOSX/Explained/Explained.html).
    in the Mac Developer Library.
    
    @(remark x11)
    Some window managers will not respect the placement of initially-hidden windows.
    
    @(remark x11)
    Due to the asynchronous nature of X11, it may take a moment for the window to reach its
    requested state. This means that you may not be able to query the final size, position or other
    attributes directly after window creation.
    
    @(remark x11)
    The class part of the `WM_CLASS` window property will by default be set to the window title
    passed to this function. The instance part will use the contents of `RESOURCE_NAME` environment
    variable, if present and not empty, or fall back to the window title. Set the
    @(ref=Window_Hint.X11_Class_Name) and @(ref=Window_Hint.X11_Instance_Name) window hints to
    override this behavior.
    
    @(remark=wayland)
    Compositors should implement the `xdg-decoration` protocol for GLFW to decorate the window
    properly. If this protocol isn't supported, or if the compositor prefers client-side decorations,
    a very simple fallback frame will be drawn using the `wp_viewporter` protocol. A compositor
    can still emit `close`, `maximize` and `fullscreen` events, using, for instance a keybind
    mechanism. If neither of these protocols is supported, the window won't be decorated.
    
    @(remark=wayland)
    Screensaver inhibition requires the idle-inhibit protocol to be implemented in the user's
    compositor.
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
create_window :: proc "contextless" (
    size_x:  i32,
    size_y:  i32,
    title:   cstring,
    monitor: ^Monitor = nil,
    share:   ^Window  = nil,
) -> ^Window {
    return glfwCreateWindow(size_x, size_y, title, monitor, share)
}

/*
    Destroys the specified window and its associated context.
    
    This function destroys the specified window and its context. On calling this function no
    further callbacks will be called for that window.
    
    If the context of the specified window is current on the main thread, it is detached before
    being destroyed.
    
    @(params)
    - window: The window to destroy
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    
    @(note)
    The context of the specified window must not be current on any other thread when this function
    is called.
    
    @(reentrancy)
    This function must not be called within a callback.
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
destroy_window :: proc "contextless" (window: ^Window) {
    glfwDestroyWindow(window)
}

/*
    Checks the close flag of the specified window.
    
    This function returns the value of the close flag of the specified window.
    
    @(params)
    - window: The window to query.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    
    @(thread_safety=safe)
    @(since=3.0)
*/
window_should_close :: proc "contextless" (window: ^Window) -> b32 {
    return glfwWindowShouldClose(window)
}

/*
    Sets the close flag of the specified window.
    
    This function sets the value of the close flag of the specified window. This can be used to
    override the user's attempt to close the window, or to signal that it should be closed.
    
    @(params)
    - window: The window whose flag to change.
    - should_close: The new value of the flag.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    
    @(thread_safety=safe)
    The access to this function is not synchronized.
    
    @(since=3.0)
*/
set_window_should_close :: proc "contextless" (window: ^Window, should_close: b32) {
    glfwSetWindowShouldClose(window, should_close)
}

/*
    Sets the title of the specified window.
    
    This function sets the window title, encoded as UTF-8, of the specified window.
    
    @(params)
    - window: The window whose title to change.
    - title: The UTF-8 encoded window title.
    
    @(remark=macos)
    The window title will not be updated until the next time you process events.
    
    @(thread_safety=safe)
    @(since=1.0)
*/
set_window_title :: proc "contextless" (window: ^Window, title: cstring) {
    glfwSetWindowTitle(window, title)
}

/*
    Sets the icon for the specified window.
    
    This function sets the icon of the specified window. If multiple candidate images, those of the
    closest to the sizes desired by the system are selected. If no images are specified, the window
    reverts to its default icon.
    
    The pixels are 32-bit little-endian, non-premultiplied RGBA, i.e. eight bits per channel with
    the red channel first. They are arranged canonically as packed sequential rows, starting from
    the top-left corner.
    
    The desired image sizes varies depending on platform and system settings. The selected images
    will be rescaled as needed. Good sizes include 16x16, 32x32 and 48x48.
    
    @(params)
    - window: The window whose icon to set.
    - icons: The images to create the icon from. Can be `nil`.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Invalid_Value)
    - @(ref=Error.Platform_Error)
    - @(ref=Error.Feature_Unavailable) (see remarks)
    
    @(remark=macos)
    Regular windows do not have icons on macOS. This function will emit
    @(ref=Error.Feature_Unavailable). The dock icon will be the same as the application bundle's
    icon. For more information on bundles see the [Bundle Programming Guide](https://developer.apple.com/library/mac/documentation/CoreFoundation/Conceptual/CFBundles/)
    in the Mac Developer Library.
    
    @(lifetimes)
    - The specified image data is copied before this function returns.
    
    @(since=3.2)
*/
set_window_icon :: proc "contextless" (window: ^Window, icons: []Image) {
    glfwSetWindowIcon(window, cast(i32) len(icons), raw_data(icons))
}

/*
    Retrieves the position of the content area of the specified window.
    
    This function retrieves the position, in screen coodinates, of the upper-left corner of the
    content area of the specified window.
    
    @(params)
    - window: The window to query.
    
    @(returns)
    1. The x-coordinate of the upper-left corner of the content area.
    2. The y-coordinate of the upper-left corner of the content area.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    - @(ref=Error.Feature_Unavailable) (see remarks)
    
    @(remark=wayland)
    There is no way for an application to retrieve the global position of its windows. This function
    will emit @(ref=Error.Feature_Unavailable).
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
get_window_pos :: proc "contextless" (window: ^Window) -> (i32, i32) {
    pos_x: i32 = ---
    pos_y: i32 = ---
    glfwGetWindowPos(window, &pos_x, &pos_y)
    return pos_x, pos_y
}

/*
    Sets the position of the content area of the specified window.
    
    This function sets the position, in screen coordinates of the upper-left corner of the content
    area of the specified windowed-mode window. If the window is a full-screen window, this function
    does nothing.
    
    **Do not use this function** to move an already visible window, unless you have very good
    reasons for doing so, as it will confuse and annoy the user.
    
    The window manager may put limits on what positions are allowed. GLFW cannot and should not
    override these limits.
    
    @(params)
    - window: The window to query.
    - pos_x: The x-coordinate of the upper-left corner of the content area.
    - pos_y: The y-coordinate of the upper-left corner of the content area.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    - @(ref=Error.Feature_Unavailable) (see remarks)
    
    @(remark=wayland)
    There is no way for an application to set the global position of its windows. This function will
    emit @(ref=Error.Feature_Unavailable).
    
    @(thread_safety=main_thread_only)
    @(since=1.0)
*/
set_window_pos :: proc "contextless" (window: ^Window, pos_x: i32, pos_y: i32) {
    glfwSetWindowPos(window, pos_x, pos_y)
}

/*
    Retrieves the size of the content area of the specified window.
    
    This function retrieves the size, in screen coordinates, of the content area of the specified
    window. If you wish to retrieve the size of the framebuffer of the window in pixels, see
    @(ref=get_framebuffer_size).
    
    @(params)
    - window: The window whose size to retrieve.
    
    @(returns)
    1. The width, in screen coordinates, of the content area, or `nil`.
    2. The height, in screen coordinates, of the content area, or `nil`.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    
    @(thread_safety=main_thread_only)
    
    @(since=1.0)
*/
get_window_size :: proc "contextless" (window: ^Window) -> (i32, i32) {
    size_x: i32 = ---
    size_y: i32 = ---
    glfwGetWindowSize(window, &size_x, &size_y)
    return size_x, size_y
}

/*
    Sets the size limits of the specified window.
    
    This function sets the size limits of the content area of the specified window. If the window
    is full screen, the size limits only take effect once it is made windowed. If the window is not
    resizeable, this function does nothing.
    
    The size limits are applied immediately to a windowed mode window and may cause it to be
    resized.
    
    The maximum dimensions must be greater than or equal to the minimum dimensions and all must be
    greater than or equal to zero.
    
    @(params)
    - window: The window to set the limits for.
    - min_size_x: The minimum width, in screen coordinates, of the content area or @(ref=DONT_CARE).
    - min_size_y: The minimum height, in screen coordinates, of the content area or
        @(ref=DONT_CARE).
    - max_size_x: The maximum width, in screen coordinates, of the content area or @(ref=DONT_CARE).
    - max_size_y: The maximum height, in screen coordinates, of the content area or
        @(ref=DONT_CARE).
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Invalid_Value)
    - @(ref=Error.Platform_Error)
    
    @(remark)
    If you se the size limits and aspect ratio that conflicts, the results are unspecified.
    
    @(remark=wayland)
    The size limits will not be applied until the window si actually resized, either by the user or
    the compositor.
    
    @(thread_safety=main_thread_only)
    @(since=3.2)
*/
set_window_size_limits :: proc "contextless" (
    window: ^Window,
    min_size_x: i32 = DONT_CARE,
    min_size_y: i32 = DONT_CARE,
    max_size_x: i32 = DONT_CARE,
    max_size_y: i32 = DONT_CARE,
) {
    glfwSetWindowSizeLimits(window, min_size_x, min_size_y, max_size_x, max_size_y)
}

/*
    Sets the aspect ratio of the specified window.
    
    This function sets the required aspect ratio of the content area of the specified window. If
    the window is full-screen, the aspect ratio only takes effect once it is made windowed. If the
    window is not resizable, this option does nothing.
    
    The aspect ratio is specified as a numerator and a denominator and both values must be greater
    than zero. For example, the common 16:9 aspect ratio is specified as 166 and 9, respectively.
    
    If the numerator and denominator are set to @(ref=DONT_CARE), then the aspect ratio limit is
    disabled.
    
    The aspect ratio is applied immediately to a windowed-mode window and may cause it to be
    resized.
    
    @(params)
    - window: The window to set the limits for.
    - numerator: The numerator of the desired aspect ratio, or @(ref=DONT_CARE)
    - denominator: The denominator of the desired aspect ratio, or @(ref=DONT_CARE)
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Invalid_Value)
    - @(ref=Error.Platform_Error)
    
    @(remark)
    If you set size limits and an aspect ratio that conflict, the results are unspecified.
    
    @(remark=wayland)
    The aspect ratio will not be applied until the window is actually resized, either by the user or
    by the compositor.
    
    @(thread_safety=main_thread_only)
    @(since=3.2)
*/
set_window_aspect_ratio :: proc "contextless" (window: ^Window, numerator: i32, denominator: i32) {
    glfwSetWindowAspectRatio(window, numerator, denominator)
}

/*
    Sets the size of the content area of the specified window.
    
    This function sets the size, in screen coordinates, of the content area of the specified window.
    
    For full-screen windows, this function updates the resolution of its desired video mode and
    switches to the video mode closest to it, without affecting the window's context. As the
    context is unaffected, the bit depths of the framebuffer remain unchanged.
    
    If you wish to update the refresh rate of the desired video mode, in addition to its resolution
    see @(ref=get_framebuffer_size).
    
    The window manager may put limits on what sizes are allowed. GLFW can not and should not
    override any of these limits.
    
    @(params)
    - window: The window to resize.
    - size_x: The desired width, in screen coordinates, of the window content area.
    - size_y: The desired height, in screen coordinates, of the window content area.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    
    @(remark=wayland)
    A full-screen window iwll not attempt to change the mode, no matter the requested size.
    
    @(thread_safety=main_thread_only)
    @(since=1.0)
*/
set_window_size :: proc "contextless" (window: ^Window, size_x: i32, size_y: i32) {
    glfwSetWindowSize(window, size_x, size_y)
}

/*
    Retrieves the size of the framebuffer of the specified window.
    
    This function retrieves the size, in pixels, of the framebuffer of the specified window. If you
    wish to retrieve the size of the window in screen coordinates, see @(ref=get_window_size).
    
    @(params)
    - window: The window whose framebuffer to query.
    
    @(returns)
    1. The width, in pixels, of the framebuffer.
    2. The height, in pixels, of the framebuffer.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
get_framebuffer_size :: proc "contextless" (window: ^Window) -> (i32, i32) {
    size_x: i32 = ---
    size_y: i32 = ---
    glfwGetFramebufferSize(window, &size_x, &size_y)
    return size_x, size_y
}

/*
    Retrieves the size of the frame of the window.
    
    This function retrieves the size, in screen coordinates of each edge of the frame of the
    specified window. The size includes the title bar, if the window has one. The size of the frame
    may vary depending on @(ref=Window_Hint) hints used to create the window.
    
    Because this function retrieves the size of each window frame edge and not the offset along a
    particular coordinate axis, the retrieved values will always be non-negative.
    
    @(params)
    - window: The window whose frame size to query.
    
    @(returns)
    1. The size, in screen coordinates, of the left edge of the window frame
    2. The size, in screen coordinates, of the top edge of the window frame
    3. The size, in screen coordinates, of the right edge of the window frame
    4. The size, in screen coordinates, of the bottom edge of the window frame
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Platform_Error)
    
    @(thread_safety=main_thread_only)
    @(since=3.1)
*/
get_window_frame_size :: proc "contextless" (window: ^Window) -> (i32, i32, i32, i32) {
    left:   i32 = ---
    top:    i32 = ---
    right:  i32 = ---
    bottom: i32 = ---
    glfwGetWindowFrameSize(window, &left, &top, &right, &bottom)
    return left, top, right, bottom
}

/*
    Retrieves the content scale for the specified window.
    
    This function retrieves the content scale for the specified window. The content scale is the
    ratio between the currnet DPI and the platform's default DPI. This is especially important for
    text and any UI elements. If the pixel dimensions of your UI scaled by this look appropriate on
    your machine then it should appear at a reasonable size on other machines regardless of their
    DPI and scaling settings. This relies on the system DPI and scaling settings being somewhat
    correct.
    
    On the platforms where each monitor can have its own content scale the window content scale
    will depend on which monitor the system considers the window to be on.
    
    @(params)
    - window: The window to query.
    
    @(returns)
    1. The x-axis content scale.
    2. The y-axis content scale.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
get_window_content_scale :: proc "contextless" (window: ^Window) -> (f32, f32) {
    scale_x: f32 = ---
    scale_y: f32 = ---
    glfwGetWindowContentScale(window, &scale_x, &scale_y)
    return scale_x, scale_y
}

/*
    Returns the opacity of the whole window.
    
    This function returns the opacity of the window, including any decorations.
    
    The opacity (or alpha) value is a positive finite number between zero and one, where zero means
    fully-transparent and one means fully-opaque. If the system doesn't support whole window
    transparency, this function always returns one.
    
    The initial opacity value for newly-created windows is one.
    
    @(params)
    - window: The window to query.
    
    @(returns)
    - The opacity value of the specified window.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    
    @(thread_safety=main_thread_only)
    @(since=3.3)
*/
get_window_opacity :: proc "contextless" (window: ^Window) -> f32 {
    return glfwGetWindowOpacity(window)
}

/*
    Sets the opacity of the whole window.
    
    This function sets the opacity of the window, including any decorations.
    
    The opacity (or alpha) value is a positive finite number between zero and one, where zero means
    fully-transparent and one means fully-opaque.
    
    The initial opacity for newly-created windows is one.
    
    A window created with framebuffer transparency may not use whole window transparency. The
    results of doing so are unspecified.
    
    @(params)
    - window: The window to set the opacity for.
    - opacity: The desired opacity of the specified window.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    - @(ref=Error.Feature_Unavailable) (see remarks)
    
    @(remark=wayland)
    There is no way to set an opacity factor for a window. This function will emit a
    @(ref=Error.Feature_Unavailable).
    
    @(thread_safety=main_thread_only)
    @(since=3.3)
*/
set_window_opacity :: proc "contextless" (window: ^Window, opacity: f32) {
    glfwSetWindowOpacity(window, opacity)
}

/*
    Iconifies (minimizes) the specified window.
    
    This function iconifies the specified window if it was previously restored. If the window is
    already iconified, this function does nothing.
    
    if the specified window is a full-screen window, GLFW restores the original video mode of the
    monitor. The window's desired video mode is set again when the window is restored.
    
    @(params)
    - window: The window to modify
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    
    @(remark=wayland)
    Once a window is iconified, @(ref=restore_window) won't be able to restore it. This is a design
    decision of the xdg-shell protocol.
    
    @(thread_safety=main_thread_only)
    @(since=2.1)
*/
iconify_window :: proc "contextless" (window: ^Window) {
    glfwIconifyWindow(window)
}

/*
    Restores the specified window.
    
    This function restores the specified window, if it was previously iconified (minimized) or
    maximized. If the window is already restored, this function does nothing.
    
    If the specified window is an iconified full-screen window, its desired video mode is set again
    for its monitor when the window is restored.
    
    @(params)
    - window: The window to restore
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    
    @(thread_safety=main_thread_only)
    @(since=2.1)
*/
restore_window :: proc "contextless" (window: ^Window) {
    glfwRestoreWindow(window)
}

/*
    Maximizes the specified window.
    
    This function maximizes the specified window, if it was previously not maximized. If the window
    is already maximized, this function does nothing.
    
    If the specified window is a full-screen window, this function does nothing.
    
    @(params)
    - window: The window to maximize.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    
    @(thread_safety=main_thread_only)
    @(since=3.2)
*/
maximize_window :: proc "contextless" (window: ^Window) {
    glfwMaximizeWindow(window)
}

/*
    Makes the specified window visible.
    
    This function makes the specified window visible, if it was previously hiddne. If the window is
    already visible, or is in full-screen mode, this function does nothing.
    
    By default, windowed-mode windows are focused when shown. Set @(ref=Window_Hint.Focus_On_Show)
    window hint to change this behavior for all newly-created windows, or change the behavior for
    an existing window with @(ref=set_window_attrib).
    
    @(params)
    - window: The window to make visible.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    
    @(remark=wayland)
    Because wayland wants every frame of the desktop to be complete, this function does not
    immediately, this function does not immediately make the window visible. Instead it will become
    visible the next time the window's framebuffer is updated after this call.
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
show_window :: proc "contextless" (window: ^Window) {
    glfwShowWindow(window)
}

/*
    Hides the specified window.
    
    This function hides the specified window, if it was previously visible. If the window is
    already hidden or is in a full-screen mode, this function does nothing.
    
    @(params)
    - window: The window to hide.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    
    (since=3.0)
*/
hide_window :: proc "contextless" (window: ^Window) {
    glfwHideWindow(window)
}

/*
    Brings the specified window to front and sets the input focus.
    
    This function brings the specified window to front and sets the input focus. The window should
    already be visible and not iconified.
    
    By default, both windowed and full-screen windows are focused when initially created. Set the
    @(ref=Window_Hint.Focused) window hint to disable this behavior.
    
    Also by default, windowed mode windows are focused when shown when @(ref=show_window). Set the
    @(ref=Window_Hint.Focus_On_Show) hint to disable this behaviour.
    
    **Do not use this function** to steal focus from other applications, unless you are certain
    that's wants. Focus stealing can be extremely disruptive.
    
    @(params)
    - window: The window to give input focus.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    - @(ref=Error.Feature_Unavailable) (see remark)
    
    @(remark=wayland)
    It is not possible for an application to set the input focus. This function will emit
    @(ref=Error.Feature_Unavailable).
    
    @(thread_safety=main_thread_only)
    @(since=3.2)
*/
focus_window :: proc "contextless" (window: ^Window) {
    glfwFocusWindow(window)
}

/*
    Requests user attention to the specified window.
    
    This function requests user attention to the specified window. On platforms where this is not
    supported, attention is requested to the application as a whole. Once the user has given
    attention, usually by focusing the window or application, the system will end the request
    automatically.
    
    @(params)
    - window: The window to request attention to.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Platform_Error)
    
    @(remark=macos)
    Attention is requested to the application as a whole, not a specified window.
    
    @(thread_safety=main_thread_only)
    @(since=3.3)
*/
request_window_attention :: proc "contextless" (window: ^Window) {
    glfwRequestWindowAttention(window)
}

/*
    Returns the monitor that the window uses for full-screen mode.
    
    This function returns the handle of the monitor that the specified window is in full-screen on.
    
    @(params)
    - window: The window to query.
    
    @(returns)
    - The monitor, or `nil` if the window is in windowed mode or an error occured.
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
window_monitor :: proc "contextless" (window: ^Window) -> ^Monitor {
    return glfwWindowMonitor(window)
}

/*
    Sets the mode, monitor, video mode and placement of a window.
    
    This function sets the monitor that the window uses for full-screen mode or, if the monitor is
    `nil`, makes it windowed.
    
    When setting a monitor, this function updates the width, height and refresh rate of the desired
    video mode and switches to the video mode most closely matching the specified mode. The window
    position is ignored when setting a monitor.
    
    When the monitor is `nil`, the position, width and height are used to place the window's content
    area. The refresh rate is ignored when no monitor is specified.
    
    If you only wish to update the resolution of a full-screen window or the size of a
    windowed-mode window, see @(ref=set_window_size).
    
    When a window transitions from full-screen to windowed mode, this function restores any previous
    window settings such as whether it is decorated, floating, resizable, has size or aspect ratio
    limits etc.
    
    @(params)
    - window: The window whose monitor, size or video mode to set.
    - monitor: The desired monitor, or `nil` to set windowed mode.
    - pos_x: The desired x-coordinate of the upper-left corner of the content area.
    - pos_y: The desired y-coordinate of the upper-left corner of the content area.
    - size_x: The desired width, in screen coordinates, of the content area.
    - size_y: The desired height, in screen coordinates, of the content area.
    - refresh_rate: The desired refresh rate, in hertz, of the video mode or @(ref=DONT_CARE).
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    
    @(remark)
    The OpenGL or OpenGL ES context will not be destroyed or otherwise affected by any resizing or
    mode switching, although you may need to update your viewport if the framebuffer size has
    changed.
    
    @(remark=wayland)
    The desired window position is ignored, as there is no way for an application to set this
    property.
    
    @(remark=wayland)
    Setting the window to full-screen will not attempt to change this mode, no matter the requested
    size or refresh rate.
    
    @(thread_safety=main_thread_only)
    @(since=3.2)
*/
set_window_monitor :: proc "contextless" (
    window: ^Window,
    monitor: ^Monitor,
    pos_x: i32,
    pos_y: i32,
    size_x: i32,
    size_y: i32,
    refresh_rate: i32,
) {
    glfwSetWindowMonitor(window, monitor, pos_x, pos_y, size_x, size_y, refresh_rate)
}

/*
    Returns an attribute of the specified window.
    
    This function returns the value of an attribute of the specified window, or its OpenGL or
    OpenGL ES context.
    
    This function obtains only the values of the boolean attributes. In order to obtain an integer
    attribute, use @(ref=get_window_attrib_i32) function. In order to see which attributes are
    integers and which are types, see @(ref=Window_Hint).
    
    @(params)
    - window: The window to query.
    - attrib: The @(ref=Window_Hint) whose value to return.
    
    @(returns)
    - The value of the attribute as a boolean.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Invalid_Enum)
    - @(ref=Error.Platform_Error)
    
    @(remark)
    Framebuffer-related hints are not window attributes.
    
    @(remark)
    Zero is a valid value for many window and context-related attributes, so you can not use a
    return of zero as an indication of errors. However this function should not fail as long as it
    is passed valid arguments and the library has been initialized/
    
    @(remark=wayland)
    The wayland protocol provides no way to check whether window is iconified (minimized), so
    @(ref=Window_Hint.Iconified) always returns `false`.
    
    @(include=get_window_attrib_b32)
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
get_window_attrib :: get_window_attrib_b32

// @(hide)
get_window_attrib_i32 :: proc "contextless" (window: ^Window, attrib: Window_Hint) -> i32 {
    return glfwGetWindowAttrib(window, attrib)
}

// @(hide)
get_window_attrib_b32 :: proc "contextless" (window: ^Window, attrib: Window_Hint) -> b32 {
    return cast(b32) glfwGetWindowAttrib(window, attrib)
}

/*
    Sets an attribute of the specified window.
    
    This function sets the value of an attribute of the specified window.
    
    The supported attributes are:
    - @(ref=Window_Hint.Decorated)
    - @(ref=Window_Hint.Resizable)
    - @(ref=Window_Hint.Floating)
    - @(ref=Window_Hint.Auto_Iconify)
    - @(ref=Window_Hint.Focus_On_Show)
    - @(ref=Window_Hint.Mouse_Passthrough)
    
    Some of these attributes are ignored for full-screen windows. The new value will take effect if
    the window is later made windowed.
    
    Some of these attributes for windowed-mode windows. The new values will take effect if the
    window is later made full-screen.
    
    @(params)
    - window: The window to set the attribute for.
    - attrib: A supported window attribute.
    - value: The value of the attribute.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Invalid_Enum)
    - @(ref=Error.Invalid_Value)
    - @(ref=Platform_Error)
    - @(ref=Feature_Unavailable)
    
    @(remark)
    Calling @(ref=get_window_attrib) will always return the latest value, even if that value is
    ignored by the current mode of the window.
    
    @(thread_safety=main_thread_only)
    @(since=3.3)
*/
set_window_attrib :: proc "contextless" (window: ^Window, attrib: Window_Hint, value: b32) {
    glfwSetWindowAttrib(window, attrib, cast(b32) value)
}

/*
    Sets the user pointer of the specified window.
    
    This function sets the user-defined pointer of the specified window. The current value is
    retained until the window is destroyed. The initial value is `nil`.
    
    @(params)
    - window: The window whose pointer to set.
    - pointer: The new value.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    
    @(thread_safety=unsafe)
    @(since=3.0)
*/
set_window_user_pointer :: proc "contextless" (window: ^Window, pointer: rawptr) {
    glfwSetWindowUserPointer(window, pointer)
}

/*
    Returns the user pointer of the specified window.
    
    This function returns the current value of the user-defined pointer of the specified window.
    The initial value is `nil`.
    
    @(params)
    - window: The window whose pointer to return
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    
    @(thread_safety=unsafe)
    @(since=3.0)
*/
get_window_user_pointer :: proc "contextless" (window: ^Window) -> rawptr {
    return glfwGetWindowUserPointer(window)
}

/*
    Sets the position callback for the specified window.
    
    This function sets the position callback of the specified window, which is called when the
    window is moved. The callback is provided with the position, in screen coordinates, of the
    upper-left corner of the content area of the window.
    
    @(params)
    - window: The window whose callback to set.
    - callback: The new callback, or `nil` to remove the currently-set callback.
    
    @(returns)
    - The previously-set callback, or `nil` if no callback was set or the library has not been
        initialized.
        
    @(errors)
    - @(ref=Error.Not_Initialized)
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
set_window_pos_callback :: proc "contextless" (window: ^Window, callback: Window_Pos_Proc) -> Window_Pos_Proc {
    return glfwSetWindowPosCallback(window, callback)
}

/*
    Sets the size callback for the specified window.
    
    This function sets the size callback of the specified window, which is called when the window
    is resized. The callback is provided with the size, in screen coordinates, of the content area
    of the window.
    
    @(params)
    - window: The window whose callback to set.
    - callback: The new callback, or `nil` to remove the currently-set callback.
    
    @(returns)
    - The previously-set callback, or `nil` if no callback was set or the library has not been
        initialized.
        
    @(errors)
    - @(ref=Error.Not_Initialized)
    
    @(thread_safety=main_thread_only)
    @(since=1.0)
*/
set_window_size_callback :: proc "contextless" (window: ^Window, callback: Window_Size_Proc) -> Window_Size_Proc {
    return glfwSetWindowSizeCallback(window, callback)
}

/*
    Sets the close callback for the specified window.
    
    This function sets the close callback of the specified window, which is called when the user
    attempts to close the window, for example by clicking the close widget in the title bar.
    
    The close flag is set before this callback is called, but you can modify it at any time with
    @(ref=set_window_should_close)
    
    The close callback is not triggered by @(ref=destroy_window).
    
    @(params)
    - window: The window whose callback to set.
    - callback: The new callback, or `nil` to remove the currently-set callback.
    
    @(returns)
    - The previously-set callback, or `nil` if no callback was set or the library has not been
        initialized.
        
    @(errors)
    - @(ref=Error.Not_Initialized)
    
    @(thread_safety=main_thread_only)
    @(since=2.5)
*/
set_window_close_callback :: proc "contextless" (window: ^Window, callback: Window_Close_Proc) -> Window_Close_Proc {
    return glfwSetWindowCloseCallback(window, callback)
}

/*
    Sets the refresh callback for the specified window.
    
    This function sets the refresh callback of the specified window, which is called when the
    content area of the window needs to be redrawn, for example, if the window has been exposed
    after having been covered by another window.
    
    On compositing window systems, such as Aero, Compiz, Aqua or Wayland, where the window contents
    are saved off-screen this callback may be called only very infrequently or never at all.

    @(params)
    - window: The window whose callback to set.
    - callback: The new callback, or `nil` to remove the currently-set callback.
    
    @(returns)
    - The previously-set callback, or `nil` if no callback was set or the library has not been
        initialized.
        
    @(errors)
    - @(ref=Error.Not_Initialized)
    
    @(thread_safety=main_thread_only)
    @(since=2.5)
*/
set_window_refresh_callback :: proc "contextless" (window: ^Window, callback: Window_Refresh_Proc) -> Window_Refresh_Proc {
    return glfwSetWindowRefreshCallback(window, callback)
}

/*
    Sets the focus callback for the specified window.
    
    This function sets the focus callback of the specified window, which is called, when the window
    gains or loses input focus.
    
    After the focus callback is called for a window that lost input focus, synthetic key and mouse
    button release events will be generated for all such that had been pressed. For more information
    see @(ref=set_key_callback) and @(ref=set_mouse_button_callback).

    @(params)
    - window: The window whose callback to set.
    - callback: The new callback, or `nil` to remove the currently-set callback.
    
    @(returns)
    - The previously-set callback, or `nil` if no callback was set or the library has not been
        initialized.
        
    @(errors)
    - @(ref=Error.Not_Initialized)
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
set_window_focus_callback :: proc "contextless" (window: ^Window, callback: Window_Focus_Proc) -> Window_Focus_Proc {
    return glfwSetWindowFocusCallback(window, callback)
}

/*
    Sets the iconify callback for the specified window.
    
    This function sets the iconification callback of the specified window, which is called when the
    window is iconified or restored.

    @(params)
    - window: The window whose callback to set.
    - callback: The new callback, or `nil` to remove the currently-set callback.
    
    @(returns)
    - The previously-set callback, or `nil` if no callback was set or the library has not been
        initialized.
        
    @(errors)
    - @(ref=Error.Not_Initialized)
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
set_window_iconify_callback :: proc "contextless" (window: ^Window, callback: Window_Iconify_Proc) -> Window_Iconify_Proc {
    return glfwSetWindowIconifyCallback(window, callback)
}

/*
    Sets the maximize callback for the specified window.
    
    This function sets the maximization callback of the specified window, which is called, when
    the window is maximized or restored.
    
    @(params)
    - window: The window whose callback to set.
    - callback: The new callback, or `nil` to remove the currently-set callback.
    
    @(returns)
    - The previously-set callback, or `nil` if no callback was set or the library has not been
        initialized.
        
    @(errors)
    - @(ref=Error.Not_Initialized)
    
    @(thread_safety=main_thread_only)
    @(since=3.3)
*/
set_window_maximize_callback :: proc "contextless" (window: ^Window, callback: Window_Maximize_Proc) -> Window_Maximize_Proc {
    return glfwSetWindowMaximizeCallback(window, callback)
}

/*
    Sets the framebuffer resize callback for the specified window.
    
    This function sets the framebuffer resize callback of the specified window, which is called when
    the framebuffer of the specified window is resized.
    
    @(params)
    - window: The window whose callback to set.
    - callback: The new callback, or `nil` to remove the currently-set callback.
    
    @(returns)
    - The previously-set callback, or `nil` if no callback was set or the library has not been
        initialized.
        
    @(errors)
    - @(ref=Error.Not_Initialized)
    
    @(thread_safety=main_thread_only)
    @(since=3.0)    
*/
set_framebuffer_size_callback :: proc "contextless" (window: ^Window, callback: Framebuffer_Size_Proc) -> Framebuffer_Size_Proc {
    return glfwSetFramebufferSizeCallback(window, callback)
}

/*
    Sets the window content scale callback for the specified window.
    
    This function sets the window content scale callback of the specified window, which is called
    when the content scale of the specified window changes.
    
    @(params)
    - window: The window whose callback to set.
    - callback: The new callback, or `nil` to remove the currently-set callback.
    
    @(returns)
    - The previously-set callback, or `nil` if no callback was set or the library has not been
        initialized.
        
    @(errors)
    - @(ref=Error.Not_Initialized)
    
    @(thread_safety=main_thread_only)
    @(since=3.3)    
*/
set_window_content_scale_callback :: proc "contextless" (window: ^Window, callback: Window_Content_Scale_Proc) -> Window_Content_Scale_Proc {
    return glfwSetWindowContentScaleCallback(window, callback)
}

/*
    Processes all pending events.
    
    This function processes only those events that are already in the event queue and returns
    immediately. Processing events will cause the window and input callbacks associated with those
    events to be called.
    
    On some platforms, a window move, resize or menu operations will cause event processing to
    block. This is due to how event processing is designed on those platforms. You can use the
    @(ref=set_window_refresh_callback) to redraw the contents of the window when necessary during
    such operations.
    
    Do not assume that callbacks you set will *only* be called in response to event processing
    functions like this one. While it is necessary to poll for events, window systems that require
    GLFW to register callbacks of its own can pass those events onto the application callbacks
    before returning.
    
    Event processing is not required for joystick input to work.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    
    @(reentrancy)
    This function must not be called from a callback.
    
    @(thread_safety=main_thread_only)
    @(since=1.0)
*/
poll_events :: proc "contextless" () {
    glfwPollEvents()
}

/*
    Waits until events are queued and processes them.
    
    This function puts the calling thread to sleep until at least one event is available in the
    event queue. Once one or more events are available, it behaves exactly like @(ref=poll_events),
    i.e. the events in the queue are processed and the function then returns immediately. Processing
    events will cause the window and input callbacks associated with those events to be called.
    
    Since not all events are associated with callbacks, this function may return without a callback
    having been called even if you are monitoring all callbacks.
    
    On some platforms, a window move, resize or menu operations will cause event processing to
    block. This is due to how event processing is designed on those platforms. You can use the
    @(ref=set_window_refresh_callback) to redraw the contents of your window when necessary during
    such operations.
    
    Do not assume that callbacks you set will *only* be called in response to event processing
    functions like this one. While it is necessary to poll for events, window systems that require
    GLFW to register callbacks of its own can pass events to GLFW in response to many window system
    function calls. GLFW will pass those events onto the application callbacks before returning.
    
    Event processing is not required for joystick input to work.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    
    @(reentrancy)
    This function must not be called from a callback.
    
    @(thread_safety=main_thread_only)
    @(since=2.5)
*/
wait_events :: proc "contextless" () {
    glfwWaitEvents()
}

/*
    Waits with timeout until events are queued and processes them.
    
    This function puts the calling thread to sleep until at least one event is available in the
    event queue, or until the specified timeout is reached. If one or more events are available,
    it behavaes exactly like @(ref=poll_events), i.e. the events in the queue are processed and
    the function then returns immediately. Processing events will cause the window and input
    callbacks associated with those events to be called.
    
    The timeout value must be a positive finite number.
    
    Since not all events are associated with callbacks, this function may return without a callabck
    having been called even if you are monitoring all callbacks.
    
    On some platforms, a window move, resize or menu operations will cause event processing to
    block. This is due to how event processing is designed on those platforms. You can use the
    @(ref=set_window_refresh_callback) to redraw the contents of your window when necessary during
    such operations.
    
    Do not assume that callbacks you set will *only* be called in response to event processing
    functions like this one. While it is necessary to poll for events, window systems that require
    GLFW to register callbacks of its own can pass events to GLFW in response to many window system
    function calls. GLFW will pass those events on to the application callbacks before returning.
    
    Event processing is not required for joystick input to work.
    
    @(params)
    - timeout: The maximum amount of time, in seconds, to wait.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Invalid_Value)
    - @(ref=Error.Platform_Error)
    
    @(reentrancy)
    This function must not be called from a callback.
    
    @(thread_safety=main_thread_only)
    @(since=3.2)
*/
wait_events_timeout :: proc "contextless" (timeout: f64) {
    glfwWaitEventsTimeout(timeout)
}

/*
    Posts an empty event to the event queue.
    
    This function posts an empty event from the current thread to the event queue, causing
    @(ref=wait_events) or @(ref=wait_events_timeout) to return.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    
    @(thread_safety=safe)
    @(since=3.1)
*/
post_empty_event :: proc "contextless" () {
    glfwPostEmptyEvent()
}

/*
    Returns the value of an input option for the specified window.
    
    This function returns the value of an input option for the specified window.
    
    This function only returns boolean modes. In order to query the cursor mode, use
    @(ref=get_input_mode_cursor).
    
    @(parrams)
    - window: The window to query.
    - mode: The input option to retrieve.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Invalid_Enum)
    
    @(include=get_input_mode_cursor)
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
get_input_mode :: proc "contextless" (window: ^Window, mode: Input_Mode) -> b32 {
    return cast(b32) glfwGetInputMode(window, mode)
}

// @(hide)
get_input_mode_cursor :: proc "contextless" (window: ^Window, mode: Input_Mode) -> Cursor_Mode {
    return cast(Cursor_Mode) glfwGetInputMode(window, mode)
}

/*
    Sets an input option for the specified window.
    
    This function sets an input mode option for the specified window.
    
    See the documentation on @(ref=Input_Mode) for the description of input modes.
    
    @(params)
    - window: The window to set the input option for.
    - mode: The input option to set.
    - value: The value to set the input option to.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Invalid_Enum)
    - @(ref=Error.Platform_Error)
    - @(ref=Error.Feature_Unavailable) (see remark)
    
    @(remark)
    If you specify @(ref=Input_Mode.Raw_Mouse_Motion) to be `true`, and the raw mouse motion
    is not supported, @(ref=Error.Feature_Unavailable) is generated. Call
    @(ref=raw_mouse_motion_supported) to query the support of raw mouse motion.
*/
set_input_mode :: proc {
    set_input_mode_b32,
    set_input_mode_cursor_mode,
}

@(private)
set_input_mode_b32 :: proc "contextless" (window: ^Window, mode: Input_Mode, value: b32) {
    glfwSetInputMode(window, mode, cast(i32) value)
}

@(private)
set_input_mode_cursor_mode :: proc "contextless" (window: ^Window, mode: Input_Mode, value: Cursor_Mode) {
    glfwSetInputMode(window, mode, cast(i32) value)
}

/*
    Returns whether raw mouse motion is supported.
    
    This function returns whether raw mouse motion is supported on the current system. This status
    does not change after GLFW has been initialized, so you only need to check this once. If you
    attempt to enable raw motion on a system that doesn't support it, @(ref=Error.Platform_Error)
    will be emitted.
    
    Raw mouse motion is closer to the actual motion of the mouse across a surface. It is not
    affected by the scaling and acceleration applied to the motion of the desktop cursor. That
    processing is suitable for a cursor while raw motion is better for controlling, for example
    a 3D camera. Because of this, raw mouse motion is only provided when the cursor is disabled.
    
    @(returns)
    - `true`, if raw mouse motion is supported on the current machine, `false` otherwise.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    
    @(since=3.3)
*/
raw_mouse_motion_supported :: proc "contextless" () -> b32 {
    return glfwRawMouseMotionSupported()
}

/*
    Returns the layout-specific name of the specified printable key.
    
    This function returns the name of the specified printable key, encoded as UTF-8. This is
    typically the character that the key would produce without any modifier keys, intended for
    displaying key bindings to the user. For dead keys, it is typically the diacritic it would
    add to the character.
    
    **Do not use this function** for text input. You will break text input for many languages, even
    if it happens to work on yours.
    
    If the key is @(ref=KEY_UNKNOWN), the scancode is used to identify the key, otherwise the
    scancode is ignored. If you specify a non-printable key, or @(ref=KEY_UNKNOWN) and a scancode
    that maps to a non-printable key, this function returns `nil` and does not emit an error.
    
    This behaviour allows you to always pass in the arguments from the key callback without
    modification.
    
    The printable keys are:
    - @(ref=Key.Apostrophe)
    - @(ref=Key.Comma)
    - @(ref=Key.Minus)
    - @(ref=Key.Period)
    - @(ref=Key.Slash)
    - @(ref=Key.Semicolon)
    - @(ref=Key.Equal)
    - @(ref=Key.Left_Bracket)
    - @(ref=Key.Right_Bracket)
    - @(ref=Key.Backslash)
    - @(ref=Key.World1)
    - @(ref=Key.World2)
    - @(ref=Key.Key0) through to @(ref=Key.Key9)
    - @(ref=Key.A) through to - @(ref=Key.Z)
    - @(ref=Key.KP_Decimal)
    - @(ref=Key.KP_Divide)
    - @(ref=Key.KP_Multiply)
    - @(ref=Key.Subtract)
    - @(ref=Key.Add)
    - @(ref=Key.Equal)
    
    Names for printable keys depend on keyboard layout, while names for non-printable keys are the
    same across layouts but depend on the application language and should be localized along with
    other user-interface text.
    
    @(params)
    - key: The key to query, or @(ref=KEY_UNKNOWN)
    - scancode: The scncode of the key to query.
    
    @(returns)
    - UTF-8 encoded, null-terminated string, storing the layout-specific name of the key, or `nil`.
    
    @(remark)
    The contents of the returned string may change when a keyboard layout change event is received.
    
    @(lifetimes)
    The returned string is allocated and freed by GLFW. You should not free it yourself. It is valid
    until the library is terminated.
    
    @(thread_safety=safe)
    @(since=3.2)
*/
get_key_name :: proc "contextless" (key: Key, scancode: i32) -> cstring {
    return glfwGetKeyName(key, scancode)
}

/*
    Returns the platform-specific scancode of the specified key.
    
    This function returns the platform-specific scancode of the specified key.
    
    If the key is @(ref=KEY_UNKNOWN), or does not exist on the keyboard, this procedure will
    return `-1`.
    
    @(param)
    - key: Any named key.
    
    @(returns)
    - The platform-specific scancode for the key, or `-1` if an error occurred.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Invalid_Enum)
    - @(ref=Error.Platform_Error)
    
    @(thread_safety=safe)
    @(since=3.3)
*/
get_key_scancode :: proc "contextless" (key: Key) -> i32 {
    return glfwGetKeyScancode(key)
}

/*
    Returns the last reported state of a keyboard key for the specified window.
    
    This function returns the last state reported for the specified key to the specified window.
    The returned state is one of @(ref=Action.Press), @(ref=Action.Release).
    
    The action @(ref=Action.Repeat) is only reported to the key callback.
    
    If the @(ref=Input_Mode.Sticky_Keys), input mode is enabled, this function returns
    @(ref=Action.Press) the first time you call it for a key that was pressed, even if that key has
    already been released.
    
    The key functions deal with physical keys, with @(ref=Key) named after their use on the
    standard US keyboard layout. If you want to input text, use the Unicode character callback
    instead.
    
    The modifier bit masks are not key tokens and cannot be used with this function.
    
    **Do not use this function** to implement text input.
    
    @(params)
    - window: The desired window.
    - key: The desired key. @(ref=KEY_UNKNOWN) is not a valid key for this function.
    
    @(returns)
    - One of @(ref=Action.Press) or @(ref=Action.Release).
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Invalid_Enum)
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
get_key :: proc "contextless" (window: ^Window, key: Key) -> Action {
    return glfwGetKey(window, key)
}

/*
    Returns the last reported state of a mouse button for the specified window.
    
    This function returns the last reported for the specified mouse button to the specified window.
    The returned state is one of @(ref=Action.Press) @(ref=Action.Release).
    
    If the @(ref=Input_Mode.Sticky_Mouse_Buttons) is enabled, this function returns
    @(ref=Action.Press) the first time you call it for a mouse button that was pressed, even if
    that mouse button has already been released.
    
    @(params)
    - window: The desired window.
    - button: The desired mouse button.
    
    @(returns)
    - One of @(ref=Action.Press) or @(ref=Action.Release).
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Invalid_Enum)
    
    @(thread_safety=main_thread_only)
    @(since=1.0)
*/
get_mouse_button :: proc "contextless" (window: ^Window, button: Mouse_Button) -> Action {
    return glfwGetMouseButton(window, button)
}

/*
    Retrieves the position of the cursor relative to the content area of the window.
    
    This function returns the position of the cursor, in screen coordinates, relative to the 
    upper-left corner of the content area of the specified window.
    
    If the cursor is disabled with @(ref=Cursor_Mode.Disabled), then the cursor position is
    unbounded and limited only by the minimum and maximum values of `f64`.
    
    The coordinate can be converted to their integer equivalents with the `floor` function.
    Casting directly to an integer types only for positive coordinates, but is slightly incorrect
    for negative coordinates.
    
    @(params)
    - window: The desired window.
    
    @(returns)
    1. The x-coordinates of the cursor position, relative to the left edge of the content area.
    2. The y-coordinate of the cursor position, relative to the top edge of the content area.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
get_cursor_pos :: proc "contextless" (window: ^Window) -> (f64, f64) {
    pos_x: f64 = ---
    pos_y: f64 = ---
    glfwGetCursorPos(window, &pos_x, &pos_y)
    return pos_x, pos_y
}

/*
    Sets the position of the cursor, relative to the content area of the window.
    
    This function sets the position, in screen coordinates, of the cursor relative to the upper-left
    corner of the content area of the specified window. The window must have input focus. If the
    window does not have input focus when this function is called, it fails silently.
    
    **Do not use this function** to implement things like camera controls. GLFW already provides
    the @(ref=Cursor_Mode.Disabled) cursor mode that hides the cursor motion. See
    @(ref=set_input_mode) for more information.
    
    If the cursor mode is @(ref=Cursor_Mode.Disabled), then the cursor position is unconstrained
    and limited only by the minimum and maximum values of `f64`.
    
    @(params)
    - window: The desired window.
    - pos_x: The desired x-coordinate, relative to the left edge of the content area.
    - pos_y: The desired y-coordinate, relative to the top edge of the content area.
    
    @(errors)
    - @(ref=Error.Not_Initialized)
    - @(ref=Error.Platform_Error)
    - @(ref=Error.Feature_Unavailable) (see remark)
    
    @(remark=wayland)
    This function will only work when the cursor mode is @(ref=Cursor_Mode.Disabled). Otherwise
    it will emit @(ref=Error.Feature_Unavailable).
    
    @(thread_safety=main_thread_only)
    @(since=3.0)
*/
set_cursor_pos :: proc "contextless" (window: ^Window, pos_x: f64, pos_y: f64) {
    glfwSetCursorPos(window, pos_x, pos_y)
}

// Cursors.

create_cursor :: proc "contextless" (image: ^Image, x: i32, y: i32) -> ^Cursor {
    return glfwCreateCursor(image, x, y)
}

create_standard_cursor :: proc "contextless" (shape: Cursor_Shape) -> ^Cursor {
    return glfwCreateStandardCursor(shape)
}

destroy_cursor :: proc "contextless" (cursor: ^Cursor) {
    glfwDestroyCursor(cursor)
}

set_cursor :: proc "contextless" (window: ^Window, cursor: ^Cursor) {
    glfwSetCursor(window, cursor)
}

// More callbacks.

set_key_callback :: proc "contextless" (window: ^Window, callback: Key_Proc) -> Key_Proc {
    return glfwSetKeyCallback(window, callback)
}

set_char_callback :: proc "contextless" (window: ^Window, callback: Char_Proc) -> Char_Proc {
    return glfwSetCharCallback(window, callback)
}

set_char_mods_callback :: proc "contextless" (window: ^Window, callback: Char_Mods_Proc) -> Char_Mods_Proc {
    return glfwSetCharModsCallback(window, callback)
}

set_mouse_button_callback :: proc "contextless" (window: ^Window, callback: Mouse_Button_Proc) -> Mouse_Button_Proc {
    return glfwSetMouseButtonCallback(window, callback)
}

set_cursor_pos_callback :: proc "contextless" (window: ^Window, callback: Cursor_Pos_Proc) -> Cursor_Pos_Proc {
    return glfwSetCursorPosCallback(window, callback)
}

set_cursor_enter_callback :: proc "contextless" (window: ^Window, callback: Cursor_Enter_Proc) -> Cursor_Enter_Proc {
    return glfwSetCursorEnterCallback(window, callback)
}

set_scroll_callback :: proc "contextless" (window: ^Window, callback: Scroll_Proc) -> Scroll_Proc {
    return glfwSetScrollCallback(window, callback)
}

set_drop_callback :: proc "contextless" (window: ^Window, callback: Drop_Proc) -> Drop_Proc {
    return glfwSetDropCallback(window, callback)
}

// Joystick input.

joystick_present :: proc "contextless" (jid: Joystick) -> b32 {
    return glfwJoystickPresent(jid)
}

get_joystick_axes :: proc "contextless" (jid: Joystick) -> []f32 {
    count: i32 = ---
    axes := glfwGetJoystickAxes(jid, &count)
    return axes[:count]
}

get_joystick_buttons :: proc "contextless" (jid: Joystick) -> []Joystick_Button_State {
    count: i32 = ---
    buttons := glfwGetJoystickButtons(jid, &count)
    return buttons[:count]
}

get_joystick_hats :: proc "contextless" (jid: Joystick) -> []Hat_State {
    count: i32 = ---
    hats := glfwGetJoystickHats(jid, &count)
    return hats[:count]
}

get_joystick_name :: proc "contextless" (jid: Joystick) -> cstring {
    return glfwGetJoystickName(jid)
}

get_joystick_guid :: proc "contextless" (jid: Joystick) -> cstring {
    return glfwGetJoystickGUID(jid)
}

set_joystick_user_pointer :: proc "contextless" (jid: Joystick, pointer: rawptr) {
    glfwSetJoystickUserPointer(jid, pointer)
}

get_joystick_user_pointer :: proc "contextless" (jid: Joystick) -> rawptr {
    return glfwGetJoystickUserPointer(jid)
}

joystick_is_gamepad :: proc "contextless" (jid: Joystick) -> b32 {
    return glfwJoystickIsGamepad(jid)
}

set_joystick_callback :: proc "contextless" (callback: Joystick_Proc) -> Joystick_Proc {
    return glfwSetJoystickCallback(callback)
}

update_gamepad_mappings :: proc "contextless" (mappings: cstring) -> b32 {
    return glfwUpdateGamepadMappings(mappings)
}

get_gamepad_state :: proc "contextless" (jid: Joystick, state: ^Gamepad_State) -> (b32, Error) {
    res := glfwGetGamepadState(jid, state)
    if res <= 1 {
        return cast(b32) res, .No_Error
    }
    return false, cast(Error) res
}

// Clipboard.

set_clipboard_string :: proc "contextless" (window: ^Window, string: cstring) {
    glfwSetClipboardString(window, string)
}

get_clipboard_string :: proc "contextless" (window: ^Window) -> cstring {
    return glfwGetClipboardString(window)
}

// Time.

get_time :: proc "contextless" () -> f64 {
    return glfwGetTime()
}

set_time :: proc "contextless" (time: f64) {
    glfwSetTime(time)
}

get_timer_value :: proc "contextless" () -> u64 {
    return glfwGetTimerValue()
}

get_timer_frequency :: proc "contextless" () -> u64 {
    return glfwGetTimerFrequency()
}

// Context.

make_context_current :: proc "contextless" (window: ^Window) {
    glfwMakeContextCurrent(window)
}

get_context_current :: proc "contextless" () -> ^Window {
    return glfwGetCurrentContext()
}

swap_buffers :: proc "contextless" (window: ^Window) {
    glfwSwapBuffers(window)
}

swap_interval :: proc "contextless" (interval: i32) {
    glfwSwapInterval(interval)
}

extension_supported :: proc "contextless" (extension: cstring) -> b32 {
    return glfwExtensionSupported(extension)
}

get_proc_address :: proc "contextless" (name: cstring) -> GL_Proc {
    return glfwGetProcAddress(name)
}

// Vulkan.

vulkan_supported :: proc "contextless" () -> b32 {
    return glfwVulkanSupported()
}

get_required_instance_extensions :: proc "contextless" () -> []cstring {
    count: i32 = ---
    exts := glfwGetRequiredInstanceExtensions(&count)
    return exts[:count]
}

get_instance_proc_address :: proc "contextless" (instance: VkInstance, name: cstring) -> VK_Proc {
    return glfwGetInstanceProcAddress(instance, name)
}

get_physical_device_presentation_support :: proc "contextless" (
    instance:     VkInstance,
    device:       VkPhysicalDevice,
    queue_family: u32,
) -> b32 {
    return glfwGetPhysicalDevicePresentationSupport(instance, device, queue_family)
}
