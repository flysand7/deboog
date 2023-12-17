package elf

import "core:intrinsics"

Read_Error :: enum {
    None,
    Not_Found,
    Not_Elf,
    Bad_Elf,
    Not_Supported,
}

verify_offset :: proc(elf: Elf_File, offset: $T) -> Read_Error
where
    intrinsics.type_is_integer(T)
{
    if 0 <= cast(uint) offset && cast(uint) offset < elf.size {
        return nil
    }
    return .Bad_Elf
}

verify_elf_header :: proc(elf: ^Elf_Header) -> Read_Error {
    if elf.header_size != size_of(Elf_Header) {
        return .Not_Elf
    }
    if size_of(elf.identification) != 16 {
        return .Not_Elf
    }
    if elf.identification[.Magic_0] != ELF_MAGIC0 {
        return .Not_Elf
    }
    if elf.identification[.Magic_1] != ELF_MAGIC1 {
        return .Not_Elf
    }
    if elf.identification[.Magic_2] != ELF_MAGIC2 {
        return .Not_Elf
    }
    if elf.identification[.Magic_3] != ELF_MAGIC3 {
        return .Not_Elf
    }
    if elf.identification[.Data] != u8(Elf_Data.Lsb) {
        return .Not_Supported
    }
    if elf.identification[.Version] != 1 {
        return .Not_Supported
    }
    return nil
}

verify_zero_section :: proc(section: ^Elf_Section_Header) -> Read_Error {
    if section.name != 0 {
        return .Bad_Elf
    }
    if section.type != Section_Type.Null {
        return .Bad_Elf
    }
    if section.flags != {} {
        return .Bad_Elf
    }
    if section.addr != 0 {
        return .Bad_Elf
    }
    if section.offset != 0 {
        return .Bad_Elf
    }
    if section.size != 0 {
        return .Bad_Elf
    }
    if section.link != SHN_UNDEF {
        return .Bad_Elf
    }
    if section.info != 0 {
        return .Bad_Elf
    }
    if section.address_align != 0 {
        return .Bad_Elf
    }
    if section.entry_size != 0 {
        return .Bad_Elf
    }
    return .Not_Elf
}
