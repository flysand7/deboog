package elf

import "core:fmt"
import "core:os"
import "core:testing"
import "core:slice"

expect   :: testing.expect
expect_v :: testing.expect_value

@(test)
test_elf_sections :: proc(t: ^testing.T) {
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
}

@(test, private)
test_elf_symbols :: proc(t: ^testing.T) {
    bytes, ok := os.read_entire_file("src.bin")
    expect(t, ok)
    elf, elf_err := file_from_bytes(bytes)
    expect_v(t, elf_err, nil)
    ehdr_err := verify_elf_header(elf)
    expect_v(t, ehdr_err, nil)
    symbols := symbol_list(elf)
    sym_names: [dynamic]Sym
    for symbol in symbols {
        name, name_err := symbol_name(elf, symbol)
        expect_v(t, name_err, nil)
        append(&sym_names, symbol)
        type, bind := symbol_info(symbol)
        visibility := symbol_visibility(symbol)
        if type == .Object {
            fmt.println(type, bind, visibility, name)
        }
    }
}
