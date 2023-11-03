
package pesticider

import "core:os"
import "core:log"

import "arch"

_ :: arch

main :: proc () {
    context.logger = logger_new(.Debug, os.stream_from_handle(os.stdout), "main")
    log.debugf("Logger set up!\n")
}
