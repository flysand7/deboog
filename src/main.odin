
package pesticider

import "core:os"
import "core:log"

import "arch"

_ :: arch

import "gui"

button_msg :: proc(element: ^gui.Element, message: gui.Msg)->int {
    #partial switch msg in message {
        case gui.Msg_Input:
            log.debugf("Button press!")
    }
    return 0
}

main :: proc () {
    context.logger = logger_new(.Debug, os.stream_from_handle(os.stdout), "main")
    log.debugf("Logger set up!")
    gui.initialize()
    window  := gui.window_create("Main window", 400, 400, {})
    vpanel  := gui.vpanel_create(window)
    vpanel.gap = 10
    // First hpanel
    hpanel1 := gui.hpanel_create(vpanel, {.Element_HFill})
    hpanel1.gap = 50
    gui.label_create(hpanel1, {}, "Click this:")
    button := gui.button_create(hpanel1, {}, "Click me!")
    // Second hpanel
    hpanel2 := gui.hpanel_create(vpanel, {.Element_HFill})
    hpanel2.gap = 50
    gui.label_create(hpanel2, {}, "Check this out:")
    gui.checkbox_create(hpanel2, {}, true)
    // Third hpanel
    vpanel2 := gui.vpanel_create(vpanel, {.Element_HFill})
    gui.text_view_create(vpanel2, {.Element_HFill}, "Hello, world, I'm text!\nSeocnd line of text!\nThird??")
    button.msg_user = button_msg
    gui.message_loop()
}
