
package x11

import "core:runtime"
import "core:log"

/*
    This bindings library provides two ways to handle errors by default. You can
    see them here.
*/
Error_Handling_Kind :: enum {
    None,
    Sync_Last_Error,
    Async_Log_Error,
}

/*
    Init default error handlers. Call this function if you want a sane error handling.
    
    If **type** is `Sync_Last_Error`, the error retrieval is synchronized and the
    procedures return the correct error in it's `Error` output. This may slow
    down the program.
    
    If **type** is `Async_Log_Error`, the error retrieval is asynchronous, the
    procedures return `.IDK` as the error and the errors are being logged using
    the context logger.
*/
default_error_handling :: proc(type: Error_Handling_Kind, logger := context.logger) {
    x11_context = runtime.default_context()
    x11_context.logger = logger
    if type == .Sync_Last_Error {
        display := XOpenDisplay(nil)
        if XSynchronize(display, true) != nil {
            panic("Failed to synchronize X11")
        }
        if !XSetErrorHandler(x11_sync_global_error_handler) {
            panic("Failed to set synchronous error handler for X11")
        }
    } else if type == .Async_Log_Error {
        if !XSetErrorHandler(x11_log_error_handler) {
            panic("Failed to set logging error handler for X11")
        }
    }
}

/*
    ... Or set a custom callback for the errors.
*/
set_error_handler :: proc(handler: #type proc "c" (display: ^Display, event: Error_Event)) -> bool {
    return cast(bool) XSetErrorHandler(handler)
}

@(private)
x11_last_error: Error = .IDK_Which

@(private)
x11_context: runtime.Context

@(private)
x11_sync_global_error_handler :: proc "c" (display: ^Display, event: Error_Event) {
    x11_last_error = event.error_code
}

@(private)
x11_log_error_handler :: proc "c" (display: ^Display, event: Error_Event) {
    context = x11_context
    buf: [1024]u8
    error_text := get_error_text(display, event.error_code, buf[:])
    log.errorf("X11 Error: %s", error_text)
}
