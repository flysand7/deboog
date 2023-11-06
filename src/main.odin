
package pesticider

import "core:os"
import "core:log"

import "arch"

_ :: arch

import "gui"

button_msg :: proc(element: ^gui.Element, message: gui.Message, di: int, dp: rawptr)->int {
    // button := cast(^gui.Button) element
    #partial switch message {
        case .Mouse_Clicked:
            log.debugf("Button press!")
    }
    return 0
}

main :: proc () {
    context.logger = logger_new(.Debug, os.stream_from_handle(os.stdout), "main")
    log.debugf("Logger set up!")
    gui.initialize()
    window := gui.window_create("Main window", 400, 400, {})
    element := gui.button_create(window, {}, "Click me!")
    element.msg_user = button_msg
    gui.message_loop()
}
