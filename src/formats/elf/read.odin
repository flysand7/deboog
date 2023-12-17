package elf

import "core:intrinsics"
import "core:slice"

Elf_File :: struct {
    using header: ^Elf_Header,
    base:   [^]u8,
    size:   uint,
}

file_from_bytes :: proc(bytes: []u8) -> (file: Elf_File, err: Read_Error) {
    header := transmute(^Elf_Header) raw_data(bytes)
    verify_elf_header(header) or_return
    elf_file := Elf_File {
        header = header,
        base   = raw_data(bytes),
        size   = len(bytes),
    }
    return elf_file, nil
}

read :: proc($T: typeid, elf: Elf_File, offset: $I) -> (data: T, err: Read_Error)
where
    (intrinsics.type_is_pointer(T) || intrinsics.type_is_multi_pointer(T)) &&
    intrinsics.type_is_integer(I)
{
    verify_offset(elf, offset) or_return
    return transmute(T) elf.base[offset:], nil
}

Section_Iterator :: struct {
    elf:    Elf_File,
    offset: uintptr,
    index:  int,
    error:  Read_Error,
}

section_iterator :: proc(elf: Elf_File) -> (Section_Iterator) {
    return Section_Iterator {
        elf    = elf,
        offset = elf.section_header_offset,
        index  = 0,
        error  = nil,
    }
}

section_iterate :: proc(iter: ^Section_Iterator) -> (^Elf_Section_Header, int, bool)
{
    entry_size  := uintptr(iter.elf.section_header_entry_size)
    entry_count := int(iter.elf.section_header_entry_count)
    if iter.index >= entry_count {
        return nil, 0, false
    }
    section, section_err := read(
        ^Elf_Section_Header,
        iter.elf,
        iter.offset,
    )
    if section_err != nil {
        iter.error = section_err
        return nil, 0, false
    }
    iter.offset += entry_size
    iter.index  += 1
    return section, iter.index, true
}

read_string :: proc(
    elf:    Elf_File,
    strtab: ^Elf_Section_Header,
    index:  u32,
) -> (_a: string, _b: Read_Error) {
    strtab_offs := strtab.offset
    strtab      := read([^]u8, elf, strtab_offs) or_return
    name_cstring := cast(cstring) strtab[index:]
    return cast(string) name_cstring, nil
}

section_name :: proc(elf: Elf_File, section: ^Elf_Section_Header) -> (_a: string, _b: Read_Error) {
    strtab_sec_idx := uintptr(elf.section_name_section_index)
    entries        := uintptr(elf.section_header_offset)
    entry_size     := uintptr(elf.section_header_entry_size)
    assert(strtab_sec_idx != SHN_UNDEF)
    strtab_offs := entries + strtab_sec_idx * entry_size
    strtab := read(^Elf_Section_Header, elf, strtab_offs) or_return
    name, name_err := read_string(elf, strtab, section.name)
    return name, name_err
}

section_by_name :: proc(elf: Elf_File, name: string) -> (^Elf_Section_Header, int, Read_Error) {
    iter := section_iterator(elf)
    for section, index in section_iterate(&iter) {
        if index != 0 {
            sec_name, sec_name_ok := section_name(elf, section)
            if sec_name_ok != nil {
                return nil, 0, .Bad_Elf
            }
            if sec_name == name {
                return section, index, nil
            }
        }
    }
    return nil, 0, .Not_Found
}

section_data :: proc(
    elf:  Elf_File,
    shdr: ^Elf_Section_Header,
    $T:   typeid,
) -> (_a: []T, _b: Read_Error) {
    verify_offset(elf, shdr.offset) or_return
    verify_offset(elf, shdr.offset + cast(uintptr) shdr.size) or_return
    if shdr.entry_size != size_of(T) {
        return {}, .Not_Supported
    }
    t_ptr := transmute([^]T) elf.base[shdr.offset:]
    t_count := shdr.size / size_of(T)
    return t_ptr[:t_count], nil
}
