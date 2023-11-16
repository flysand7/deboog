
package pesticider

import "core:os"
import "core:log"

import "arch"

_ :: arch

import "gui"
import "pesticider:prof"

button_msg :: proc(element: ^gui.Element, message: gui.Msg)->int {
    #partial switch msg in message {
        case gui.Msg_Input_Clicked:
            log.debugf("Button press!")
    }
    return 0
}

main :: proc () {
    // Initialize the profiler.
    prof.init()
    prof.event(#procedure)
    // Initialize the logger.
    context.logger = logger_new(.Debug, os.stream_from_handle(os.stdout), "main")
    log.debugf("Logger set up!")
    // Initialize the GUI library.
    gui.initialize()
    window  := gui.window_create("Main window", 400, 400, {})
    vpanel  := gui.vpanel_create(window)
    vpanel.gap = 0
    // First hpanel
    hpanel1 := gui.hpanel_create(vpanel, {.Element_HFill})
    hpanel1.gap = 50
    gui.label_create(hpanel1, {}, "Click this:")
    button := gui.button_create(hpanel1, {}, "Click me!")
    // Third vpanel
    // vpanel2 := gui.vpanel_create(vpanel, {.Element_HFill})
    bytes, ok := os.read_entire_file("src/gui/gui_window.odin")
    assert(ok, "File couldn't be loaded")
    gui.text_view_create(vpanel, {.Element_HFill}, cast(string) bytes)
    // Second hpanel
    hpanel2 := gui.hpanel_create(vpanel, {.Element_HFill})
    hpanel2.gap = 50
    gui.label_create(hpanel2, {}, "Click if you read this code:")
    gui.checkbox_create(hpanel2, {}, true)
    button.msg_user = button_msg
    gui.message_loop()
    prof.fini()
}
