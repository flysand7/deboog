
package arch

import "core:intrinsics"

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
    {"rax",  8, 0x00, {}},
    {"rbx",  8, 0x08, {}},
    {"rdx",  8, 0x10, {}},
    {"rcx",  8, 0x18, {}},
    {"rsi",  8, 0x20, {}},
    {"rdi",  8, 0x28, {}},
    {"rbp",  8, 0x30, {}},
    {"rsp",  8, 0x38, {}},
    {"r8",   8, 0x40, {}},
    {"r9",   8, 0x48, {}},
    {"r10",  8, 0x50, {}},
    {"r11",  8, 0x58, {}},
    {"r12",  8, 0x60, {}},
    {"r13",  8, 0x68, {}},
    {"r14",  8, 0x70, {}},
    {"r15",  8, 0x78, {}},
    // 32-bit general-purpose registers. Since the architecture
    // is little-endian, we can assume the same offsets.
    // These become shadows if we're on 64-bit platform
    {"eax",  4, 0x00, {}},
    {"ebx",  4, 0x08, {}},
    {"edx",  4, 0x10, {}},
    {"ecx",  4, 0x18, {}},
    {"esi",  4, 0x20, {}},
    {"edi",  4, 0x28, {}},
    {"ebp",  4, 0x30, {}},
    {"esp",  4, 0x38, {}},
    // Only available on 64-bit platforms
    {"r8d",  4, 0x40, {}},
    {"r9d",  4, 0x48, {}},
    {"r10d", 4, 0x50, {}},
    {"r11d", 4, 0x58, {}},
    {"r12d", 4, 0x60, {}},
    {"r13d", 4, 0x68, {}},
    {"r14d", 4, 0x70, {}},
    {"r15d", 4, 0x78, {}},
    // 16-bit general-purpose registers.
    {"ax",   2, 0x00, {}},
    {"bx",   2, 0x08, {}},
    {"dx",   2, 0x10, {}},
    {"cx",   2, 0x18, {}},
    {"si",   2, 0x20, {}},
    {"di",   2, 0x28, {}},
    {"bp",   2, 0x30, {}},
    {"sp",   2, 0x38, {}},
    // 8-bit general-purpose registers
    {"al",   1, 0x00, {}},
    {"bl",   1, 0x08, {}},
    {"dl",   1, 0x10, {}},
    {"cl",   1, 0x18, {}},
    {"ah",   1, 0x01, {}},
    {"bh",   1, 0x09, {}},
    {"dh",   1, 0x11, {}},
    {"ch",   1, 0x19, {}},
}

x86_misc_regs := []Register_Desc {
    // RIP and flags are written to the same buffer as general-purpose registers
    // despite being in a different set. The reason is to be able to disable the
    // printing of these registers.
    {"rip",    8, 0x80, {}},
    {"rflags", 8, 0x88, {}},
    // 32-bit variants
    {"eip",    4, 0x80, {}},
    {"eflags", 4, 0x88, {}},
    // 16-bit variants
    {"ip",     2, 0x80, {}},
    {"flags",  2, 0x88, {}},
}

/*
    Segment registers. Only FS and GS segment registers have a hidden base
    stored, because the bases for other registers are implied.
*/
x86_seg_regs := []Register_Desc {
    {"cs", 2, 0x00, {}},
    {"es", 2, 0x02, {}},
    {"ds", 2, 0x04, {}},
    {"ss", 2, 0x06, {}},
    {"fs", 2, 0x08, {}},
    {"gs", 2, 0x0a, {}},
    {"fs_base", size_of(uint), 0x0c+0*size_of(uint), {}},
    {"gs_base", size_of(uint), 0x0c+1*size_of(uint), {}},
}

/*
    x87 FPU stack registers.
*/
x86_fpu_regs := []Register_Desc {
    {"r0", 10, 0x20+0*0x10, {}},
    {"r1", 10, 0x20+1*0x10, {}},
    {"r2", 10, 0x20+2*0x10, {}},
    {"r3", 10, 0x20+3*0x10, {}},
    {"r4", 10, 0x20+4*0x10, {}},
    {"r5", 10, 0x20+5*0x10, {}},
    {"r6", 10, 0x20+6*0x10, {}},
    {"r7", 10, 0x20+7*0x10, {}},
}

/*
    MMX registers. These alias in storage to x87 FPU registers.
*/
x86_mmx_regs := []Register_Desc {
    {"mm0", 8, 0x20+0*0x10, {}},
    {"mm1", 8, 0x20+1*0x10, {}},
    {"mm2", 8, 0x20+2*0x10, {}},
    {"mm3", 8, 0x20+3*0x10, {}},
    {"mm4", 8, 0x20+4*0x10, {}},
    {"mm5", 8, 0x20+5*0x10, {}},
    {"mm6", 8, 0x20+6*0x10, {}},
    {"mm7", 8, 0x20+7*0x10, {}},
}

/*
    x87 FPU miscellaneous registers.
    ftwa is abridged ftw, meaning it's only 1 byte instead of 2.
*/
x86_fpu_misc_regs := []Register_Desc {
    {"fcw", 2, 0x00, {}},
    {"fsw", 2, 0x02, {}},
    {"ftwa",1, 0x04, {}},
    {"fop", 2, 0x06, {}},
    {"fip", 4, 0x08, {}},
    {"fcs", 2, 0xa0, {}},
    {"fdp", 4, 0x10, {}},
    {"fds", 2, 0x14, {}},
}

x86_mpx_regs := []Register_Desc {
    {"bnd0",   16, 0x00, {}},
    {"bnd1",   16, 0x10, {}},
    {"bnd2",   16, 0x20, {}},
    {"bnd3",   16, 0x30, {}},
    {"bndcsr", 8,  0x40, {}},
}

/*
    SSE registers.
*/
x86_sse_regs := []Register_Desc {
    {"xmm0",  16, 0x00+0*0x10,  {}},
    {"xmm1",  16, 0x00+1*0x10,  {}},
    {"xmm2",  16, 0x00+2*0x10,  {}},
    {"xmm3",  16, 0x00+3*0x10,  {}},
    {"xmm4",  16, 0x00+4*0x10,  {}},
    {"xmm5",  16, 0x00+5*0x10,  {}},
    {"xmm6",  16, 0x00+6*0x10,  {}},
    {"xmm7",  16, 0x00+7*0x10,  {}},
    {"xmm8",  16, 0x00+8*0x10,  {}},
    {"xmm9",  16, 0x00+9*0x10,  {}},
    {"xmm10", 16, 0x00+10*0x10, {}},
    {"xmm11", 16, 0x00+11*0x10, {}},
    {"xmm12", 16, 0x00+12*0x10, {}},
    {"xmm13", 16, 0x00+13*0x10, {}},
    {"xmm14", 16, 0x00+14*0x10, {}},
    {"xmm15", 16, 0x00+15*0x10, {}},
}

/*
    MMX control state register, it's stored on a separate descriptor set
    because we want to treat it differently.
*/
x86_sse_misc_regs := []Register_Desc {
    {"mxcsr",      4, 0x08, {}},
    {"mxcsr_mask", 4, 0xc0, {}},
}

/*
    AVX registers. Added 32-bit registers, which are saved by XSAVE. The low
    128 bit of these registers are stored in legacy FPU area, while the top
    bits are stored separately in a different buffer.
*/
x86_avx_regs := []Register_Desc {
    {"ymm0",  32, 0x0+0*0x10,  {.Halves}},
    {"ymm1",  32, 0x0+1*0x10,  {.Halves}},
    {"ymm2",  32, 0x0+2*0x10,  {.Halves}},
    {"ymm3",  32, 0x0+3*0x10,  {.Halves}},
    {"ymm4",  32, 0x0+4*0x10,  {.Halves}},
    {"ymm5",  32, 0x0+5*0x10,  {.Halves}},
    {"ymm6",  32, 0x0+6*0x10,  {.Halves}},
    {"ymm7",  32, 0x0+7*0x10,  {.Halves}},
    {"ymm8",  32, 0x0+8*0x10,  {.Halves}},
    {"ymm9",  32, 0x0+9*0x10,  {.Halves}},
    {"ymm10", 32, 0x0+10*0x10, {.Halves}},
    {"ymm11", 32, 0x0+11*0x10, {.Halves}},
    {"ymm12", 32, 0x0+12*0x10, {.Halves}},
    {"ymm13", 32, 0x0+13*0x10, {.Halves}},
    {"ymm14", 32, 0x0+14*0x10, {.Halves}},
    {"ymm15", 32, 0x0+15*0x10, {.Halves}},
}

/*
    AVX-512 opmask state. Stored in the same buffer as AVX-512 registers.
*/
x86_avx512_opmask_regs := []Register_Desc {
    {"k0",    8,  0x0+0*0x08, {}},
    {"k1",    8,  0x0+1*0x08, {}},
    {"k2",    8,  0x0+2*0x08, {}},
    {"k3",    8,  0x0+3*0x08, {}},
    {"k4",    8,  0x0+4*0x08, {}},
    {"k5",    8,  0x0+5*0x08, {}},
    {"k6",    8,  0x0+6*0x08, {}},
    {"k7",    8,  0x0+7*0x08, {}},
}

/*
    AVX-512 registers. The bottom 256 bits of ZMM0-15 are stored in another
    table. The tops of these registers are stored in this table. For ZMM16-32
    the full 512-bits of these registers are stored in this table.
*/
x86_avx512_regs := []Register_Desc {
    {"zmm0",  64, 0x40+0*0x20,  {.Halves}},
    {"zmm1",  64, 0x40+1*0x20,  {.Halves}},
    {"zmm2",  64, 0x40+2*0x20,  {.Halves}},
    {"zmm3",  64, 0x40+3*0x20,  {.Halves}},
    {"zmm4",  64, 0x40+4*0x20,  {.Halves}},
    {"zmm5",  64, 0x40+5*0x20,  {.Halves}},
    {"zmm6",  64, 0x40+6*0x20,  {.Halves}},
    {"zmm7",  64, 0x40+7*0x20,  {.Halves}},
    {"zmm8",  64, 0x40+8*0x20,  {.Halves}},
    {"zmm9",  64, 0x40+9*0x20,  {.Halves}},
    {"zmm10", 64, 0x40+10*0x20, {.Halves}},
    {"zmm11", 64, 0x40+11*0x20, {.Halves}},
    {"zmm12", 64, 0x40+12*0x20, {.Halves}},
    {"zmm13", 64, 0x40+13*0x20, {.Halves}},
    {"zmm14", 64, 0x40+14*0x20, {.Halves}},
    {"zmm15", 64, 0x40+15*0x20, {.Halves}},
    {"zmm16", 64, 0x40+16*0x40, {}},
    {"zmm17", 64, 0x40+17*0x40, {}},
    {"zmm18", 64, 0x40+18*0x40, {}},
    {"zmm19", 64, 0x40+19*0x40, {}},
    {"zmm20", 64, 0x40+20*0x40, {}},
    {"zmm21", 64, 0x40+21*0x40, {}},
    {"zmm22", 64, 0x40+22*0x40, {}},
    {"zmm23", 64, 0x40+23*0x40, {}},
    {"zmm24", 64, 0x40+24*0x40, {}},
    {"zmm25", 64, 0x40+25*0x40, {}},
    {"zmm26", 64, 0x40+26*0x40, {}},
    {"zmm27", 64, 0x40+27*0x40, {}},
    {"zmm28", 64, 0x40+28*0x40, {}},
    {"zmm29", 64, 0x40+29*0x40, {}},
    {"zmm30", 64, 0x40+30*0x40, {}},
    {"zmm31", 64, 0x40+31*0x40, {}},
}

/*
    TODO: AMX registers
*/
x86_amx_regs := []Register_Desc {
    {"tmm0", 0x400, 0+0*0x400, {}},
    {"tmm1", 0x400, 0+1*0x400, {}},
    {"tmm2", 0x400, 0+2*0x400, {}},
    {"tmm3", 0x400, 0+3*0x400, {}},
    {"tmm4", 0x400, 0+4*0x400, {}},
    {"tmm5", 0x400, 0+5*0x400, {}},
    {"tmm6", 0x400, 0+6*0x400, {}},
    {"tmm7", 0x400, 0+7*0x400, {}},
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
        if reg.name == "flags" || reg.name == "eflags" || reg.name == "rflags" {
            reg.flags |= {.Special}
        }
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
    for reg in &x86_fpu_misc_set.regs {
        _ = reg
        // TODO(flysand): Figure out which of these need to be special.
        // reg.flags |= {.Special}
    }
}
