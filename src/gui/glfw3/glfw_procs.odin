//+private
package glfw

GLFW_SHARED :: #config(GLFW_SHARED, false)
GLFW_SYSTEM :: #config(GLFW_SYSTEM, false)

when GLFW_SHARED && GLFW_SYSTEM {
    #panic(
        "Do not define GLFW_SHARED and GLFW_SYSTEM at the same time!" +
        " You can't link local and system copies of the library at the same time anyway!",
    )
}

when GLFW_SHARED {
    when ODIN_OS == .Windows {
        when ODIN_ARCH == .amd64 {
            // Built with multithreaded libc.
            foreign import glfw "bin/windows_amd64_glfw3dll.lib"
        } else when ODIN_ARCH == .i386 {
            foreign import glfw "bin/windows_i386_glfw3dll.lib"
        } else {
            #panic("GLFW3 wasn't built for the current architecture.")
        }
    } else when ODIN_OS == .Linux {
        when ODIN_ARCH == .amd64 {
            foreign import glfw "bin/linux_amd64.libglfw3.so"
        } else {
            #panic("GLFW3 wasn't built for the current architecture.")
        }
    } else when ODIN_OS == .Darwin {
        when ODIN_ARCH == .amd64 {
            foreign import glfw "bin/darwin_amd64_libglfw3.dylib"
        } else when ODIN_ARCH == .arm64 {
            foreign import glfw "bin/darwin_arm64_libglfw3.dylib"
        } else {
            #panic("GLFW3 wasn't built for the current architecture.")
        }
    }
} else {
    when ODIN_OS == .Windows {
        when ODIN_ARCH == .amd64 {
            // Built with multithreaded libc.
            foreign import glfw "bin/windows_amd64_glfw3_mt.lib"
        } else when ODIN_ARCH == .i386 {
            foreign import glfw "bin/windows_i386_glfw3_mt.lib"
        } else {
            #panic("GLFW3 wasn't built for the current architecture.")
        }
    } else when ODIN_OS == .Linux {
        when ODIN_ARCH == .amd64 {
            when GLFW_SYSTEM {
                foreign import glfw "system:glfw"
            } else {
                foreign import glfw "bin/linux_amd64_libglfw3.a"
            }
        } else {
            #panic("GLFW3 wasn't built for the current architecture.")
        }
    } else when ODIN_OS == .Darwin {
        when ODIN_ARCH == .amd64 {
            foreign import glfw "bin/darwin_amd64_libglfw3.a"
        } else when ODIN_ARCH == .arm64 {
            foreign import glfw "bin/darwin_arm64_libglfw3.a"
        } else {
            #panic("GLFW3 wasn't built for the current architecture.")
        }
    }
}

@(default_calling_convention="c")
foreign glfw {
    // Library initialization and termination.
    glfwInit :: proc() -> b32 ---
    glfwTerminate :: proc() ---
    glfwInitHint :: proc(hint: Init_Hint, value: i32) ---
    glfwGetVersion :: proc(major: ^i32, minot: ^i32, revision: ^i32) ---
    glfwGetVersionString :: proc() -> cstring ---
    // Error handling.
    glfwGetError :: proc(description: ^cstring) -> Error ---
    glfwSetErrorCallback :: proc(callback: Error_Proc) -> Error_Proc ---
    // Monitors.
    glfwGetMonitors :: proc(count: ^i32) -> [^]^Monitor ---
    glfwGetPrimaryMonitor :: proc() -> ^Monitor ---
    glfwGetMonitorPos :: proc(monitor: ^Monitor, pos_x: ^i32, pos_y: ^i32) ---
    glfwGetMonitorWorkarea :: proc(
        monitor: ^Monitor,
        pos_x: ^i32,
        pos_y: ^i32,
        size_x: ^i32,
        size_y: ^i32,
    ) ---
    glfwGetMonitorPhysicalSize :: proc(
        monitor: ^Monitor,
        size_x_mm: ^i32,
        size_y_mm: ^i32,
    ) ---
    glfwGetMonitorContentScale :: proc(
        monitor: ^Monitor, 
        scale_x: ^f32,
        scale_y: ^f32,
    ) ---
    glfwGetMonitorName :: proc(monitor: ^Monitor) -> cstring ---
    glfwSetMonitorUserPointer :: proc(monitor: ^Monitor, pointer: rawptr) ---
    glfwGetMonitorUserPointer :: proc(monitor: ^Monitor) -> rawptr ---
    glfwSetMonitorCallback :: proc(callback: Monitor_Proc) -> Monitor_Proc ---
    // Video modes.
    glfwGetVideoModes :: proc(monitor: ^Monitor, count: ^i32) -> [^]Video_Mode ---
    glfwGetVideoMode :: proc(monitor: ^Monitor) -> ^Video_Mode ---
    glfwSetGamma :: proc(monitor: ^Monitor, gamma: f32) ---
    glfwGetGammaRamp :: proc(monitor: ^Monitor) -> ^Gamma_Ramp ---
    glfwSetGammaRamp :: proc(monitor: ^Monitor, ramo: ^Gamma_Ramp) ---
    glfwDefaultWindowHints :: proc() ---
    // Window.
    glfwWindowHint :: proc(hint: Window_Hint, value: i32) ---
    glfwWindowHintString :: proc(hint: Window_Hint, value: cstring) ---
    glfwCreateWindow :: proc(
        size_x:  i32,
        size_y:  i32,
        title:   cstring,
        monitor: ^Monitor,
        share:   ^Window,
    ) -> ^Window ---
    glfwDestroyWindow :: proc(window: ^Window) ---
    glfwWindowShouldClose :: proc(window: ^Window) -> b32 ---
    glfwSetWindowShouldClose :: proc(window: ^Window, should_close: b32) ---
    glfwSetWindowTitle :: proc(window: ^Window, title: cstring) ---
    glfwSetWindowIcon :: proc(window: ^Window, count: i32, images: [^]Image) ---
    glfwGetWindowPos :: proc(window: ^Window, pos_x: ^i32, pos_y: ^i32) ---
    glfwSetWindowPos :: proc(window: ^Window, pos_x: i32, pos_y: i32) ---
    glfwGetWindowSize :: proc(window: ^Window, size_x: ^i32, size_y: ^i32) ---
    glfwSetWindowSizeLimits :: proc(
        window: ^Window,
        min_size_x: i32,
        min_size_y: i32,
        max_size_x: i32,
        max_size_y: i32,
    ) ---
    glfwSetWindowAspectRatio :: proc(window: ^Window, numerator: i32, denominator: i32) ---
    glfwSetWindowSize :: proc(window: ^Window, size_x: i32, size_y: i32) ---
    glfwGetFramebufferSize :: proc(window: ^Window, size_x: ^i32, size_y: ^i32) ---
    glfwGetWindowFrameSize :: proc(
        window: ^Window,
        left:   ^i32,
        top:    ^i32,
        right:  ^i32,
        bottom: ^i32,
    ) ---
    glfwGetWindowContentScale :: proc(window: ^Window, scale_x: ^f32, scale_y: ^f32) ---
    glfwGetWindowOpacity :: proc(window: ^Window) -> f32 ---
    glfwSetWindowOpacity :: proc(window: ^Window, opacity: f32) ---
    glfwIconifyWindow :: proc(window: ^Window) ---
    glfwRestoreWindow :: proc(window: ^Window) ---
    glfwMaximizeWindow :: proc(window: ^Window) ---
    glfwShowWindow :: proc(window: ^Window) ---
    glfwHideWindow :: proc(window: ^Window) ---
    glfwFocusWindow :: proc(window: ^Window) ---
    glfwRequestWindowAttention :: proc(window: ^Window) ---
    glfwWindowMonitor :: proc(window: ^Window) -> ^Monitor ---
    glfwSetWindowMonitor :: proc(
        window: ^Window,
        monitor: ^Monitor,
        pos_x: i32,
        pos_y: i32,
        size_x: i32,
        size_y: i32,
        refresh_rate: i32,
    ) ---
    glfwGetWindowAttrib :: proc(window: ^Window, attrib: Window_Hint) -> i32 ---
    glfwSetWindowAttrib :: proc(window: ^Window, attrib: Window_Hint, value: b32) -> i32 ---
    // Callbacks.
    glfwSetWindowUserPointer :: proc(
        window: ^Window,
        pointer: rawptr,
    ) ---
    glfwGetWindowUserPointer :: proc(window: ^Window) -> rawptr ---
    glfwSetWindowPosCallback :: proc(
        window: ^Window,
        callback: Window_Pos_Proc,
    ) -> Window_Pos_Proc ---
    glfwSetWindowSizeCallback :: proc(
        window: ^Window,
        callback: Window_Size_Proc,
    ) -> Window_Size_Proc ---
    glfwSetWindowCloseCallback :: proc(
        window: ^Window,
        callback: Window_Close_Proc,
    ) -> Window_Close_Proc ---
    glfwSetWindowRefreshCallback :: proc(
        window: ^Window,
        callback: Window_Refresh_Proc,
    ) -> Window_Refresh_Proc ---
    glfwSetWindowFocusCallback :: proc(
        window: ^Window,
        callback: Window_Focus_Proc,
    ) -> Window_Focus_Proc ---
    glfwSetWindowIconifyCallback :: proc(
        window: ^Window,
        callback: Window_Iconify_Proc,
    ) -> Window_Iconify_Proc ---
    glfwSetWindowMaximizeCallback :: proc(
        window: ^Window,
        callback: Window_Maximize_Proc,
    ) -> Window_Maximize_Proc ---
    glfwSetFramebufferSizeCallback :: proc(
        window: ^Window,
        callback: Framebuffer_Size_Proc,
    ) -> Framebuffer_Size_Proc ---
    glfwSetWindowContentScaleCallback :: proc(
        window: ^Window,
        callback: Window_Content_Scale_Proc,
    ) -> Window_Content_Scale_Proc ---
    // Events.
    glfwPollEvents :: proc() ---
    glfwWaitEvents :: proc() ---
    glfwWaitEventsTimeout :: proc(timeout: f64) ---
    glfwPostEmptyEvent :: proc() ---
    // Input.
    glfwGetInputMode :: proc(window: ^Window, mode: Input_Mode) -> i32 ---
    glfwSetInputMode :: proc(window: ^Window, mode: Input_Mode, value: i32) ---
    glfwRawMouseMotionSupported :: proc() -> b32 ---
    glfwGetKeyName :: proc(key: Key, scancode: i32) -> cstring ---
    glfwGetKeyScancode :: proc(key: Key) -> i32 ---
    glfwGetKey :: proc(window: ^Window, key: Key) -> Action  ---
    glfwGetMouseButton :: proc(window: ^Window, button: Mouse_Button) -> Action ---
    glfwGetCursorPos :: proc(window: ^Window, pos_x: ^f64, pos_y: ^f64) ---
    glfwSetCursorPos :: proc(window: ^Window, pos_x: f64, pos_y: f64) ---
    // Cursors.
    glfwCreateCursor :: proc(image: ^Image, x: i32, y: i32) -> ^Cursor ---
    glfwCreateStandardCursor :: proc(shape: Cursor_Shape) -> ^Cursor ---
    glfwDestroyCursor :: proc(cursor: ^Cursor) ---
    glfwSetCursor :: proc(window: ^Window, cursor: ^Cursor) ---
    // More callbacks.
    glfwSetKeyCallback :: proc(window: ^Window, callback: Key_Proc) -> Key_Proc ---
    glfwSetCharCallback :: proc(window: ^Window, callback: Char_Proc) -> Char_Proc ---
    glfwSetCharModsCallback :: proc(window: ^Window, callback: Char_Mods_Proc) -> Char_Mods_Proc ---
    glfwSetMouseButtonCallback :: proc(window: ^Window, callback: Mouse_Button_Proc) -> Mouse_Button_Proc ---
    glfwSetCursorPosCallback :: proc(window: ^Window, callback: Cursor_Pos_Proc) -> Cursor_Pos_Proc ---
    glfwSetCursorEnterCallback :: proc(window: ^Window, callback: Cursor_Enter_Proc) -> Cursor_Enter_Proc ---
    glfwSetScrollCallback :: proc(window: ^Window, callback: Scroll_Proc) -> Scroll_Proc ---
    glfwSetDropCallback :: proc(window: ^Window, callback: Drop_Proc) -> Drop_Proc ---
    // Joystick input.
    glfwJoystickPresent :: proc(jid: Joystick) -> b32 ---
    glfwGetJoystickAxes :: proc(jid: Joystick, count: ^i32) -> [^]f32 ---
    glfwGetJoystickButtons :: proc(jid: Joystick, count: ^i32) -> [^]Joystick_Button_State ---
    glfwGetJoystickHats :: proc(jid: Joystick, count: ^i32) -> [^]Hat_State ---
    glfwGetJoystickName :: proc(jid: Joystick) -> cstring ---
    glfwGetJoystickGUID :: proc(jid: Joystick) -> cstring ---
    glfwSetJoystickUserPointer :: proc(jid: Joystick, pointer: rawptr) ---
    glfwGetJoystickUserPointer :: proc(jid: Joystick) -> rawptr ---
    glfwJoystickIsGamepad :: proc(jid: Joystick) -> b32 ---
    glfwSetJoystickCallback :: proc(callback: Joystick_Proc) -> Joystick_Proc ---
    glfwUpdateGamepadMappings :: proc(mappings: cstring) -> b32 ---
    glfwGetGamepadName :: proc(jid: Joystick) -> cstring ---
    glfwGetGamepadState :: proc(jid: Joystick, state: ^Gamepad_State) -> i32 ---
    // Clipboard.
    glfwSetClipboardString :: proc(window: ^Window, string: cstring) ---
    glfwGetClipboardString :: proc(window: ^Window) -> cstring ---
    // Time.
    glfwGetTime :: proc() -> f64 ---
    glfwSetTime :: proc(time: f64) ---
    glfwGetTimerValue :: proc() -> u64 ---
    glfwGetTimerFrequency :: proc() -> u64 ---
    // Context.
    glfwMakeContextCurrent :: proc(window: ^Window) ---
    glfwGetCurrentContext :: proc() -> ^Window ---
    glfwSwapBuffers :: proc(window: ^Window) ---
    glfwSwapInterval :: proc(interval: i32) ---
    glfwExtensionSupported :: proc(extension: cstring) -> b32 ---
    glfwGetProcAddress :: proc(proc_name: cstring) -> GL_Proc ---
    // Vulkan.
    glfwVulkanSupported :: proc() -> b32 ---
    glfwGetRequiredInstanceExtensions :: proc(count: ^i32) -> [^]cstring ---
    glfwGetInstanceProcAddress :: proc(
        instance:     VkInstance,
        name:         cstring,
    ) -> VK_Proc ---
    glfwGetPhysicalDevicePresentationSupport :: proc(
        instance:     VkInstance,
        device:       VkPhysicalDevice,
        queue_family: u32,
    ) -> b32 ---
}
