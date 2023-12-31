package gui

import glfw "vendor:glfw"
import gl   "vendor:OpenGL"

import "font"
import "render"

import "core:testing"
import "core:runtime"
import "core:fmt"

OPENGL_MAJOR :: 4
OPENGL_MINOR :: 3

glfw_error_callback :: proc "c" (error: i32, description: cstring) {
    context = runtime.default_context()
    fmt.printf("[GLFW] Error (%d): %s\n", error, description)
}

gl_severity := map[u32]string {
    gl.DEBUG_SEVERITY_NOTIFICATION = "N",
    gl.DEBUG_SEVERITY_LOW          = "L",
    gl.DEBUG_SEVERITY_MEDIUM       = "M",
    gl.DEBUG_SEVERITY_HIGH         = "H",
}

gl_debug_type := map[u32]string {
    gl.DEBUG_TYPE_ERROR               = "Error",
    gl.DEBUG_TYPE_DEPRECATED_BEHAVIOR = "Deprecated",
    gl.DEBUG_TYPE_MARKER              = "Marker",
    gl.DEBUG_TYPE_OTHER               = "Other",
    gl.DEBUG_TYPE_PERFORMANCE         = "Performance",
    gl.DEBUG_TYPE_PORTABILITY         = "Portability",
    gl.DEBUG_TYPE_UNDEFINED_BEHAVIOR  = "UB",
}

gl_debug_proc :: proc "c" (source: u32, type: u32, id: u32, severity: u32, length: i32, message: cstring, userParam: rawptr) {
    context = runtime.default_context()
    if type != gl.DEBUG_TYPE_PUSH_GROUP && type != gl.DEBUG_TYPE_POP_GROUP {
        message_str := transmute(string) (cast([^]u8)message)[:length]
        fmt.printf("[GL] [%s: %s]: %s\n", gl_severity[severity], gl_debug_type[type], message_str)
    }
}

glfw_framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
    context = runtime.default_context()
    render.tell_framebuffer_size(Vec{cast(f32) width, cast(f32) height})
}

get_monitor_dpi :: proc(monitor: glfw.MonitorHandle) -> Vec {
    mode := glfw.GetVideoMode(monitor)
    pixels_size_x := mode.width
    pixels_size_y := mode.height
    mm_size_x, mm_size_y := glfw.GetMonitorPhysicalSize(monitor)
    dpi_x := f32(pixels_size_x) * 25.4 / f32(mm_size_x)
    dpi_y := f32(pixels_size_y) * 25.4 / f32(mm_size_y)
    return Vec { dpi_x, dpi_y }
}

@(test)
test_window :: proc(t: ^testing.T) {
    glfw_major, glfw_minor, _ := glfw.GetVersion()
    assert(glfw_major >= 3 && glfw_minor >= 3, "Requires at least GLFW 3.3 to run.")
    glfw.SetErrorCallback(glfw_error_callback)
    
    glfw.Init()
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, OPENGL_MAJOR)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, OPENGL_MINOR)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
    glfw.WindowHint(glfw.CLIENT_API, glfw.OPENGL_API)
    glfw.WindowHint(glfw.OPENGL_DEBUG_CONTEXT, true)
    glfw.WindowHintString(glfw.X11_INSTANCE_NAME, "pesticider")
    glfw.WindowHintString(glfw.X11_CLASS_NAME, "floating")
    window := glfw.CreateWindow(1280, 720, "Test", nil, nil)
    glfw.SetFramebufferSizeCallback(window, glfw_framebuffer_size_callback)
    glfw.MakeContextCurrent(window)
    gl.load_up_to(OPENGL_MAJOR, OPENGL_MINOR, glfw.gl_set_proc_address)
    gl.DebugMessageCallback(gl_debug_proc, nil)
    render.tell_framebuffer_size({1280, 720})
    render.init()
    
    font.tell_monitor_dpi(get_monitor_dpi(glfw.GetPrimaryMonitor()))
    packed_font := render.make_packed_font("/usr/share/fonts/noto/NotoSerif-Medium.ttf", 9, 4096)
    surface := render.create_surface({400, 400})
    render.surface_start(&surface)
    render.rect({100, 100, 200, 200}, {1.0, 0.0, 0.5})
    render.surface_end()
    for ! glfw.WindowShouldClose(window) {
        glfw.PollEvents()
        gl.ClearColor(0.0, 0.4, 0.4, 1)
        gl.Clear(gl.COLOR_BUFFER_BIT)
        render.str("I hate kerning", {100, 100}, 1.0, {0.9, 0.7, 0.6}, packed_font)
        glfw.SwapBuffers(window)
    }
    glfw.Terminate()
}
