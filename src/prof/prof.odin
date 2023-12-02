package prof

import "core:prof/spall"

ctx: spall.Context
buffer: spall.Buffer

init :: proc() {
    ctx = spall.context_create("trace.spall")
    buffer = spall.buffer_create(make([]u8, spall.BUFFER_DEFAULT_SIZE))
}

fini :: proc() {
    spall.buffer_destroy(&ctx, &buffer)
    spall.context_destroy(&ctx)
}

@(deferred_in=_event_end)
event :: #force_inline proc(name: string, args: string = "", location := #caller_location) {
    spall._buffer_begin(&ctx, &buffer, name, args, location)
}

@(private)
_event_end :: #force_inline proc(_, _: string, _ := #caller_location) {
    spall._buffer_end(&ctx, &buffer)
}
