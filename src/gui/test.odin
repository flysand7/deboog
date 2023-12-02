package gui

import "core:testing"
import "core:log"

@(test)
test_window :: proc (t: ^testing.T) {
    context.logger = log.create_console_logger()
    init()
    defer fini()
    window := window_create(1280, 720, "Pesticider")
    testing.expect(t, window != nil, "Failed to make window")
    update_loop()
}

