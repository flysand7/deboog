package elf

import "core:fmt"
import "core:os"
import "core:testing"
import "core:slice"

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
    symbols := symbol_list(elf)
    sym_names: [dynamic]string
    for symbol in symbols {
        name, name_err := symbol_name(elf, symbol)
        expect_v(t, name_err, nil)
        append(&sym_names, name)
    }
    slice.sort(sym_names[:])
    for n in sym_names {
        fmt.println(n)
    }
}
