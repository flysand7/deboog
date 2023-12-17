package elf

hash :: proc(name: cstring) -> uint {
    name := transmute([^]u8) name
    h := uint(0)
    g := uint(0)
    for i := 0; name[i] != 0; i += 1 {
        h = (h << 4) + cast(uint) name[i]
        g = h & 0xf0000000
        if g != 0 {
            h ~= g >> 24
        }
        h &= ~g
    }
    return h
}
