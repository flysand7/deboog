package gui

import gl "vendor:OpenGL"
import "core:intrinsics"
import "core:runtime"
import "core:reflect"
import "core:os"
import "core:fmt"

@(private="file")
render_state: struct {
    framebuffer_size: Vec,
}

@(private="file")
quad_data: struct {
    vertex_array: u32,
    vertex_count: int,
}

@(private="file")
simple_shader: Shader(struct {
    screen:   Uniform(Vec),
    scale:    Uniform(Vec),
    position: Uniform(Vec),
    color:    Uniform(Color),
})

Shader :: struct($T: typeid)
where
    intrinsics.type_is_struct(intrinsics.type_base_type(T))
{
    program:  u32,
    using uniforms: T,
}

Uniform :: struct($T: typeid) {
    location: struct { _:i32 },
    value:    T,
}

@(private="file")
compile_shader :: proc(type: u32, source: cstring) -> u32 {
    source := source
    shader := gl.CreateShader(type)
    gl.ShaderSource(shader, 1, &source, nil)
    gl.CompileShader(shader)
    compile_status: i32
    gl.GetShaderiv(shader, gl.COMPILE_STATUS, &compile_status)
    if compile_status == 0 {
        log: [1024]u8
        gl.GetShaderInfoLog(shader, size_of(log), nil, &log[0])
        fmt.printf("[GL] Vertex shader compile error: %s\n", log)
        os.exit(1)
    }
    return shader
}

@(private="file")
load_shader :: proc(shader: ^Shader($T), vert_source: cstring, frag_source: cstring) {
    shader_program := gl.CreateProgram()
    vert_shader := compile_shader(gl.VERTEX_SHADER, vert_source)
    frag_shader := compile_shader(gl.FRAGMENT_SHADER, frag_source)
    gl.AttachShader(shader_program, vert_shader)
    gl.AttachShader(shader_program, frag_shader)
    gl.LinkProgram(shader_program)
    gl.DeleteShader(vert_shader)
    gl.DeleteShader(frag_shader)
    program_link_status: i32
    gl.GetProgramiv(shader_program, gl.LINK_STATUS, &program_link_status)
    if program_link_status == 0 {
        log: [1024]u8
        gl.GetProgramInfoLog(shader_program, size_of(log), nil, &log[0])
        fmt.printf("[GL] Shader program link error: %s\n", log)
        os.exit(1)
    }
    shader.program = shader_program
    get_uniform_locations(shader.program, &shader.uniforms)
}

@(private="file")
create_static_buffer :: proc(buffer: []$T) -> u32
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
    gl.BufferData(gl.ARRAY_BUFFER, vertex_size*len(buffer), raw_data(buffer), gl.STATIC_DRAW)
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
            gl.VertexAttribPointer(attrib_index, i32(count), gl_type, false, i32(count*size), field_offset)
            gl.EnableVertexAttribArray(attrib_index)
        case:
            panic("Only arrays are allowed. Your vertex is bullshit!!!")
        }
        attrib_index += 1
    }
    return vao
}

@(private="file")
get_uniform_locations :: proc(shader_program: u32, uniforms: ^$T)
where
    intrinsics.type_is_struct(intrinsics.type_base_type(T))
{
    uniforms_type_info := type_info_of(reflect.typeid_base(T))
    uniforms_struct := uniforms_type_info.variant.(runtime.Type_Info_Struct)
    uniforms_count := len(uniforms_struct.names)
    storage_ptr := cast(uintptr) rawptr(uniforms)
    for i in 0 ..< uniforms_count {
        uniform_offset := uniforms_struct.offsets[i]
        uniform_name   := cast(cstring) raw_data(uniforms_struct.names[i])
        uniform_struct := reflect.type_info_base(uniforms_struct.types[i]).variant.(runtime.Type_Info_Struct)
        location_ptr := cast(^i32)(storage_ptr + uniform_offset + uniform_struct.offsets[0])
        uniform_location := gl.GetUniformLocation(shader_program, uniform_name)
        location_ptr^ = uniform_location
        if uniform_location == -1 {
            fmt.panicf("Uniform %s wasn't found in the shader.\n", uniform_name)
        }
    }
}

@(private="file")
set_shader_uniforms :: proc(shader_program: u32, uniforms: ^$T)
where
    intrinsics.type_is_struct(intrinsics.type_base_type(T))
{
    uniforms_type_info := type_info_of(reflect.typeid_base(T))
    uniforms_struct := uniforms_type_info.variant.(runtime.Type_Info_Struct)
    uniforms_count := len(uniforms_struct.names)
    storage_ptr := cast(uintptr) rawptr(uniforms)
    for i in 0 ..< uniforms_count {
        uniform_offset := uniforms_struct.offsets[i]
        uniform_struct := reflect.type_info_base(uniforms_struct.types[i]).variant.(runtime.Type_Info_Struct)
        location_ptr := cast(^i32)(storage_ptr + uniform_offset + uniform_struct.offsets[0])
        value_ptr    := storage_ptr + uniform_offset + uniform_struct.offsets[1]
        uniform_type := uniform_struct.types[1]
        switch uniform_type.id {
        case [2]f32:
            vec := (cast(^[2]f32) value_ptr)^
            gl.Uniform2f(location_ptr^, vec.x, vec.y)
        case [3]f32:
            vec := (cast(^[3]f32) value_ptr)^
            gl.Uniform3f(location_ptr^, vec.x, vec.y, vec.z)
        case [4]f32:
            vec := (cast(^[4]f32) value_ptr)^
            gl.Uniform4f(location_ptr^, vec.x, vec.y, vec.z, vec.w)
        case:
            panic("Bad uniform type")
        }
    }
}

@(private="file")
shader_use :: proc(shader: ^Shader($T)) {
    gl.UseProgram(shader.program)
    set_shader_uniforms(shader.program, &shader.uniforms)
}

renderer_init :: proc() {
    quad_buffer := []struct{pos: Vec} {
        { pos = { 0, 0 }, },
        { pos = { 1, 0 }, },
        { pos = { 0, 1 }, },
        { pos = { 1, 0 }, },
        { pos = { 0, 1 }, },
        { pos = { 1, 1 }, },
    }
    quad_data.vertex_array = create_static_buffer(quad_buffer)
    quad_data.vertex_count = len(quad_buffer)
    load_shader(&simple_shader, #load("./rendering/simple.vert"), #load("./rendering/simple.frag"))
}

render_rect :: proc(bounds: Rect, color: [3]f32) {
    simple_shader.screen.value   = render_state.framebuffer_size
    simple_shader.scale.value    = rect_size(bounds)
    simple_shader.position.value = rect_position(bounds)
    simple_shader.color.value    = color
    shader_use(&simple_shader)
    gl.BindVertexArray(quad_data.vertex_array)
    gl.DrawArrays(gl.TRIANGLES, 0, i32(quad_data.vertex_count))
}

@(private)
renderer_set_framebuffer_size :: proc "contextless" (size: Vec) {
    render_state.framebuffer_size = size
    gl.Viewport(0, 0, cast(i32) size.x, cast(i32) size.y)
}
