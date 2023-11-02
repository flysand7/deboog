
package pesticider

import "core:fmt"
import "core:log"
import "core:io"
import "core:time"

Logger_Data :: struct {
    name: string,
    writer: io.Writer,
}

log_level_names := map[log.Level]string {
    .Debug   = "D",
    .Info    = "I",
    .Warning = "W",
    .Error   = "E",
    .Fatal   = "F",
}

logger_proc :: proc(data: rawptr, level: log.Level, text: string, options: log.Options, location := #caller_location) {
    logger_data := cast(^Logger_Data)data
    output := logger_data.writer
    log_level := log_level_names[level]
    time_hour, time_min, time_sec := time.clock_from_time(time.now())
    fmt.wprintf(output, "[%02d:%02d:%02d][%s][%s]: %s\n",
        time_hour, time_min, time_sec, log_level, logger_data.name, text)
}

logger_new :: proc(level: log.Level, writer: io.Writer, name: string) -> log.Logger {
    logger_data := new(Logger_Data)
    logger_data.name = name
    logger_data.writer = writer
    return log.Logger {
        procedure    = logger_proc,
        data         = cast(rawptr) logger_data,
        lowest_level = level,
        options      =  {},
    }
}
