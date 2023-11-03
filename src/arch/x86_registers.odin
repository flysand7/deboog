
package arch

import "core:intrinsics"
import "core:mem"
import "core:fmt"

X86_RFlags :: bit_set[X86_RFlags_Bits; u64]
X86_RFlags_Bits :: enum {
    CF    = 0,
    PF    = 2,
    AF    = 4,
    ZF    = 6,
    SF    = 7,
    TF    = 8, // system
    IF    = 9, // system
    DF    = 10,
    OF    = 11,
    IOPL0 = 12, // system
    IOPL1 = 13, // system
    NT    = 14, // system
    RF    = 16, // system
    VM    = 17, // system
    AC    = 18, // system
    VIF   = 19, // system
    VIP   = 20, // system
    ID    = 21, // system
}

X86_MXCSR :: bit_set[X86_MXCSR_Bits; u32]
X86_MXCSR_Bits :: enum {
    IE  = 0,
    DE  = 1,
    ZE  = 2,
    OE  = 3,
    UE  = 4,
    PE  = 5,
    DAZ = 6,
    IM  = 7,
    DM  = 8,
    ZM  = 9,
    OM  = 10,
    UM  = 11,
    PM  = 12,
    RC0 = 13,
    RC1 = 14,
    FTZ = 15,
}

X86_FSW :: bit_set[X86_FSW_Bits; u16]
X86_FSW_Bits :: enum {
    IE   = 0,
    DE   = 1,
    ZE   = 2,
    OE   = 3,
    UE   = 4,
    PE   = 5,
    SF   = 6,
    ES   = 7,
    C0   = 8,
    C1   = 9,
    C2   = 10,
    TOP0 = 11,
    TOP1 = 12,
    TOP2 = 13,
    C3   = 14,
    B    = 15,
}

X86_FCW :: bit_set[X86_FCW_Bits; u16]
X86_FCW_Bits :: enum {
    IM  = 0,
    DM  = 1,
    ZM  = 2,
    OM  = 3,
    UM  = 4,
    PM  = 5,
    PC0 = 8,
    PC1 = 9,
    RC0 = 10,
    RC1 = 11,
    X   = 12,
}

/*
    Whatever buffer is used to store general-purpose registers
*/
X86_GP_BUFFER     :: 0

/*
    Corresponds to legacy register storage used by FXSAVE.
    Contains x87 FPU, MMX and SSE registers.
*/
X86_FPU_BUFFER    :: 1

/*
    Contains SSE state.
*/
X86_SSE_BUFFER    :: 2

/*
    AVX state.
*/
X86_AVX_BUFFER    :: 3

/*
    MPX state.
*/
X86_MPX_BUFFER    :: 4

/*
    AVX-512 state.
*/
X86_AVX512_BUFFER :: 5

_ARCH_MAX_REGISTER_BUFFERS :: 6

x86_gp_regs := []Register_Desc {
    // 64-bit general-purpose registers
    {"rax",  8, 0x00, {}, nil},
    {"rbx",  8, 0x08, {}, nil},
    {"rdx",  8, 0x10, {}, nil},
    {"rcx",  8, 0x18, {}, nil},
    {"rsi",  8, 0x20, {}, nil},
    {"rdi",  8, 0x28, {}, nil},
    {"rbp",  8, 0x30, {}, nil},
    {"rsp",  8, 0x38, {}, nil},
    {"r8",   8, 0x40, {}, nil},
    {"r9",   8, 0x48, {}, nil},
    {"r10",  8, 0x50, {}, nil},
    {"r11",  8, 0x58, {}, nil},
    {"r12",  8, 0x60, {}, nil},
    {"r13",  8, 0x68, {}, nil},
    {"r14",  8, 0x70, {}, nil},
    {"r15",  8, 0x78, {}, nil},
    // 32-bit general-purpose registers. Since the architecture
    // is little-endian, we can assume the same offsets.
    // These become shadows if we're on 64-bit platform
    {"eax",  4, 0x00, {}, nil},
    {"ebx",  4, 0x08, {}, nil},
    {"edx",  4, 0x10, {}, nil},
    {"ecx",  4, 0x18, {}, nil},
    {"esi",  4, 0x20, {}, nil},
    {"edi",  4, 0x28, {}, nil},
    {"ebp",  4, 0x30, {}, nil},
    {"esp",  4, 0x38, {}, nil},
    // Only available on 64-bit platforms
    {"r8d",  4, 0x40, {}, nil},
    {"r9d",  4, 0x48, {}, nil},
    {"r10d", 4, 0x50, {}, nil},
    {"r11d", 4, 0x58, {}, nil},
    {"r12d", 4, 0x60, {}, nil},
    {"r13d", 4, 0x68, {}, nil},
    {"r14d", 4, 0x70, {}, nil},
    {"r15d", 4, 0x78, {}, nil},
    // 16-bit general-purpose registers.
    {"ax",   2, 0x00, {}, nil},
    {"bx",   2, 0x08, {}, nil},
    {"dx",   2, 0x10, {}, nil},
    {"cx",   2, 0x18, {}, nil},
    {"si",   2, 0x20, {}, nil},
    {"di",   2, 0x28, {}, nil},
    {"bp",   2, 0x30, {}, nil},
    {"sp",   2, 0x38, {}, nil},
    // 8-bit general-purpose registers
    {"al",   1, 0x00, {}, nil},
    {"bl",   1, 0x08, {}, nil},
    {"dl",   1, 0x10, {}, nil},
    {"cl",   1, 0x18, {}, nil},
    {"ah",   1, 0x01, {}, nil},
    {"bh",   1, 0x09, {}, nil},
    {"dh",   1, 0x11, {}, nil},
    {"ch",   1, 0x19, {}, nil},
}

x86_misc_regs := []Register_Desc {
    // RIP and flags are written to the same buffer as general-purpose registers
    // despite being in a different set. The reason is to be able to disable the
    // printing of these registers.
    {"rip",    8, 0x80, {}, nil},
    {"rflags", 8, 0x88, {.Special}, fmt_flags},
    // 32-bit variants
    {"eip",    4, 0x80, {}, nil},
    {"eflags", 4, 0x88, {.Special}, fmt_flags},
    // 16-bit variants
    {"ip",     2, 0x80, {}, nil},
    {"flags",  2, 0x88, {.Special}, fmt_flags},
}

/*
    Segment registers. Only FS and GS segment registers have a hidden base
    stored, because the bases for other registers are implied.
*/
x86_seg_regs := []Register_Desc {
    {"cs", 2, 0x00, {}, nil},
    {"es", 2, 0x02, {}, nil},
    {"ds", 2, 0x04, {}, nil},
    {"ss", 2, 0x06, {}, nil},
    {"fs", 2, 0x08, {}, nil},
    {"gs", 2, 0x0a, {}, nil},
    {"fs_base", size_of(uint), 0x0c+0*size_of(uint), {}, nil},
    {"gs_base", size_of(uint), 0x0c+1*size_of(uint), {}, nil},
}

/*
    x87 FPU stack registers.
*/
x86_fpu_regs := []Register_Desc {
    {"r0", 10, 0x20+0*0x10, {}, nil},
    {"r1", 10, 0x20+1*0x10, {}, nil},
    {"r2", 10, 0x20+2*0x10, {}, nil},
    {"r3", 10, 0x20+3*0x10, {}, nil},
    {"r4", 10, 0x20+4*0x10, {}, nil},
    {"r5", 10, 0x20+5*0x10, {}, nil},
    {"r6", 10, 0x20+6*0x10, {}, nil},
    {"r7", 10, 0x20+7*0x10, {}, nil},
}

/*
    MMX registers. These alias in storage to x87 FPU registers.
*/
x86_mmx_regs := []Register_Desc {
    {"mm0", 8, 0x20+0*0x10, {}, nil},
    {"mm1", 8, 0x20+1*0x10, {}, nil},
    {"mm2", 8, 0x20+2*0x10, {}, nil},
    {"mm3", 8, 0x20+3*0x10, {}, nil},
    {"mm4", 8, 0x20+4*0x10, {}, nil},
    {"mm5", 8, 0x20+5*0x10, {}, nil},
    {"mm6", 8, 0x20+6*0x10, {}, nil},
    {"mm7", 8, 0x20+7*0x10, {}, nil},
}

/*
    x87 FPU miscellaneous registers.
    ftwa is abridged ftw, meaning it's only 1 byte instead of 2.
*/
x86_fpu_misc_regs := []Register_Desc {
    {"fcw", 2, 0x00, {.Special}, fmt_fcw},
    {"fsw", 2, 0x02, {.Special}, fmt_fsw},
    {"ftwa",1, 0x04, {.Special}, nil},
    {"fop", 2, 0x06, {.Special}, nil},
    {"fip", 4, 0x08, {}, nil},
    {"fcs", 2, 0xa0, {}, nil},
    {"fdp", 4, 0x10, {}, nil},
    {"fds", 2, 0x14, {}, nil},
}

x86_mpx_regs := []Register_Desc {
    {"bnd0",   16, 0x00, {}, nil},
    {"bnd1",   16, 0x10, {}, nil},
    {"bnd2",   16, 0x20, {}, nil},
    {"bnd3",   16, 0x30, {}, nil},
    {"bndcsr", 8,  0x40, {}, nil},
}

/*
    SSE registers.
*/
x86_sse_regs := []Register_Desc {
    {"xmm0",  16, 0x00+0*0x10,  {}, nil},
    {"xmm1",  16, 0x00+1*0x10,  {}, nil},
    {"xmm2",  16, 0x00+2*0x10,  {}, nil},
    {"xmm3",  16, 0x00+3*0x10,  {}, nil},
    {"xmm4",  16, 0x00+4*0x10,  {}, nil},
    {"xmm5",  16, 0x00+5*0x10,  {}, nil},
    {"xmm6",  16, 0x00+6*0x10,  {}, nil},
    {"xmm7",  16, 0x00+7*0x10,  {}, nil},
    {"xmm8",  16, 0x00+8*0x10,  {}, nil},
    {"xmm9",  16, 0x00+9*0x10,  {}, nil},
    {"xmm10", 16, 0x00+10*0x10, {}, nil},
    {"xmm11", 16, 0x00+11*0x10, {}, nil},
    {"xmm12", 16, 0x00+12*0x10, {}, nil},
    {"xmm13", 16, 0x00+13*0x10, {}, nil},
    {"xmm14", 16, 0x00+14*0x10, {}, nil},
    {"xmm15", 16, 0x00+15*0x10, {}, nil},
}

/*
    MMX control state register, it's stored on a separate descriptor set
    because we want to treat it differently.
*/
x86_sse_misc_regs := []Register_Desc {
    {"mxcsr",      4, 0x08, {.Special}, fmt_mxcsr},
    {"mxcsr_mask", 4, 0xc0, {.Special}, fmt_mxcsr_mask},
}

/*
    AVX registers. Added 32-bit registers, which are saved by XSAVE. The low
    128 bit of these registers are stored in legacy FPU area, while the top
    bits are stored separately in a different buffer.
*/
x86_avx_regs := []Register_Desc {
    {"ymm0",  32, 0x0+0*0x10,  {.Halves}, nil},
    {"ymm1",  32, 0x0+1*0x10,  {.Halves}, nil},
    {"ymm2",  32, 0x0+2*0x10,  {.Halves}, nil},
    {"ymm3",  32, 0x0+3*0x10,  {.Halves}, nil},
    {"ymm4",  32, 0x0+4*0x10,  {.Halves}, nil},
    {"ymm5",  32, 0x0+5*0x10,  {.Halves}, nil},
    {"ymm6",  32, 0x0+6*0x10,  {.Halves}, nil},
    {"ymm7",  32, 0x0+7*0x10,  {.Halves}, nil},
    {"ymm8",  32, 0x0+8*0x10,  {.Halves}, nil},
    {"ymm9",  32, 0x0+9*0x10,  {.Halves}, nil},
    {"ymm10", 32, 0x0+10*0x10, {.Halves}, nil},
    {"ymm11", 32, 0x0+11*0x10, {.Halves}, nil},
    {"ymm12", 32, 0x0+12*0x10, {.Halves}, nil},
    {"ymm13", 32, 0x0+13*0x10, {.Halves}, nil},
    {"ymm14", 32, 0x0+14*0x10, {.Halves}, nil},
    {"ymm15", 32, 0x0+15*0x10, {.Halves}, nil},
}

/*
    AVX-512 opmask state. Stored in the same buffer as AVX-512 registers.
*/
x86_avx512_opmask_regs := []Register_Desc {
    {"k0",    8,  0x0+0*0x08, {.Special}, nil},
    {"k1",    8,  0x0+1*0x08, {.Special}, nil},
    {"k2",    8,  0x0+2*0x08, {.Special}, nil},
    {"k3",    8,  0x0+3*0x08, {.Special}, nil},
    {"k4",    8,  0x0+4*0x08, {.Special}, nil},
    {"k5",    8,  0x0+5*0x08, {.Special}, nil},
    {"k6",    8,  0x0+6*0x08, {.Special}, nil},
    {"k7",    8,  0x0+7*0x08, {.Special}, nil},
}

/*
    AVX-512 registers. The bottom 256 bits of ZMM0-15 are stored in another
    table. The tops of these registers are stored in this table. For ZMM16-32
    the full 512-bits of these registers are stored in this table.
*/
x86_avx512_regs := []Register_Desc {
    {"zmm0",  64, 0x40+0*0x20,  {.Halves}, nil},
    {"zmm1",  64, 0x40+1*0x20,  {.Halves}, nil},
    {"zmm2",  64, 0x40+2*0x20,  {.Halves}, nil},
    {"zmm3",  64, 0x40+3*0x20,  {.Halves}, nil},
    {"zmm4",  64, 0x40+4*0x20,  {.Halves}, nil},
    {"zmm5",  64, 0x40+5*0x20,  {.Halves}, nil},
    {"zmm6",  64, 0x40+6*0x20,  {.Halves}, nil},
    {"zmm7",  64, 0x40+7*0x20,  {.Halves}, nil},
    {"zmm8",  64, 0x40+8*0x20,  {.Halves}, nil},
    {"zmm9",  64, 0x40+9*0x20,  {.Halves}, nil},
    {"zmm10", 64, 0x40+10*0x20, {.Halves}, nil},
    {"zmm11", 64, 0x40+11*0x20, {.Halves}, nil},
    {"zmm12", 64, 0x40+12*0x20, {.Halves}, nil},
    {"zmm13", 64, 0x40+13*0x20, {.Halves}, nil},
    {"zmm14", 64, 0x40+14*0x20, {.Halves}, nil},
    {"zmm15", 64, 0x40+15*0x20, {.Halves}, nil},
    {"zmm16", 64, 0x40+16*0x40, {}, nil},
    {"zmm17", 64, 0x40+17*0x40, {}, nil},
    {"zmm18", 64, 0x40+18*0x40, {}, nil},
    {"zmm19", 64, 0x40+19*0x40, {}, nil},
    {"zmm20", 64, 0x40+20*0x40, {}, nil},
    {"zmm21", 64, 0x40+21*0x40, {}, nil},
    {"zmm22", 64, 0x40+22*0x40, {}, nil},
    {"zmm23", 64, 0x40+23*0x40, {}, nil},
    {"zmm24", 64, 0x40+24*0x40, {}, nil},
    {"zmm25", 64, 0x40+25*0x40, {}, nil},
    {"zmm26", 64, 0x40+26*0x40, {}, nil},
    {"zmm27", 64, 0x40+27*0x40, {}, nil},
    {"zmm28", 64, 0x40+28*0x40, {}, nil},
    {"zmm29", 64, 0x40+29*0x40, {}, nil},
    {"zmm30", 64, 0x40+30*0x40, {}, nil},
    {"zmm31", 64, 0x40+31*0x40, {}, nil},
}

/*
    TODO: AMX registers
*/
x86_amx_regs := []Register_Desc {
    {"tmm0", 0x400, 0+0*0x400, {}, nil},
    {"tmm1", 0x400, 0+1*0x400, {}, nil},
    {"tmm2", 0x400, 0+2*0x400, {}, nil},
    {"tmm3", 0x400, 0+3*0x400, {}, nil},
    {"tmm4", 0x400, 0+4*0x400, {}, nil},
    {"tmm5", 0x400, 0+5*0x400, {}, nil},
    {"tmm6", 0x400, 0+6*0x400, {}, nil},
    {"tmm7", 0x400, 0+7*0x400, {}, nil},
}

x86_gp_set := Register_Set {
    name = "General-purpose registers",
    buffer_id = X86_GP_BUFFER,
    regs = x86_gp_regs,
}

x86_misc_set := Register_Set {
    name = "Miscellaneous registers",
    buffer_id = X86_GP_BUFFER,
    regs = x86_misc_regs,
}

x86_seg_set := Register_Set {
    name = "Segment registers",
    buffer_id = X86_GP_BUFFER,
    regs = x86_seg_regs,
}

x86_fpu_set := Register_Set {
    name = "x87 FPU stack",
    buffer_id = X86_FPU_BUFFER,
    regs = x86_fpu_regs,
}

x86_fpu_misc_set := Register_Set {
    name = "x87 FPU state",
    buffer_id = X86_FPU_BUFFER,
    regs = x86_fpu_misc_regs,
}

x86_mmx_set := Register_Set {
    name = "MMX State",
    buffer_id = X86_FPU_BUFFER,
    regs = x86_mmx_regs,
}

x86_sse_set := Register_Set {
    name = "SSE State",
    buffer_id = X86_SSE_BUFFER,
    regs = x86_sse_regs,
}

x86_sse_misc_set := Register_Set {
    name = "SSE State",
    buffer_id = X86_FPU_BUFFER,
    regs = x86_sse_misc_regs,
}

x86_mpx_set := Register_Set {
    name = "MPX State",
    buffer_id = X86_MPX_BUFFER,
    regs = x86_mpx_regs,
}

x86_avx_set := Register_Set {
    name = "AVX State",
    buffer_id = X86_AVX_BUFFER,
    regs = x86_avx_regs,
    ref_set = &x86_sse_set,
}

x86_avx512_set := Register_Set {
    name = "AVX-512 State",
    buffer_id = X86_AVX512_BUFFER,
    regs = x86_avx512_regs,
    ref_set = &x86_avx_set,
}

x86_avx512_opmask_set := Register_Set {
    name = "AVX-512 opmask registers",
    buffer_id = X86_AVX512_BUFFER,
    regs = x86_avx512_opmask_regs,
}

x86_registers := []Register_Set {
    x86_gp_set,
    x86_misc_set,
    x86_seg_set,
    x86_fpu_set,
    x86_fpu_misc_set,
    x86_mmx_set,
    x86_sse_set,
    x86_sse_misc_set,
    x86_mpx_set,
    x86_avx_set,
    x86_avx512_set,
    x86_avx512_opmask_set,
}

x86_get_buffers :: proc(cpu: ^CPU, save_buffer: []u8, reg_buffers: [][]u8) {
    assert(len(reg_buffers) >= _ARCH_MAX_REGISTER_BUFFERS)
    // Assume standard XSAVE format
    if cpu_has_feature(cpu, X86_FEATURE_OSXSAVE) {
        reg_buffers[X86_FPU_BUFFER] = save_buffer[0:0xa0]
        reg_buffers[X86_SSE_BUFFER] = save_buffer[0xa0:0x120]
        return
    }
    // Read the XSAVE header, should start at 512'th byte of XSAVE area.
    XSAVE_Header :: struct {
        xstate_bv: u64,
        xcomp_bv:  u64,
    }
    xsave_header := cast(^XSAVE_Header) &save_buffer[0x200]
    for i in 3..<_ARCH_MAX_REGISTER_BUFFERS {
        component_idx := cast(u32)(i - 1)
        stored := ((xsave_header.xstate_bv >> component_idx) & 0b1) != 0
        if stored {
            buf_size, buf_offs, _, _ := intrinsics.x86_cpuid(0x0d, component_idx)
            reg_buffers[i] = save_buffer[buf_offs:buf_size]
        } else {
            reg_buffers[i] = nil
        }
    }
}

x86_init_registers :: proc(cpu: ^CPU) {
    impl_state := cast(^X86_CPU_Impl_State) cpu._impl_state
    xsave_scs  := impl_state.xsave_state_components
    for &set in x86_registers {
        set.flags &= ~{.Available}
        for &reg in set.regs {
            reg.flags &= ~{.Available, .Shadow}
        }
    }
    // TODO(flysand): Compacted XSAVE format
    if cpu_has_feature(cpu, X86_FEATURE_FPU) && .Present in xsave_scs[.X87].flags {
        x86_fpu_set.flags |= {.Available}
        x86_fpu_misc_set.flags |= {.Available}
    }
    if cpu_has_feature(cpu, X86_FEATURE_MMX) && .Present in xsave_scs[.X87].flags {
        x86_mmx_set.flags |= {.Available}
    }
    if cpu_has_feature(cpu, X86_FEATURE_SSE) && .Present in xsave_scs[.SSE].flags {
        x86_sse_set.flags |= {.Available}
    }
    if cpu_has_feature(cpu, X86_FEATURE_AVX) && .Present in xsave_scs[.AVX].flags {
        x86_avx_set.flags |= {.Available}
    }
    if cpu_has_feature(cpu, X86_FEATURE_MPX) {
        if .Present in xsave_scs[.MPX_BND].flags &&
           .Present in xsave_scs[.MPX_CFG].flags
       {
            x86_mpx_set.flags |= {.Available}
        }
    }
    if cpu_has_feature(cpu, X86_FEATURE_AVX512_F) {
        if .Present in xsave_scs[.AVX512_OP].flags &&
           .Present in xsave_scs[.AVX512_LO16].flags &&
           .Present in xsave_scs[.AVX512_HI16].flags
        {
            x86_avx512_set.flags |= {.Available}
            x86_avx512_opmask_set.flags |= {.Available}
        }
    }
    for reg in &x86_gp_set.regs {
        if reg.size == 8 {
            reg.flags |= {.Shadow, .Available}
        } else if reg.size == 16 {
            reg.flags |= {.Shadow, .Available}
        } else if reg.size == 32 {
            if cpu.bits > 32 {
                reg.flags |= {.Shadow, .Available}
            }
            if cpu.bits >= 16 {
                reg.flags |= {.Available}
            }
        }
        if reg.size == 64 && cpu.bits == 64{
            reg.flags |= {.Available}
        }
    }
    for reg in &x86_misc_set.regs {
        if reg.size == 16 {
            reg.flags |= {.Shadow, .Available}
        } else if reg.size == 32 {
            if cpu.bits > 32 {
                reg.flags |= {.Shadow, .Available}
            }
            if cpu.bits >= 16 {
                reg.flags |= {.Available}
            }
        } else if reg.size == 64 && cpu.bits == 64 {
            reg.flags |= {.Available}
        }
    }
}

fmt_flags :: proc(cpu: ^CPU, desc: ^Register_Desc, value: Register_Value, allocator: mem.Allocator) -> string {
    bits := u64(0)
    #partial switch v in value {
        case u16: bits = cast(u64) v
        case u32: bits = cast(u64) v
        case u64: bits = cast(u64) v
        case: panic("Bad size for (e/r)flags register")
    }
    flags := transmute(X86_RFlags) bits
    CF := .CF in flags? "C" : "-"
    PF := .PF in flags? "P" : "-"
    AF := .AF in flags? "A" : "-"
    ZF := .ZF in flags? "Z" : "-"
    SF := .SF in flags? "S" : "-"
    DF := .DF in flags? "D" : "-"
    OF := .OF in flags? "O" : "-"
    return fmt.aprintf("%s%s%s%s%s%s%s", CF, PF, AF, ZF, SF, DF, OF, allocator)
}

fmt_mxcsr :: proc(cpu: ^CPU, desc: ^Register_Desc, value: Register_Value, allocator: mem.Allocator) -> string {
    bits := value.(u32)
    mxcsr := transmute(X86_MXCSR) bits
    IE  := .IE  in mxcsr? "I" : "-"
    DE  := .DE  in mxcsr? "D" : "-"
    ZE  := .ZE  in mxcsr? "Z" : "-"
    OE  := .OE  in mxcsr? "O" : "-"
    UE  := .UE  in mxcsr? "U" : "-"
    PE  := .PE  in mxcsr? "P" : "-"
    DAZ := .DAZ in mxcsr? "1" : "0"
    IM  := .IM  in mxcsr? "I" : "-"
    DM  := .DM  in mxcsr? "D" : "-"
    ZM  := .ZM  in mxcsr? "Z" : "-"
    OM  := .OM  in mxcsr? "O" : "-"
    UM  := .UM  in mxcsr? "U" : "-"
    PM  := .PM  in mxcsr? "P" : "-"
    RC  := ((.RC0 in mxcsr? 0 : 1) << 1) | (.RC1 in mxcsr? 0 : 1)
    FTZ := .FTZ in mxcsr? "1" : "0"
    return fmt.aprintf("FTZ RC -masks- DAZ -flags-\n%s  %02b %s%s%s%s%s%s  %s   %s%s%s%s%s%s",
        FTZ, RC, IM, DM, ZM, OM, UM, PM, DAZ, IE, DE, ZE, OE, UE, PE, allocator)
}

fmt_mxcsr_mask :: proc(cpu: ^CPU, desc: ^Register_Desc, value: Register_Value, allocator: mem.Allocator) -> string {
    bits := value.(u32)
    if bits == 0 {
        bits = 0x0000FFBF
    }
    return fmt_mxcsr(cpu, desc, bits, allocator)
}

fmt_fsw :: proc(cpu: ^CPU, desc: ^Register_Desc, value: Register_Value, allocator: mem.Allocator) -> string {
    bits := value.(u16)
    fsw := transmute(X86_FSW) bits
    IE   := .IE   in fsw? 1 : 0
    DE   := .DE   in fsw? 1 : 0
    ZE   := .ZE   in fsw? 1 : 0
    OE   := .OE   in fsw? 1 : 0
    UE   := .UE   in fsw? 1 : 0
    PE   := .PE   in fsw? 1 : 0
    SF   := .SF   in fsw? 1 : 0
    ES   := .ES   in fsw? 1 : 0
    C0   := .C0   in fsw? 1 : 0
    C1   := .C1   in fsw? 2 : 0
    C2   := .C2   in fsw? 4 : 0
    TOP0 := .TOP0 in fsw? 1 : 0
    TOP1 := .TOP1 in fsw? 2 : 0
    TOP2 := .TOP2 in fsw? 4 : 0
    C3   := .C3   in fsw? 8 : 0
    B    := .B    in fsw? 1 : 0
    CODE := C0 | C1 | C2 | C3
    TOP  := TOP0 | TOP1 | TOP2
    return fmt.aprintf("B TOP CODE ESPUOZDI\n%b %03b %04b %b%b%b%b%b%b%b%b",
        B, TOP, CODE, ES, SF, PE, UE, OE, ZE, DE, IE, allocator)
}

fmt_fcw :: proc(cpu: ^CPU, desc: ^Register_Desc, value: Register_Value, allocator: mem.Allocator) -> string {
    bits := value.(u16)
    fcw := transmute(X86_FCW) bits
    IM  := .IM  in fcw? 1 : 0
    DM  := .DM  in fcw? 1 : 0
    ZM  := .ZM  in fcw? 1 : 0
    OM  := .OM  in fcw? 1 : 0
    UM  := .UM  in fcw? 1 : 0
    PM  := .PM  in fcw? 1 : 0
    PC0 := .PC0 in fcw? 1 : 0
    PC1 := .PC1 in fcw? 2 : 0
    RC0 := .RC0 in fcw? 1 : 0
    RC1 := .RC1 in fcw? 2 : 0
    X   := .X   in fcw? 1 : 0
    PC  := PC0 | PC1
    RC  := RC0 | RC1
    return fmt.aprintf("X RC PC PUOZDI\n%b %02b %02b %b%b%b%b%b%b",
        X, RC, PC, PM, UM, OM, ZM, DM, IM, allocator)
}
