package pesticider

import "arch"

import "core:os"

_ :: arch

import "gui"
import "pesticider:prof"

main :: proc () {
    context.logger = logger_new(.Debug, os.stream_from_handle(os.stdout), "main")
    prof.init()
    gui.init()
    window := gui.window_create("Pesticider")
    _ = window
    gui.fini()
    prof.fini()
}
