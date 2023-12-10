package gui_render

import gl "vendor:OpenGL"

import "core:intrinsics"
import "core:reflect"
import "core:runtime"

Buffer :: struct {
    id: u32,
    vertices: i32,
}

@(private)
init_static_buffer :: proc(buffer: ^Buffer, vertices: []$T)
where
    intrinsics.type_is_struct(intrinsics.type_base_type(T))
{
    vertex_type_info := type_info_of(reflect.typeid_base(T))
    vertex_size := vertex_type_info.size
    vertex_struct_type := vertex_type_info.variant.(runtime.Type_Info_Struct)
    // assert(len(vertex_struct_type.usings) == 0)
    assert(vertex_struct_type.is_raw_union == false)
    assert(vertex_struct_type.soa_base_type == nil)
    vertex_fields_count := len(vertex_struct_type.names)
    // Create vertex array object and the associated buffer
    vao: u32
    gl.GenVertexArrays(1, &vao)
    gl.BindVertexArray(vao)
    vbo: u32
    gl.GenBuffers(1, &vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
    gl.BufferData(gl.ARRAY_BUFFER, vertex_size*len(vertices), raw_data(vertices), gl.STATIC_DRAW)
    // Bind vertex attributes.
    attrib_index := u32(0)
    for i in 0 ..< vertex_fields_count {
        field_offset := vertex_struct_type.offsets[i]
        #partial switch field_type in vertex_struct_type.types[i].variant {
        case runtime.Type_Info_Array:
            count := field_type.count
            size  := field_type.elem_size
            gl_type: u32
            #partial switch element_type in field_type.elem.variant {
            case runtime.Type_Info_Float:
                if size == 8 {
                    gl_type = gl.DOUBLE
                } else if size == 4 {
                    gl_type = gl.FLOAT
                } else if size == 2 {
                    gl_type = gl.HALF_FLOAT
                } else {
                    panic("Bad type")
                }
            case runtime.Type_Info_Integer:
                if element_type.signed {
                    if size == 4 {
                        gl_type = gl.INT
                    } else if size == 2 {
                        gl_type = gl.SHORT
                    } else if size == 1 {
                        gl_type = gl.BYTE
                    } else {
                        panic("Bad type")
                    }
                } else {
                    if size == 4 {
                        gl_type = gl.UNSIGNED_INT
                    } else if size == 2 {
                        gl_type = gl.UNSIGNED_SHORT
                    } else if size == 1 {
                        gl_type = gl.UNSIGNED_BYTE
                    } else {
                        panic("Bad type")
                    }
                }
            }
            gl.VertexAttribPointer(attrib_index, i32(count), gl_type, false, i32(vertex_size), field_offset)
            gl.EnableVertexAttribArray(attrib_index)
        case:
            panic("Only arrays are allowed. Your vertex is bullshit!!!")
        }
        attrib_index += 1
    }
    buffer.id = vao
    buffer.vertices = cast(i32) len(vertices)
}

draw_buffer :: proc(buffer: Buffer) {
    gl.BindVertexArray(buffer.id)
    gl.DrawArrays(gl.TRIANGLES, 0, buffer.vertices)
}
