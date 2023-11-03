
package arch

CPU_MAX_FEATURES :: 1024

/*
    Contains all the information about the CPU that we may want to know.
    Architecture, bits, endianness, manufacturer, supported features.
    
    The CPU is not necessarily a processor, but any real or emulated hardware.
    The reason this abstraction is so overly complicated is because we want to
    know most of this information at runtime and it's not enough to just
    have different versions of this debugger compiled for every architecture
    and limit it to just that architecture.
    
    Being able to debug apps running in a virtual machine is a really useful
    feature that we want to support here.
*/
CPU :: struct {
    arch:          Arch,
    bits:          u8,
    endian:        Endian,
    manufacturer:  string,
    features:      [(CPU_MAX_FEATURES+63)/64]u64,
    feature_names: [(CPU_MAX_FEATURES+63)/64]string,
    _impl_state:   rawptr,
}

Arch :: enum u8 {
    X86,
    ARM32,
    ARM64,
}

Endian :: enum u8 {
    Little,
    Big,
}

/*
    Detect Host's CPU information. Used for native debugging.
*/
cpu_get_host :: proc() -> CPU {
    host_arch:   Arch
    host_bits:   u8
    host_endian: Endian
    #partial switch ODIN_ARCH {
        case .amd64: fallthrough
        case .i386:  host_arch = .X86
        case .arm32: host_arch = .ARM32
        case .arm64: host_arch = .ARM64
        case: panic("Native debugging not supported on architecture set by ODIN_ARCH")
    }
    #partial switch ODIN_ENDIAN {
        case .Big:    host_endian = .Big
        case .Little: host_endian = .Little
        case: panic("Unknown endianness")
    }
    when size_of(int) == 4 {
        host_bits = 32
    } else when size_of(int) == 8 {
        host_bits = 64
    } else {
        panic("Native debugging only supported on 32 and 64-bit machines")
    }
    cpu: CPU
    cpu.arch = host_arch
    cpu.bits = host_bits
    cpu.endian = host_endian
    #partial switch host_arch {
        case .X86: x86_learn_cpu(&cpu)
        case: unimplemented()
    }
    return cpu
}

cpu_has_feature :: proc(cpu: ^CPU, #any_int idx: int) -> bool {
    assert(0 <= idx && idx < CPU_MAX_FEATURES, "Bad feature index")
    feature_word := cast(u8) (idx / size_of(u64))
    feature_offs := cast(u8) (idx % size_of(u64))
    return ((cpu.features[feature_word] >> feature_offs) & 0b1) != 0
}

@(private)
cpu_set_feature :: proc(cpu: ^CPU, #any_int idx: int) {
    assert(0 <= idx && idx < CPU_MAX_FEATURES, "Bad feature index")
    feature_word := cast(u8) (idx / size_of(u64))
    feature_offs := cast(u8) (idx % size_of(u64))
    cpu.features[feature_word] |= (1<<feature_offs)
}

@(private)
cpu_reset_feature :: proc(cpu: ^CPU, #any_int idx: int) {
    assert(0 <= idx && idx < CPU_MAX_FEATURES, "Bad feature index")
    feature_word := cast(u8) (idx / size_of(u64))
    feature_offs := cast(u8) (idx % size_of(u64))
    cpu.features[feature_word] &= ~(1<<feature_offs)
}
