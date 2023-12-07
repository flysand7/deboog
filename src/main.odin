package pesticider

import "arch"

import "core:os"

_ :: arch

// import "gui"
import "src:profiler"

main :: proc () {
    context.logger = logger_new(.Debug, os.stream_from_handle(os.stdout), "main")
    profiler.init()
    // gui.init()
    // window := gui.window_create("Pesticider")
    // _ = window
    // gui.fini()
    profiler.fini()
}
