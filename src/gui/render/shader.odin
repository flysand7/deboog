package gui_render

import gl "vendor:OpenGL"

import "core:intrinsics"
import "core:reflect"
import "core:runtime"
import "core:fmt"
import "core:os"

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


@(private)
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

@(private)
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


@(private)
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

@(private)
set_shader_uniforms :: proc(shader_program: u32, uniforms: ^$T)
where
    intrinsics.type_is_struct(intrinsics.type_base_type(T))
{
    uniforms_type_info := type_info_of(reflect.typeid_base(T))
    uniforms_struct := uniforms_type_info.variant.(runtime.Type_Info_Struct)
    uniforms_count := len(uniforms_struct.names)
    storage_ptr := cast(uintptr) rawptr(uniforms)
    texture_slot := i32(0)
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
            gl.ActiveTexture(gl.TEXTURE0 + u32(texture_slot))
            gl.BindTexture(gl.TEXTURE_2D, texture.id)
            gl.Uniform1i(location_ptr^, cast(i32) texture_slot)
            texture_slot += 1
        case:
            panic("Bad uniform type")
        }
    }
}

@(private)
shader_use :: proc(shader: ^Shader($T)) {
    gl.UseProgram(shader.program)
    set_shader_uniforms(shader.program, &shader.uniforms)
}

@(private)
shader_uniform :: proc(uniform: ^Uniform($Type), value: Type) {
    uniform.value = value
}