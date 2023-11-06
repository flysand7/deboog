
package pesticider

import "core:os"
import "core:log"

import "arch"

_ :: arch

import "gui"

button_msg :: proc(element: ^gui.Element, message: gui.Message, di: int, dp: rawptr)->int {
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
    window  := gui.window_create("Main window", 400, 400, {})
    vpanel  := gui.panel_create(window, {.Panel_VLayout})
    hpanel  := gui.panel_create(vpanel, {.Panel_HLayout})
    hpanel.gap = 50
    gui.label_create(hpanel, {}, "Click this:")
    button := gui.button_create(hpanel, {}, "Click me!")
    button.msg_user = button_msg
    gui.message_loop()
}
