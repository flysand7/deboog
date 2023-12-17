package elf

import "core:intrinsics"
import "core:slice"

Elf_File :: struct {
    using header: ^Ehdr,
    base:   [^]u8,
    size:   uint,
}

file_from_bytes :: proc(bytes: []u8) -> (file: Elf_File, err: Read_Error) {
    header := transmute(^Ehdr) raw_data(bytes)
    elf_file := Elf_File {
        header = header,
        base   = raw_data(bytes),
        size   = len(bytes),
    }
    verify_elf_header(elf_file) or_return
    return elf_file, nil
}

read :: proc($T: typeid, elf: Elf_File, #any_int offs: uintptr) -> (T, Read_Error)
where
    intrinsics.type_is_pointer(T) ||
    intrinsics.type_is_multi_pointer(T)
{
    err := check_offset(elf, offs)
    if err != nil {
        return {}, .Bad_Elf
    }
    return transmute(T) elf.base[offs:], nil
}

section_data :: proc(elf: Elf_File, shdr: Shdr, $T: typeid) -> ([]T, Read_Error) {
    offs := cast(uint) shdr.offset
    size := cast(uint) shdr.size
    if offs + size > elf.size {
        return nil, .Bad_Elf
    }
    bytes := transmute([^]T) elf.base[offs:]
    count := size / size_of(T)
    return bytes[:count], nil
}

section_list :: proc(elf: Elf_File) -> ([]Shdr, Read_Error) {
    sections := (transmute([^]Shdr) elf.base[elf.sh_off:])[:elf.sh_ent_cnt]
    return sections, nil
}

section_by_index :: proc(elf: Elf_File, #any_int i: uintptr) -> (Shdr, Read_Error) {
    if i >= cast(uintptr) elf.sh_ent_cnt {
        return {}, .Bad_Elf
    }
    return (transmute([^]Shdr) elf.base[elf.sh_off:])[i], nil
}

section_name :: proc(elf: Elf_File, shdr: Shdr) -> (string, Read_Error) {
    assert(elf.str_sec_ndx != 0)
    strtab_sh, strtab_sh_err := section_by_index(elf, elf.str_sec_ndx)
    if strtab_sh_err != nil {
        return {}, strtab_sh_err
    }
    strtab, strtab_err := section_data(elf, strtab_sh, u8)
    if strtab_err != nil {
        return {}, strtab_err
    }
    name := transmute(cstring) &strtab[shdr.name]
    return cast(string) name, nil
}

section_by_name :: proc(elf: Elf_File, name: string) -> (Shdr, int, Read_Error) {
    assert(elf.str_sec_ndx != 0)
    strtab_sh, strtab_sh_err := section_by_index(elf, elf.str_sec_ndx)
    if strtab_sh_err != nil {
        return {}, 0, strtab_sh_err
    }
    strtab, strtab_err := section_data(elf, strtab_sh, u8)
    if strtab_err != nil {
        return {}, 0, strtab_err
    }
    sections, sections_err := section_list(elf)
    if sections_err != nil {
        return {}, 0, sections_err
    }
    for section, idx in sections {
        section_name := cast(string) transmute(cstring) &strtab[section.name]
        if section_name == name {
            return section, idx, nil
        }
    }
    return {}, 0, .Not_Found
}
