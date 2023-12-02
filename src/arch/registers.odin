package arch

import "core:mem"
import "core:fmt"

Error :: enum {
    None,
    
    /* Queried feature isn't supported on the current architecture */
    Not_Supported,
    
    /* Queried feature doesn't exist */
    Not_Existent,
}

/*
    Contains architecture-independent representation of the registers available
    on the CPU. The primary purpose is to abstract the locations and names of
    the registers. Typically CPU's would have their own register save/restore
    routines which the operating systems use to feed us on request. The
    files for specific architectures will by default assume that buffers are
    populated in the same way that platform-dependent saving routine saves
    them. If the OS choses to reorder the registers for whatever reason it will
    be OS's job to make a buffer that is readable by functions here.
*/
Registers :: struct {
    sets: []Register_Set,
}

/*
    CPU's registers typically come in sets of registers (e.g. general-purpose,
    MMX, SSE, AVX etc. Which register sets are available is decided at runtime
    using CPU-specific means.
    
    buffer_id specifies the index of the buffer in which the register can be
    found. The buffer indices are assigned by each architecture separately.
*/
Register_Set :: struct {
    name:      string,
    buffer_id: int,
    regs:      []Register_Desc,
    flags:     Register_Set_Flags,
    ref_set:   ^Register_Set,
}

/*
    Flags for a given register set.
    `Available`: specifies that the set is available on a current CPU.
*/
Register_Set_Flags :: bit_set[Register_Set_Flags_Bits; u8]
Register_Set_Flags_Bits :: enum {
    Available,
}

/*
    Description of the register.
*/
Register_Desc :: struct {
    name:      string,
    size:      int,
    offset:    int,
    flags:     Register_Flags,
    formatter: proc(cpu: ^CPU, desc: ^Register_Desc, value: Register_Value, allocator: mem.Allocator) -> string,
}

/*
    Flags for register descriptor.
    
- `Shadow`:
    Specifies that an alias for another register storage and therefore doesn't
    need printing.
- `Available`:
    Specifies that the register exists on the system.
- `Special`:
    Specifies that the register needs special printing.
- `Halves`:
    Specifies that the register is split into halves. The top half is stored in
    this table, and the bottom half is stored in a register set specified by
    `ref_set` of the containing register set.
*/
Register_Flags :: bit_set[Register_Flags_Bits; u8]
Register_Flags_Bits :: enum {
    Available,
    Shadow,
    Special,
    Halves,
}

u80  :: distinct u128

// TODO(flysand): Endianness-dependent storage
u256 :: struct { lo: u128, hi: u128 }
u512 :: struct { lo: u256, hi: u256 }

Register_Value :: union {
    u8,
    u16,
    u32,
    u64,
    u80,
    u128,
    u256,
    u512,
}

/*
    How much buffers this architecture needs?
*/
MAX_REGISTER_BUFFERS :: _ARCH_MAX_REGISTER_BUFFERS

query_register_info_by_name :: proc (cpu: ^CPU, name: string) -> (^Register_Set, ^Register_Desc, int, Error) {
    found_set: ^Register_Set = nil
    found_reg: ^Register_Desc = nil
    found_idx: int = 0
    register_sets: []Register_Set
    #partial switch cpu.arch {
        case .X86: register_sets = x86_registers
        case: unimplemented()
    }
    all: for &set in register_sets {
        for &reg, idx in set.regs {
            if reg.name == name {
                found_set = &set
                found_reg = &reg
                found_idx = idx
                break all
            }
        }
    }
    if found_reg == nil {
        return nil, nil, 0, .Not_Existent
    }
    if .Available not_in found_set.flags {
        return nil, nil, 0, .Not_Supported
    }
    if .Available not_in found_reg.flags {
        return nil, nil, 0, .Not_Supported
    }
    return found_set, found_reg, found_idx, .None
}

@(private)
_reg_concat :: proc(hi: Register_Value, lo: Register_Value) -> Register_Value {
    assert(type_of(hi) == type_of(lo))
    result: Register_Value
    #partial switch t in hi {
    case u8:   result = (u16(hi.(u8)) << 8) | u16(lo.(u8))
    case u16:  result = (u32(hi.(u16)) << 16) | u32(lo.(u16))
    case u32:  result = (u64(hi.(u32)) << 32) | u64(lo.(u32))
    case u64:  result = (u128(hi.(u64)) << 64) | u128(lo.(u64))
    case u80:
        panic("Can't concatenate non-power of two registers.")
    case u128: result = u256{ hi = hi.(u128), lo = lo.(u128) }
    case u256: result = u512{ hi = hi.(u256), lo = lo.(u256) }
    case:
        panic("Unkown register sizes or register size >= max size!")
    }
    return result
}

@(private)
_reg_value_from_buffer :: proc(buf: []u8, size: int) -> Register_Value {
    reg_value: Register_Value
    switch size {
    case 1:  reg_value = (cast(^u8)   &buf[0])^
    case 2:  reg_value = (cast(^u16)  &buf[0])^
    case 4:  reg_value = (cast(^u32)  &buf[0])^
    case 8:  reg_value = (cast(^u64)  &buf[0])^
    case 10: reg_value = (cast(^u80)  &buf[0])^
    case 16: reg_value = (cast(^u128) &buf[0])^
    case 32: reg_value = (cast(^u256) &buf[0])^
    case 64: reg_value = (cast(^u512) &buf[0])^
    case:
        panic("Unhandled register size!")
    }
    return reg_value
}

@(private)
_query_register_value_by_index :: proc(save_buf: []u8, buffers: [][]u8,
    set: ^Register_Set, idx: int) -> (Register_Value, Error)
{
    if .Available not_in set.flags {
        return nil, .Not_Supported
    }
    buffer := buffers[set.buffer_id]
    reg := &set.regs[idx]
    if .Available not_in reg.flags {
        return nil, .Not_Supported
    }
    offset := reg.offset
    size   := reg.size
    if .Halves in reg.flags {
        size /= 2
    }
    reg_value := _reg_value_from_buffer(buffer[offset : offset+size], size)
    // If it's a full register we're finished, otherwise we need to load
    // the other half.
    if .Halves not_in reg.flags {
        return reg_value, .None
    }
    reg_value_lo, err := _query_register_value_by_index(save_buf, buffers, set.ref_set, idx)
    assert(err == .None, "Bad arch configuration!")
    value := _reg_concat(reg_value, reg_value_lo)
    return value, .None
}

query_register_value_by_name :: proc(cpu: ^CPU, save_buf: []u8, name: string) -> (^Register_Desc, Register_Value, Error) {
    // Get the list of buffers
    reg_buffers: [MAX_REGISTER_BUFFERS][]u8
    #partial switch cpu.arch {
        case .X86: x86_get_buffers(cpu, save_buf, reg_buffers[:])
        case: unimplemented()
    }
    // Get the register info
    set, reg, idx, err := query_register_info_by_name(cpu, name)
    if err != .None {
        return nil, nil, err
    }
    buffer := reg_buffers[set.buffer_id]
    offset := reg.offset
    size   := reg.size
    if .Halves in reg.flags {
        size /= 2
    }
    reg_value := _reg_value_from_buffer(buffer[offset : offset+size], size)
    // If it's a full register we're finished, otherwise we need to load
    // the other half.
    if .Halves not_in reg.flags {
        return nil, reg_value, .None
    }
    reg_value_lo, err2 := _query_register_value_by_index(save_buf, reg_buffers[:], set.ref_set, idx)
    assert(err2 == .None, "Bad arch configuration!")
    value := _reg_concat(reg_value, reg_value_lo)
    return reg, value, .None
}

format_register_value :: proc(cpu: ^CPU, reg: ^Register_Desc, value: Register_Value,
    allocator := context.temp_allocator) -> string
{
    // Check to see if this register is special, if so and it has a formatter,
    // call that formatter.
    if .Special in reg.flags {
        if reg.formatter != nil {
            return reg.formatter(cpu, reg, value, allocator)
        }
    }
    // Otherwise use the default formatter
    #partial switch t in value {
        case u8:
            return fmt.aprintf("%02x", t, allocator)
        case u16:
            return fmt.aprintf("%04x", t, allocator)
        case u32:
            return fmt.aprintf("%08x", t, allocator)
        case u64:
            return fmt.aprintf("%016x", t, allocator)
        case u80:
            return fmt.aprintf("%020x", t, allocator)
        case u128:
            return fmt.aprintf("%032x", t, allocator)
        case u256:
            lo := t.lo
            hi := t.hi
            return fmt.aprintf("%032x%03x", hi, lo, allocator)
        case u512:
            lo := t.lo
            hi := t.hi
            b0 := lo.lo
            b1 := lo.hi
            b2 := hi.lo
            b3 := hi.hi
            return fmt.aprintf("%032x%03x%032x%032x", b3, b2, b1, b0, allocator)
        case:
            panic("Unkown register sizes or register size >= max size!")
    }
}
