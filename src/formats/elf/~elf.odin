package elf

import "core:fmt"
import "core:os"
import "core:testing"

expect   :: testing.expect
expect_v :: testing.expect_value

@(test)
test_elf_basic :: proc(t: ^testing.T) {
    bytes, ok := os.read_entire_file("src.bin")
    expect(t, ok)
    elf, err := file_from_bytes(bytes)
    expect_v(t, err, nil)
    expect_v(t, size_of(elf.identification), 16)
    expect_v(t, elf.header_size, size_of(Elf_Header))
    expect_v(t, elf.identification[.Magic_0], ELF_MAGIC0)
    expect_v(t, elf.identification[.Magic_1], ELF_MAGIC1)
    expect_v(t, elf.identification[.Magic_2], ELF_MAGIC2)
    expect_v(t, elf.identification[.Magic_3], ELF_MAGIC3)
    expect_v(t, elf.identification[.Data],    u8(Elf_Data.Lsb))
    expect_v(t, elf.identification[.Class],   u8(Elf_Class.Elf64))
    expect_v(t, elf.identification[.Version], 1)
    expect_v(t, elf.type, Elf_Type.Executable)
    // fmt.printf("Elf flags: %04x\n", elf.flags)
    section_iter := section_iterator(elf)
    for shdr, i in section_iterate(&section_iter) {
        if i == 0 {
            expect_v(t, shdr.name,          0)
            expect_v(t, shdr.type,          Section_Type.Null)
            expect_v(t, shdr.flags,         Section_Flags {})
            expect_v(t, shdr.addr,          0)
            expect_v(t, shdr.offset,        0)
            expect_v(t, shdr.size,          0)
            expect_v(t, shdr.link,          SHN_UNDEF)
            expect_v(t, shdr.info,          0)
            expect_v(t, shdr.address_align, 0)
            expect_v(t, shdr.entry_size,    0)
        }
        // fmt.printf("%d\n", i)
        sec_name, sec_name_ok := section_name(elf, shdr)
        if sec_name_ok != nil {
            sec_name = "<invalid>"
        }
        fmt.printf("%02d: %016x -- %s\n", i, shdr.offset, sec_name)
    }
    fmt.println("---")
    strtab, strtab_i, strtab_err := section_by_name(elf, ".strtab")
    symtab, symtab_i, symtab_err := section_by_name(elf, ".symtab")
    expect_v(t, symtab_err, nil)
    symbols, symbols_err := section_data(elf, symtab, Elf_Sym)
    expect_v(t, symbols_err, nil)
    for sym in symbols[1:] {
        sym_name, sym_name_err := read_string(elf, strtab, sym.name)
        fmt.println(sym_name)
    }
    // sec_code, sec_code_idx, sec_code_ok := section_by_name(header, ".data")
    // expect(t, sec_code_ok)
    // fmt.println(sec_code)
}
