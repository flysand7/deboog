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
    elf, elf_err := file_from_bytes(bytes)
    expect_v(t, elf_err, nil)
    ehdr_err := verify_elf_header(elf)
    expect_v(t, ehdr_err, nil)
    sections, sections_err := section_list(elf)
    expect_v(t, sections_err, nil)
    for section in sections {
        name, name_err := section_name(elf, section)
        expect_v(t, name_err, nil)
        fmt.println(name)
    }
    symtab, symtab_i, symtab_err := section_by_name(elf, ".symtab")
    strtab, strtab_i, strtab_err := section_by_name(elf, ".strtab")
    expect_v(t, symtab_err, nil)
    expect_v(t, strtab_err, nil)
    symbols, symbols_err := section_data(elf, symtab, Elf_Sym)
    expect_v(t, symbols_err, nil)
    for symbol in symbols {
        
    }
}
