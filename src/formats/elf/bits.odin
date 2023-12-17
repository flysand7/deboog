package elf

Elf_Type :: enum u16 {
    None        = 0,
    Relocatable = 1,
    Executable  = 2,
    Shared      = 3,
    Core        = 4,
}

Elf_Machine :: enum u16 {
    None        = 0,
    i386        = 3,
    Arm         = 40,
    x64         = 62,
}

Elf_Version :: enum u32 {
    None        = 0,
    Current     = 1,
}

Elf_Identification :: enum {
    Magic_0     = 0,
    Magic_1     = 1,
    Magic_2     = 2,
    Magic_3     = 3,
    Class       = 4,
    Data        = 5,
    Version     = 6,
    Abi         = 7,
    Abi_Version = 8,
    _0          = 9,
    _1          = 10,
    _2          = 11,
    _3          = 12,
    _4          = 13,
    _5          = 14,
    _6          = 15,
}

ELF_MAGIC0 :: u8(0x7f)
ELF_MAGIC1 :: u8('E')
ELF_MAGIC2 :: u8('L')
ELF_MAGIC3 :: u8('F')

Elf_Class :: enum u8 {
    None  = 0,
    Elf32 = 1,
    Elf64 = 2,
}

Elf_Data :: enum u8 {
    None = 0,
    Lsb  = 1,
    Msb  = 2,
}

Elf_Abi :: enum u8 {
    None     = 0,
    Net_BSD  = 2,
    Linux    = 3,
    Free_BSD = 9,
}

SHN_UNDEF  :: 0
SHN_ABS    :: 0xfff1
SHN_COMMON :: 0xfff2
SHN_XINDEX :: 0xffff

Elf_Header :: struct {
    identification:             [Elf_Identification]u8,
    type:                       Elf_Type,
    machine:                    Elf_Machine,
    version:                    Elf_Version,
    entry:                      uintptr,
    program_header_offset:      uintptr,
    section_header_offset:      uintptr,
    flags:                      u32,
    header_size:                u16,
    program_header_entry_size:  u16,
    program_header_entry_count: u16,
    section_header_entry_size:  u16,
    section_header_entry_count: u16,
    section_name_section_index: u16,
}

Section_Type :: enum u32 {
    Null          = 0,
    Progbits      = 1,
    Symtab        = 2,
    Strtab        = 3,
    Rela          = 4,
    Hash          = 5,
    Dynamic       = 6,
    Note          = 7,
    Nobits        = 8,
    Rel           = 9,
    Shlib         = 10,
    Dynsym        = 11,
    Init_Array    = 14,
    Fini_Array    = 15,
    Preinit_Array = 16,
    Group         = 17,
    Symtab_Index  = 18,
}

Section_Flag_Bit :: enum {
    Write             = 0,
    Alloc             = 1,
    Exec              = 2,
    Merge             = 3,
    Strings           = 4,
    Info_link         = 5,
    Link_Order        = 6,
    Os_Non_Conforming = 7,
    Group             = 8,
    TLS               = 9,
}

Section_Flags :: bit_set[Section_Flag_Bit; uint]

Section_Group_Flags :: bit_set[enum{
    Comdat = 0,
}; u32]

Elf_Section_Header :: struct {
    name:          u32,
    type:          Section_Type,
    flags:         Section_Flags,
    addr:          uintptr,
    offset:        uintptr,
    size:          uint,
    link:          u32,
    info:          u32,
    address_align: uint,
    entry_size:    uint,
}

Segment_Type :: enum u32 {
    Null    = 0,
    Load    = 1,
    Dynamic = 2,
    Interp  = 3,
    Note    = 4,
    Shlib   = 5,
    Phdr    = 6,
    Tls     = 7,
}

Segment_Flags :: bit_set[enum {
    X = 0,
    W = 1,
    R = 2,
}; u32]

/*
    Elf32 program headers have flags in a different place. All functions that
    access elf program headers will automatically convert from elf32 to elf64
    format.
*/
Elf32_Program_Header :: struct {
    type:           Segment_Type,
    offset:         uint,
    vaddr:          uintptr,
    paddr:          uintptr,
    size_in_file:   uint,
    size_in_memory: uint,
    flags:          Segment_Flags,
    align:          uint,
}

Elf_Program_Header :: struct {
    type:           Segment_Type,
    flags:          Segment_Flags,
    offset:         uint,
    vaddr:          uintptr,
    paddr:          uintptr,
    size_in_file:   uint,
    size_in_memory: uint,
    align:          uint,
}

Elf32_Sym :: struct {
    name:      u32,
    value:     uintptr,
    size:      u32,
    info:      u8,
    other:     u8,
    section:   u16,
}

Elf_Sym :: struct {
    name:    u32,
    info:    u8,
    other:   u8,
    section: u16,
    value:   uintptr,
    size:    u64,
}
