package arch

import "core:intrinsics"
import "core:strings"
import "core:slice"

/*
    Information about where different register states are saved in XSAVE
    buffer. We'll need to retrieve them later, this will help us.
*/
X86_State_Component :: enum u32 {
    X87         = 0,
    SSE         = 1,
    AVX         = 2,
    MPX_BND     = 3,
    MPX_CFG     = 4,
    AVX512_OP   = 5,
    AVX512_LO16 = 6,
    AVX512_HI16 = 7,
    PT          = 8,
    PKRU        = 9,
    PASID       = 10,
    CET_U       = 11,
    CET_S       = 12,
    HDC         = 13,
    UINTR       = 14,
    LBR         = 15,
    HWP         = 16,
    AMX_CFG     = 17,
    AMX_TILE    = 18,
    APX         = 19,
    LWP         = 62,
}

X86_State_Component_Info :: struct {
    size: u32,
    offs: u32,
    flags: X86_State_Component_Flags,
}

X86_State_Component_Flags :: bit_set[X86_State_Component_Flags_Bits; u8]
X86_State_Component_Flags_Bits :: enum {
    Supervisor,
    Align64,
    Present,
}

X86_XSAVE_Feature_Flags :: bit_set[X86_XSAVE_Feature_Flags_Bits; u32]
X86_XSAVE_Feature_Flags_Bits :: enum {
    XSAVEOPT    = 0,
    XSAVEC      = 1,
    XGETBV_ECX1 = 2,
    XSS         = 3,
    XFD         = 4,
}

/*
    The state that isn't visible to the rest of the program, but used in other
    x86 modules.
*/
X86_CPU_Impl_State :: struct {
    xsave_state_components: #sparse [X86_State_Component]X86_State_Component_Info,
    xsave_feature_flags: X86_XSAVE_Feature_Flags,
    xsave_buffer_size: u32,
}

/*
    We'll be table-driving most of the CPUID features. It's easier to program
    CPU features that way.
*/
X86_Feature_Desc :: struct {
    leaf: u32,
    func: u32,
    dest: enum u8 {
        EAX,
        EBX,
        ECX,
        EDX,
    },
    bit:  u8,
    feature: u8,
}

X86_FEATURE_FPU                 :: u8(0)
X86_FEATURE_VME                 :: u8(1)
X86_FEATURE_DE                  :: u8(2)
X86_FEATURE_PSE                 :: u8(3)
X86_FEATURE_TSC                 :: u8(4)
X86_FEATURE_MSR                 :: u8(5)
X86_FEATURE_PAE                 :: u8(6)
X86_FEATURE_MCE                 :: u8(7)
X86_FEATURE_CX8                 :: u8(8)
X86_FEATURE_APIC                :: u8(9)
X86_FEATURE_SEP                 :: u8(10)
X86_FEATURE_MTRR                :: u8(11)
X86_FEATURE_PGE                 :: u8(12)
X86_FEATURE_MCA                 :: u8(13)
X86_FEATURE_CMOV                :: u8(14)
X86_FEATURE_PAT                 :: u8(15)
X86_FEATURE_PSE_36              :: u8(16)
X86_FEATURE_PSN                 :: u8(17)
X86_FEATURE_CLFLSH              :: u8(18)
X86_FEATURE_DS                  :: u8(19)
X86_FEATURE_ACPI                :: u8(20)
X86_FEATURE_MMX                 :: u8(21)
X86_FEATURE_FXSR                :: u8(22)
X86_FEATURE_SSE                 :: u8(23)
X86_FEATURE_SSE2                :: u8(24)
X86_FEATURE_SS                  :: u8(25)
X86_FEATURE_HTT                 :: u8(26)
X86_FEATURE_TM                  :: u8(27)
X86_FEATURE_IA64                :: u8(28)
X86_FEATURE_PBE                 :: u8(29)
X86_FEATURE_SSE3                :: u8(30)
X86_FEATURE_PCLMULQDQ           :: u8(31)
X86_FEATURE_DTES64              :: u8(32)
X86_FEATURE_MONITOR             :: u8(33)
X86_FEATURE_DS_CPL              :: u8(34)
X86_FEATURE_VMX                 :: u8(35)
X86_FEATURE_SMX                 :: u8(36)
X86_FEATURE_EST                 :: u8(37)
X86_FEATURE_TM2                 :: u8(38)
X86_FEATURE_SSSE3               :: u8(39)
X86_FEATURE_CNTX_ID             :: u8(40)
X86_FEATURE_SDBG                :: u8(41)
X86_FEATURE_FMA                 :: u8(42)
X86_FEATURE_CX16                :: u8(43)
X86_FEATURE_XPTR                :: u8(44)
X86_FEATURE_PDCM                :: u8(45)
X86_FEATURE_PCID                :: u8(46)
X86_FEATURE_DCA                 :: u8(47)
X86_FEATURE_SSE4_1              :: u8(48)
X86_FEATURE_SSE4_2              :: u8(49)
X86_FEATURE_X2APIC              :: u8(50)
X86_FEATURE_MOVBE               :: u8(51)
X86_FEATURE_POPCNT              :: u8(52)
X86_FEATURE_TSC_DEADLINE        :: u8(53)
X86_FEATURE_AES_NI              :: u8(54)
X86_FEATURE_XSAVE               :: u8(55)
X86_FEATURE_OSXSAVE             :: u8(56)
X86_FEATURE_AVX                 :: u8(57)
X86_FEATURE_F16C                :: u8(58)
X86_FEATURE_RDRND               :: u8(59)
X86_FEATURE_HYPERVISOR          :: u8(60)
X86_FEATURE_FSGSBASE            :: u8(61)
X86_FEATURE_SGX                 :: u8(62)
X86_FEATURE_BMI1                :: u8(63)
X86_FEATURE_HLE                 :: u8(64)
X86_FEATURE_AVX2                :: u8(65)
X86_FEATURE_FDP_EXCPN_ONLY      :: u8(66)
X86_FEATURE_SMEP                :: u8(67)
X86_FEATURE_BMI2                :: u8(68)
X86_FEATURE_ERMS                :: u8(69)
X86_FEATURE_INVPCID             :: u8(70)
X86_FEATURE_RTM                 :: u8(71)
X86_FEATURE_RDT_M               :: u8(72)
X86_FEATURE_FPU_CSDS_DEPRECATED :: u8(73)
X86_FEATURE_MPX                 :: u8(74)
X86_FEATURE_RDT_A               :: u8(75)
X86_FEATURE_AVX512_F            :: u8(76)
X86_FEATURE_AVX512_DQ           :: u8(77)
X86_FEATURE_RDSEED              :: u8(78)
X86_FEATURE_ADX                 :: u8(79)
X86_FEATURE_SMAP                :: u8(80)
X86_FEATURE_AVX512_IFMA         :: u8(81)
X86_FEATURE_CLFLUSHOPT          :: u8(82)
X86_FEATURE_CLWB                :: u8(83)
X86_FEATURE_PT                  :: u8(84)
X86_FEATURE_AVX512_PF           :: u8(85)
X86_FEATURE_AVX512_ER           :: u8(86)
X86_FEATURE_AVX512_CD           :: u8(87)
X86_FEATURE_SHA                 :: u8(88)
X86_FEATURE_AVX512_BW           :: u8(89)
X86_FEATURE_AVX512_VL           :: u8(90)
X86_FEATURE_PREFETCHWT1         :: u8(91)
X86_FEATURE_AVX512_VBMI         :: u8(92)
X86_FEATURE_UMIP                :: u8(93)
X86_FEATURE_PKU                 :: u8(94)
X86_FEATURE_OSPKE               :: u8(95)
X86_FEATURE_WAITPKG             :: u8(96)
X86_FEATURE_AVX512_VBMI2        :: u8(97)
X86_FEATURE_CET_SS              :: u8(98)
X86_FEATURE_GFNI                :: u8(99)
X86_FEATURE_VAES                :: u8(100)
X86_FEATURE_VPCLMULQDQ          :: u8(101)
X86_FEATURE_AVX512_VNNI         :: u8(102)
X86_FEATURE_AVX512_BITALG       :: u8(103)
X86_FEATURE_TME_EN              :: u8(104)
X86_FEATURE_AVX512_VPOPCNTDQ    :: u8(105)
X86_FEATURE_LA57                :: u8(106)
X86_FEATURE_MAWAU               :: u8(107)
X86_FEATURE_RDPID               :: u8(108)
X86_FEATURE_KL                  :: u8(109)
X86_FEATURE_BUS_LOCK_DETECT     :: u8(110)
X86_FEATURE_CLDEMOTE            :: u8(111)
X86_FEATURE_MOVDIRI             :: u8(112)
X86_FEATURE_MOVDIR64B           :: u8(113)
X86_FEATURE_ENQCMD              :: u8(114)
X86_FEATURE_SGX_LC              :: u8(115)
X86_FEATURE_PKS                 :: u8(116)
X86_FEATURE_SGX_KEYS            :: u8(117)
X86_FEATURE_AVX512_4VNNIW       :: u8(118)
X86_FEATURE_AVX512_4FMAPS       :: u8(119)
X86_FEATURE_FSRM                :: u8(120)
X86_FEATURE_UINTR               :: u8(121)
X86_FEATURE_AVX512_VP2INTERSECT :: u8(122)
X86_FEATURE_SRBDS_CTRL          :: u8(123)
X86_FEATURE_MD_CLEAR            :: u8(124)
X86_FEATURE_RTM_ALWAYS_ABORT    :: u8(125)
X86_FEATURE_SERIALIZE           :: u8(126)
X86_FEATURE_HYBRID              :: u8(127)
X86_FEATURE_TSXLDTRK            :: u8(128)
X86_FEATURE_PCONFIG             :: u8(129)
X86_FEATURE_LBR                 :: u8(130)
X86_FEATURE_CET_IBT             :: u8(131)
X86_FEATURE_AMX_BF16            :: u8(132)
X86_FEATURE_AVX512_FP16         :: u8(133)
X86_FEATURE_AMX_TILE            :: u8(134)
X86_FEATURE_AMX_INT8            :: u8(135)
X86_FEATURE_IBRS                :: u8(136)
X86_FEATURE_STIBP               :: u8(137)
X86_FEATURE_SSBD                :: u8(138)
X86_FEATURE_SHA512              :: u8(139)
X86_FEATURE_SM3                 :: u8(140)
X86_FEATURE_SM4                 :: u8(141)
X86_FEATURE_RAO_INT             :: u8(142)
X86_FEATURE_AVX_VNNI            :: u8(143)
X86_FEATURE_AVX512_BF16         :: u8(144)
X86_FEATURE_LASS                :: u8(145)
X86_FEATURE_CMDCCADD            :: u8(146)
X86_FEATURE_ARCHPERFMONEXT      :: u8(147)
X86_FEATURE_FZRM                :: u8(148)
X86_FEATURE_FSRS                :: u8(149)
X86_FEATURE_RSRCS               :: u8(150)
X86_FEATURE_FRED                :: u8(151)
X86_FEATURE_LKGS                :: u8(152)
X86_FEATURE_WRMSRNS             :: u8(153)
X86_FEATURE_AMX_FP16            :: u8(154)
X86_FEATURE_HRESET              :: u8(155)
X86_FEATURE_AVX_IFMA            :: u8(156)
X86_FEATURE_LAM                 :: u8(157)
X86_FEATURE_MSRLIST             :: u8(158)
X86_FEATURE_PBNDKB              :: u8(159)
X86_FEATURE_AVX_VNNI_INT8       :: u8(160)
X86_FEATURE_AMX_AMX_COMPLEX     :: u8(161)
X86_FEATURE_AVX_NE_CONVERT      :: u8(162)
X86_FEATURE_AVX_VNNI_INT16      :: u8(163)
X86_FEATURE_PREFETCHI           :: u8(164)
X86_FEATURE_USER_MSR            :: u8(165)
X86_FEATURE_CET_SSS             :: u8(166)
X86_FEATURE_AVX10               :: u8(167)
X86_FEATURE_APX_F               :: u8(168)

x86_features := []X86_Feature_Desc {
    /* Leaf 01H, Function 00H, EDX */
    { 0x01, 0x00, .EDX, 0,  X86_FEATURE_FPU },
    { 0x01, 0x00, .EDX, 1,  X86_FEATURE_VME },
    { 0x01, 0x00, .EDX, 2,  X86_FEATURE_DE },
    { 0x01, 0x00, .EDX, 3,  X86_FEATURE_PSE },
    { 0x01, 0x00, .EDX, 4,  X86_FEATURE_TSC },
    { 0x01, 0x00, .EDX, 5,  X86_FEATURE_MSR },
    { 0x01, 0x00, .EDX, 6,  X86_FEATURE_PAE },
    { 0x01, 0x00, .EDX, 7,  X86_FEATURE_MCE },
    { 0x01, 0x00, .EDX, 8,  X86_FEATURE_CX8 },
    { 0x01, 0x00, .EDX, 9,  X86_FEATURE_APIC },
    { 0x01, 0x00, .EDX, 11, X86_FEATURE_SEP },
    { 0x01, 0x00, .EDX, 12, X86_FEATURE_MTRR },
    { 0x01, 0x00, .EDX, 13, X86_FEATURE_PGE },
    { 0x01, 0x00, .EDX, 14, X86_FEATURE_MCA },
    { 0x01, 0x00, .EDX, 15, X86_FEATURE_CMOV },
    { 0x01, 0x00, .EDX, 16, X86_FEATURE_PAT },
    { 0x01, 0x00, .EDX, 17, X86_FEATURE_PSE_36 },
    { 0x01, 0x00, .EDX, 18, X86_FEATURE_PSN },
    { 0x01, 0x00, .EDX, 19, X86_FEATURE_CLFLSH },
    { 0x01, 0x00, .EDX, 20, X86_FEATURE_DS },
    { 0x01, 0x00, .EDX, 21, X86_FEATURE_ACPI },
    { 0x01, 0x00, .EDX, 22, X86_FEATURE_MMX },
    { 0x01, 0x00, .EDX, 23, X86_FEATURE_FXSR },
    { 0x01, 0x00, .EDX, 24, X86_FEATURE_SSE },
    { 0x01, 0x00, .EDX, 25, X86_FEATURE_SSE2 },
    { 0x01, 0x00, .EDX, 26, X86_FEATURE_SS },
    { 0x01, 0x00, .EDX, 27, X86_FEATURE_HTT },
    { 0x01, 0x00, .EDX, 28, X86_FEATURE_TM },
    { 0x01, 0x00, .EDX, 29, X86_FEATURE_IA64 },
    { 0x01, 0x00, .EDX, 30, X86_FEATURE_PBE },
    /* Leaf 01H, Function 00H, ECX */
    { 0x01, 0x00, .ECX, 0,  X86_FEATURE_SSE3 },
    { 0x01, 0x00, .ECX, 1,  X86_FEATURE_PCLMULQDQ },
    { 0x01, 0x00, .ECX, 2,  X86_FEATURE_DTES64 },
    { 0x01, 0x00, .ECX, 3,  X86_FEATURE_MONITOR },
    { 0x01, 0x00, .ECX, 4,  X86_FEATURE_DS_CPL },
    { 0x01, 0x00, .ECX, 5,  X86_FEATURE_VMX },
    { 0x01, 0x00, .ECX, 6,  X86_FEATURE_SMX },
    { 0x01, 0x00, .ECX, 7,  X86_FEATURE_EST },
    { 0x01, 0x00, .ECX, 8,  X86_FEATURE_TM2 },
    { 0x01, 0x00, .ECX, 9,  X86_FEATURE_SSSE3 },
    { 0x01, 0x00, .ECX, 10, X86_FEATURE_CNTX_ID },
    { 0x01, 0x00, .ECX, 11, X86_FEATURE_SDBG },
    { 0x01, 0x00, .ECX, 12, X86_FEATURE_FMA },
    { 0x01, 0x00, .ECX, 13, X86_FEATURE_CX16 },
    { 0x01, 0x00, .ECX, 14, X86_FEATURE_XPTR },
    { 0x01, 0x00, .ECX, 15, X86_FEATURE_PDCM },
    { 0x01, 0x00, .ECX, 17, X86_FEATURE_PCID },
    { 0x01, 0x00, .ECX, 18, X86_FEATURE_DCA },
    { 0x01, 0x00, .ECX, 19, X86_FEATURE_SSE4_1 },
    { 0x01, 0x00, .ECX, 20, X86_FEATURE_SSE4_2 },
    { 0x01, 0x00, .ECX, 21, X86_FEATURE_X2APIC },
    { 0x01, 0x00, .ECX, 22, X86_FEATURE_MOVBE },
    { 0x01, 0x00, .ECX, 23, X86_FEATURE_POPCNT },
    { 0x01, 0x00, .ECX, 24, X86_FEATURE_TSC_DEADLINE },
    { 0x01, 0x00, .ECX, 25, X86_FEATURE_AES_NI },
    { 0x01, 0x00, .ECX, 26, X86_FEATURE_XSAVE },
    { 0x01, 0x00, .ECX, 27, X86_FEATURE_OSXSAVE },
    { 0x01, 0x00, .ECX, 28, X86_FEATURE_AVX },
    { 0x01, 0x00, .ECX, 29, X86_FEATURE_F16C },
    { 0x01, 0x00, .ECX, 30, X86_FEATURE_RDRND },
    { 0x01, 0x00, .ECX, 31, X86_FEATURE_HYPERVISOR },
    /* Leaf 07H, Function 00H, EBX */
    { 0x07, 0x00, .EBX, 0,  X86_FEATURE_FSGSBASE },
    { 0x07, 0x00, .EBX, 2,  X86_FEATURE_SGX },
    { 0x07, 0x00, .EBX, 3,  X86_FEATURE_BMI1 },
    { 0x07, 0x00, .EBX, 4,  X86_FEATURE_HLE },
    { 0x07, 0x00, .EBX, 5,  X86_FEATURE_AVX2 },
    { 0x07, 0x00, .EBX, 6,  X86_FEATURE_FDP_EXCPN_ONLY },
    { 0x07, 0x00, .EBX, 7,  X86_FEATURE_SMEP },
    { 0x07, 0x00, .EBX, 8,  X86_FEATURE_BMI2 },
    { 0x07, 0x00, .EBX, 9,  X86_FEATURE_ERMS },
    { 0x07, 0x00, .EBX, 10, X86_FEATURE_INVPCID },
    { 0x07, 0x00, .EBX, 11, X86_FEATURE_RTM },
    { 0x07, 0x00, .EBX, 12, X86_FEATURE_RDT_M },
    { 0x07, 0x00, .EBX, 13, X86_FEATURE_FPU_CSDS_DEPRECATED },
    { 0x07, 0x00, .EBX, 14, X86_FEATURE_MPX },
    { 0x07, 0x00, .EBX, 15, X86_FEATURE_RDT_A },
    { 0x07, 0x00, .EBX, 16, X86_FEATURE_AVX512_F },
    { 0x07, 0x00, .EBX, 17, X86_FEATURE_AVX512_DQ },
    { 0x07, 0x00, .EBX, 18, X86_FEATURE_RDSEED },
    { 0x07, 0x00, .EBX, 19, X86_FEATURE_ADX },
    { 0x07, 0x00, .EBX, 20, X86_FEATURE_SMAP },
    { 0x07, 0x00, .EBX, 21, X86_FEATURE_AVX512_IFMA },
    { 0x07, 0x00, .EBX, 22, X86_FEATURE_CLFLUSHOPT },
    { 0x07, 0x00, .EBX, 23, X86_FEATURE_CLWB },
    { 0x07, 0x00, .EBX, 24, X86_FEATURE_PT },
    { 0x07, 0x00, .EBX, 25, X86_FEATURE_AVX512_PF },
    { 0x07, 0x00, .EBX, 26, X86_FEATURE_AVX512_ER },
    { 0x07, 0x00, .EBX, 27, X86_FEATURE_AVX512_CD },
    { 0x07, 0x00, .EBX, 28, X86_FEATURE_SHA },
    { 0x07, 0x00, .EBX, 29, X86_FEATURE_AVX512_BW },
    { 0x07, 0x00, .EBX, 30, X86_FEATURE_AVX512_VL },
    /* Leaf 07H, Function 00H, ECX */
    { 0x07, 0x00, .ECX, 0,  X86_FEATURE_PREFETCHWT1 },
    { 0x07, 0x00, .ECX, 1,  X86_FEATURE_AVX512_VBMI },
    { 0x07, 0x00, .ECX, 2,  X86_FEATURE_UMIP },
    { 0x07, 0x00, .ECX, 3,  X86_FEATURE_PKU },
    { 0x07, 0x00, .ECX, 4,  X86_FEATURE_OSPKE },
    { 0x07, 0x00, .ECX, 5,  X86_FEATURE_WAITPKG },
    { 0x07, 0x00, .ECX, 6,  X86_FEATURE_AVX512_VBMI2 },
    { 0x07, 0x00, .ECX, 7,  X86_FEATURE_CET_SS },
    { 0x07, 0x00, .ECX, 8,  X86_FEATURE_GFNI },
    { 0x07, 0x00, .ECX, 9,  X86_FEATURE_VAES },
    { 0x07, 0x00, .ECX, 10, X86_FEATURE_VPCLMULQDQ },
    { 0x07, 0x00, .ECX, 11, X86_FEATURE_AVX512_VNNI },
    { 0x07, 0x00, .ECX, 12, X86_FEATURE_AVX512_BITALG },
    { 0x07, 0x00, .ECX, 13, X86_FEATURE_TME_EN },
    { 0x07, 0x00, .ECX, 14, X86_FEATURE_AVX512_VPOPCNTDQ },
    { 0x07, 0x00, .ECX, 16, X86_FEATURE_LA57 },
    { 0x07, 0x00, .ECX, 17, X86_FEATURE_MAWAU },
    { 0x07, 0x00, .ECX, 18, X86_FEATURE_RDPID },
    { 0x07, 0x00, .ECX, 19, X86_FEATURE_KL },
    { 0x07, 0x00, .ECX, 20, X86_FEATURE_BUS_LOCK_DETECT },
    { 0x07, 0x00, .ECX, 21, X86_FEATURE_CLDEMOTE },
    { 0x07, 0x00, .ECX, 22, X86_FEATURE_MOVDIRI },
    { 0x07, 0x00, .ECX, 23, X86_FEATURE_MOVDIR64B },
    { 0x07, 0x00, .ECX, 24, X86_FEATURE_ENQCMD },
    { 0x07, 0x00, .ECX, 25, X86_FEATURE_SGX_LC },
    { 0x07, 0x00, .ECX, 26, X86_FEATURE_PKS },
    /* Leaf 07H, Function 00H, EDX */
    { 0x07, 0x00, .EDX, 1,  X86_FEATURE_SGX_KEYS },
    { 0x07, 0x00, .EDX, 2,  X86_FEATURE_AVX512_4VNNIW },
    { 0x07, 0x00, .EDX, 3,  X86_FEATURE_AVX512_4FMAPS },
    { 0x07, 0x00, .EDX, 4,  X86_FEATURE_FSRM },
    { 0x07, 0x00, .EDX, 5,  X86_FEATURE_UINTR },
    { 0x07, 0x00, .EDX, 8,  X86_FEATURE_AVX512_VP2INTERSECT },
    { 0x07, 0x00, .EDX, 9,  X86_FEATURE_SRBDS_CTRL },
    { 0x07, 0x00, .EDX, 10, X86_FEATURE_MD_CLEAR },
    { 0x07, 0x00, .EDX, 11, X86_FEATURE_RTM_ALWAYS_ABORT },
    { 0x07, 0x00, .EDX, 14, X86_FEATURE_SERIALIZE },
    { 0x07, 0x00, .EDX, 15, X86_FEATURE_HYBRID },
    { 0x07, 0x00, .EDX, 16, X86_FEATURE_TSXLDTRK },
    { 0x07, 0x00, .EDX, 18, X86_FEATURE_PCONFIG },
    { 0x07, 0x00, .EDX, 19, X86_FEATURE_LBR },
    { 0x07, 0x00, .EDX, 20, X86_FEATURE_CET_IBT },
    { 0x07, 0x00, .EDX, 22, X86_FEATURE_AMX_BF16 },
    { 0x07, 0x00, .EDX, 23, X86_FEATURE_AVX512_FP16 },
    { 0x07, 0x00, .EDX, 24, X86_FEATURE_AMX_TILE },
    { 0x07, 0x00, .EDX, 25, X86_FEATURE_AMX_INT8 },
    { 0x07, 0x00, .EDX, 26, X86_FEATURE_IBRS },
    { 0x07, 0x00, .EDX, 27, X86_FEATURE_STIBP },
    { 0x07, 0x00, .EDX, 31, X86_FEATURE_SSBD },
    /* Leaf 07H, Function 01H, EAX */
    { 0x07, 0x01, .EAX, 0,  X86_FEATURE_SHA512 },
    { 0x07, 0x01, .EAX, 1,  X86_FEATURE_SM3 },
    { 0x07, 0x01, .EAX, 2,  X86_FEATURE_SM4 },
    { 0x07, 0x01, .EAX, 3,  X86_FEATURE_RAO_INT },
    { 0x07, 0x01, .EAX, 4,  X86_FEATURE_AVX_VNNI },
    { 0x07, 0x01, .EAX, 5,  X86_FEATURE_AVX512_BF16 },
    { 0x07, 0x01, .EAX, 6,  X86_FEATURE_LASS },
    { 0x07, 0x01, .EAX, 7,  X86_FEATURE_CMDCCADD },
    { 0x07, 0x01, .EAX, 8,  X86_FEATURE_ARCHPERFMONEXT },
    { 0x07, 0x01, .EAX, 10, X86_FEATURE_FZRM },
    { 0x07, 0x01, .EAX, 11, X86_FEATURE_FSRS },
    { 0x07, 0x01, .EAX, 12, X86_FEATURE_RSRCS },
    { 0x07, 0x01, .EAX, 17, X86_FEATURE_FRED },
    { 0x07, 0x01, .EAX, 18, X86_FEATURE_LKGS },
    { 0x07, 0x01, .EAX, 19, X86_FEATURE_WRMSRNS },
    { 0x07, 0x01, .EAX, 21, X86_FEATURE_AMX_FP16 },
    { 0x07, 0x01, .EAX, 22, X86_FEATURE_HRESET },
    { 0x07, 0x01, .EAX, 23, X86_FEATURE_AVX_IFMA },
    { 0x07, 0x01, .EAX, 26, X86_FEATURE_LAM },
    { 0x07, 0x01, .EAX, 27, X86_FEATURE_MSRLIST },
    /* Leaf 07H, Function 01H, EBX */
    { 0x07, 0x01, .EBX, 1,  X86_FEATURE_PBNDKB },
    /* Leaf 07H, Function 01H, ECX */
    { 0x07, 0x01, .ECX, 4,  X86_FEATURE_AVX_VNNI_INT8 },
    { 0x07, 0x01, .ECX, 5,  X86_FEATURE_AMX_AMX_COMPLEX },
    { 0x07, 0x01, .ECX, 8,  X86_FEATURE_AVX_NE_CONVERT },
    { 0x07, 0x01, .ECX, 10, X86_FEATURE_AVX_VNNI_INT16 },
    { 0x07, 0x01, .ECX, 14, X86_FEATURE_PREFETCHI },
    { 0x07, 0x01, .ECX, 15, X86_FEATURE_USER_MSR },
    { 0x07, 0x01, .ECX, 18, X86_FEATURE_CET_SSS },
    { 0x07, 0x01, .ECX, 19, X86_FEATURE_AVX10 },
    { 0x07, 0x01, .ECX, 20, X86_FEATURE_APX_F },
}

x86_learn_cpu :: proc(cpu: ^CPU) {
    // Read the maximum CPUID parameter and the CPU manufacturer.
    eax, ebx, ecx, edx := intrinsics.x86_cpuid(0, 0)
    manufacturer_bits := [3]u32 {ebx, edx, ecx}
    manufacturer := strings.clone(transmute(string) slice.to_bytes(manufacturer_bits[:]))
    cpu.manufacturer = manufacturer
    x86_highest_leaf := eax
    // Initialize CPUID processor features by table-driving.
    leaf := u32(0xffffffff)
    func := u32(0xffffffff)
    for cpuid_desc in x86_features {
        if cpuid_desc.leaf != leaf || cpuid_desc.func != func {
            if cpuid_desc.leaf < x86_highest_leaf {
                break
            }
            eax, ebx, ecx, edx = intrinsics.x86_cpuid(leaf, func)
        }
        reg: u32
        switch cpuid_desc.dest {
            case .EAX: reg = eax
            case .EBX: reg = ebx
            case .ECX: reg = ecx
            case .EDX: reg = edx
        }
        set := ((reg >> cpuid_desc.bit) & 0b1) != 0
        if set {
            cpu_set_feature(cpu, cpuid_desc.feature)
        }
    }
    // Load XSAVE information
    impl_state := new(X86_CPU_Impl_State)
    if x86_highest_leaf >= 0x0d {
        eax, _, _, edx = intrinsics.x86_cpuid(0x0d, 0x00)
        sc_bitmap := [2]u32{eax, edx}
        eax, ebx, ecx, edx = intrinsics.x86_cpuid(0x0d, 0x01)
        impl_state.xsave_feature_flags = transmute(X86_XSAVE_Feature_Flags) eax
        impl_state.xsave_buffer_size = ebx
        for sci in u32(2) ..< cast(u32) max(X86_State_Component) {
            scc := cast(X86_State_Component) sci
            eax, ebx, ecx, _ = intrinsics.x86_cpuid(0x0d, sci)
            impl_state.xsave_state_components[scc].size = eax
            impl_state.xsave_state_components[scc].offs = ebx
            impl_state.xsave_state_components[scc].flags = transmute(X86_State_Component_Flags) cast(u8) ecx
            bm_idx := sci / 32
            bm_off := sci % 32
            if ((sc_bitmap[bm_idx] >> bm_off) & 0b1) != 0 {
                impl_state.xsave_state_components[scc].flags |= {.Present}
            }
        }
    } else {
        // Just leave enough state for X87 and SSE
        impl_state.xsave_buffer_size = 0x400 + 0x40
    }
    // The information about X87 and SSE can be loaded statically
    impl_state.xsave_state_components[.X87].size = 0xa0
    impl_state.xsave_state_components[.X87].offs = 0x00
    impl_state.xsave_state_components[.X87].flags = {.Present}
    impl_state.xsave_state_components[.SSE].size = 0x100
    impl_state.xsave_state_components[.SSE].offs = 0xa0
    impl_state.xsave_state_components[.SSE].flags = {.Present}
    cpu._impl_state = cast(rawptr) impl_state
    // Initialize the register buffers for this CPU
    x86_init_registers(cpu)
}

