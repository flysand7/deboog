package gui_render

import gl   "vendor:OpenGL"
import stbi "vendor:stb/image"

Texture :: struct {
    id: u32,
}

@(private)
load_texture :: proc(bytes: []u8) -> Texture {
    texture: u32
    gl.GenTextures(1, &texture)
    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, texture)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
    size_x: i32
    size_y: i32
    channels: i32
    stbi.set_flip_vertically_on_load(1)
    data := stbi.load_from_memory(raw_data(bytes), cast(i32) len(bytes), &size_x, &size_y, &channels, 0)
    assert(data != nil)
    if channels == 4 {
        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, size_x, size_y, 0, gl.RGBA, gl.UNSIGNED_BYTE, data)
    } else {
        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, size_x, size_y, 0, gl.RGB, gl.UNSIGNED_BYTE, data)
    }
    return {id = texture }
}

@(private)
create_color_buffer :: proc(bytes: [^]u8, size_x: int, size_y: int, channels: i32) -> Texture {
    texture: u32
    gl.GenTextures(1, &texture)
    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, texture)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
    if channels == 4 {
        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, i32(size_x), i32(size_y), 0, gl.RGBA, gl.UNSIGNED_BYTE, bytes)
    } else {
        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, i32(size_x), i32(size_y), 0, gl.RGB, gl.UNSIGNED_BYTE, bytes)
    }
    return {id = texture }
}
