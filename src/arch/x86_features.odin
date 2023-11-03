
package arch

import "core:intrinsics"
import "core:slice"

x86_cpuid_max_eax := 0
x86_features: X86_Features
x86_manufacturer: string
x86_bits := 64 when size_of(int) == 8 else 32

X86_Features :: bit_set[X86_Features_Bits]
X86_Features_Bits :: enum {
    DE,
    MSR,
    XSAVE,
    FXSR,
    OSXSAVE,
    FSGSBASE,
    // Whether CPU supports the instruction sets
    FPU_Supported,
    MMX_Supported,
    SSE_Supported,
    AVX_Supported,
    AVX2_Supported,
    MPX_Supported,
    AVX512_Supported,
    // Whether CPU saves them in XSAVE format
    FPU_Saved,
    MMX_Saved,
    SSE_Saved,
    AVX_Saved,
    AVX2_Saved,
    AVX512_Saved,
    MPX_Saved,
    // Compact or normal variant of XSAVE?
    XSAVE_Compact_Supported,
}

x86_init_features :: proc() {
    // Read the maximum CPUID parameter.
    eax, ebx, ecx, edx := intrinsics.x86_cpuid(0, 0)
    manufacturer_bits := [3]u32 {ebx, edx, ecx}
    manufacturer := transmute(string) slice.to_bytes(manufacturer_bits[:])
    x86_manufacturer = manufacturer
    x86_cpuid_max_eax = cast(int) eax
    // We don't need to check CPUID max here, because the time it was implemented
    // i.e. in 486 the max CPUID was already 1.
    // Read the feature flags.
    eax, ebx, ecx, edx = intrinsics.x86_cpuid(1, 0)
    // CPUID.01H:EDX.FPU[0]: x87 FPU present on system.
    if (edx & (1 << 0)) != 0 {
        x86_features |= {.FPU_Supported}
    }
    // CPUID.01H:EDX.DE[2]: Debugging extensions.
    if (edx & (1 << 2)) != 0 {
        x86_features |= {.DE}
    }
    // CPUID.01H:EDX.MSR[5]: RDMSR/WRMSR instructions.
    if (edx & (1 << 5)) != 0 {
        x86_features |= {.MSR}
    }
    // CPUID.01H:EDX.MMX[23]: MMX Instructions.
    if (edx & (1 << 23)) != 0 {
        x86_features |= {.MMX_Supported}
    }
    // CPUID.01H:EDX.FXCR[24]: FXSAVE/FXRESTORE Instructions.
    if (edx & (1 << 24)) != 0 {
        x86_features |= {.FXSR}
    }
    // CPUID.01H:EDX.SSE[25]: SSE Instruction set.
    if (edx & (1 << 25)) != 0 {
        x86_features |= {.SSE_Supported}
    }
    // CPUID.01H:ECX.XSAVE[26]: XSAVE/XRSTOR instructions.
    if (ecx & (1 << 26)) != 0 {
        x86_features |= {.XSAVE}
    }
    // CPUID.01H:ECX.OSXAVE[27]: XSAVE enabled by the OS.
    if (ecx & (1 << 27)) != 0 {
        x86_features |= {.OSXSAVE}
    }
    // CPUID.01H:ECX.AVX[28]: AVX Instruction set.
    if (ecx & (1 << 28)) != 0 {
        x86_features |= {.AVX_Supported}
    }
    // The features that follow require Intel Core, AMD Athlon or newer
    if x86_cpuid_max_eax < 7 {
        return
    }
    eax, ebx, ecx, edx = intrinsics.x86_cpuid(7, 0)
    // CPUID.07H:EBX.FSGSBASE[0]: Access to the base of FS and GS.
    if (ebx & (1 << 0)) != 0 {
        x86_features |= {.FSGSBASE}
    }
    // CPUID.07H:EBX.AVX2[5]: AVX2 Instruction set.
    if (ebx & (1 << 5)) != 0 {
        x86_features |= {.AVX2_Supported}
    }
    // CPUID.07H:EBX.MPX[14]: MPX Instruction set.
    if (ebx & (1 << 14)) != 0 {
        x86_features |= {.MPX_Supported}
    }
    // CPUID.07H:EBX.AVX512[16]: AVX-512 Foundation.
    if (ebx & (1 << 16)) != 0 {
        x86_features |= {.AVX512_Supported}
    }
    // Check whether these registers are going to be saved in XSAVE format.
    if .OSXSAVE not_in x86_features {
        return
    }
    if x86_cpuid_max_eax < 0x0d {
        return
    }
    eax, edx = intrinsics.x86_xgetbv(0)
    if .FPU_Supported in x86_features && (eax & 0b1) != 0 {
        x86_features |= {.FPU_Saved}
    }
    if .SSE_Supported in x86_features && (eax & 0b10) != 0 {
        x86_features |= {.SSE_Saved}
    }
    if .AVX_Supported in x86_features && (eax & 0b100) != 0 {
        x86_features |= {.AVX_Saved}
    }
    if .MPX_Supported in x86_features && (eax & 0b11000) != 0 {
        x86_features |= {.MPX_Saved}
    }
    if .AVX512_Supported in x86_features && (eax & 0b11100000) != 0 {
        x86_features |= {.AVX512_Saved}
    }
    // Check the XSAVE format
    eax, ebx, ecx, edx = intrinsics.x86_cpuid(0x0d, 1)
    if (eax & 0b01) != 0 {
        x86_features |= {.XSAVE_Compact_Supported}
    }
}

