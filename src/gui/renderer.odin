package gui

import gl   "vendor:OpenGL"
import stbi "vendor:stb/image"

import "core:intrinsics"
import "core:runtime"
import "core:reflect"
import "core:os"
import "core:fmt"

@(private="file")
render_state: struct {
    framebuffer_size: Vec,
}

@(private="file") quad_data: Buffer
@(private="file") textured_quad_data: Buffer

@(private="file")
simple_shader: Shader(struct {
    screen:   Uniform(Vec),
    scale:    Uniform(Vec),
    position: Uniform(Vec),
    color:    Uniform(Color),
})

@(private="file")
texture_shader: Shader(struct {
    screen:   Uniform(Vec),
    scale:    Uniform(Vec),
    position: Uniform(Vec),
    our_texture: Uniform(Texture),
})

Buffer :: struct {
    id: u32,
    vertices: i32,
}

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

Texture :: struct {
    id: u32,
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
init_shader :: proc(shader: ^Shader($T), vert_source: cstring, frag_source: cstring) {
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
    texture_slot := u32(0)
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
        case i32:
            v := (cast(^i32) value_ptr)^
            gl.Uniform1i(location_ptr^, v)
        case Texture:
            texture := (cast(^Texture) value_ptr)^
            gl.ActiveTexture(gl.TEXTURE0 + texture_slot)
            gl.BindTexture(gl.TEXTURE_2D, texture.id)
            gl.Uniform1ui(location_ptr^, texture_slot)
            texture_slot += 1
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

@(private="file")
shader_uniform :: proc(uniform: ^Uniform($Type), value: Type) {
    uniform.value = value
}

@(private="file")
load_texture :: proc(bytes: []u8) -> Texture {
    texture: u32
    gl.GenTextures(1, &texture)
    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, texture)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
    size_x: i32
    size_y: i32
    channels: i32
    stbi.set_flip_vertically_on_load(1)
    data := stbi.load_from_memory(raw_data(bytes), cast(i32) len(bytes), &size_x, &size_y, &channels, 0)
    assert(data != nil)
    fmt.println(size_x, size_y, channels)
    if channels == 4 {
        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, size_x, size_y, 0, gl.RGBA, gl.UNSIGNED_BYTE, data)
    } else {
        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, size_x, size_y, 0, gl.RGB, gl.UNSIGNED_BYTE, data)
    }
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
    return {id = texture }
}

@(private="file")
draw_buffer :: proc(buffer: Buffer) {
    gl.BindVertexArray(buffer.id)
    gl.DrawArrays(gl.TRIANGLES, 0, buffer.vertices)
}

renderer_init :: proc() {
    init_static_buffer(&quad_data, []struct{pos: Vec} {
        { pos = { 0, 0 }, },
        { pos = { 1, 0 }, },
        { pos = { 0, 1 }, },
        { pos = { 1, 0 }, },
        { pos = { 0, 1 }, },
        { pos = { 1, 1 }, },
    })
    init_static_buffer(&textured_quad_data, []struct{pos: Vec, tex_coord: Vec} {
        { pos = { 0, 0 }, tex_coord = { 0, 0 } },
        { pos = { 1, 0 }, tex_coord = { 1, 0 } },
        { pos = { 0, 1 }, tex_coord = { 0, 1 } },
        { pos = { 1, 0 }, tex_coord = { 1, 0 } },
        { pos = { 0, 1 }, tex_coord = { 0, 1 } },
        { pos = { 1, 1 }, tex_coord = { 1, 1 } },
    })
    init_shader(
        &simple_shader,
        #load("./rendering/simple.vert"),
        #load("./rendering/simple.frag"),
    )
    init_shader(
        &texture_shader,
        #load("./rendering/textured.vert"),
        #load("./rendering/textured.frag"),
    )
}

render_rect :: proc(bounds: Rect, color: [3]f32) {
    shader_uniform(&simple_shader.screen,   render_state.framebuffer_size)
    shader_uniform(&simple_shader.scale,    rect_size(bounds))
    shader_uniform(&simple_shader.position, rect_position(bounds))
    shader_uniform(&simple_shader.color,    color)
    shader_use(&simple_shader)
    draw_buffer(quad_data)
}

render_textured_rect :: proc(bounds: Rect, texture: Texture) {
    shader_uniform(&texture_shader.screen, render_state.framebuffer_size)
    shader_uniform(&texture_shader.scale,  rect_size(bounds))
    shader_uniform(&texture_shader.position, rect_position(bounds))
    shader_uniform(&texture_shader.our_texture, texture)
    shader_use(&texture_shader)
    draw_buffer(textured_quad_data)
}

@(private)
renderer_set_framebuffer_size :: proc "contextless" (size: Vec) {
    render_state.framebuffer_size = size
    gl.Viewport(0, 0, cast(i32) size.x, cast(i32) size.y)
}
