package gui_render

import gl   "vendor:OpenGL"
import stbi "vendor:stb/image"

import "src:gui/types"

Texture :: struct {
    id: u32,
}

texture_from_bitmap :: proc(
    bitmap: types.Bitmap,
    channels: int,
    monochrome_alpha := false,
) -> Texture {
    return texture_from_raw_bytes(
        bitmap.buffer, bitmap.size_x, bitmap.size_y, channels,
    )
}

texture_from_image_bytes :: proc(bytes: []u8) -> Texture {
    size_x: i32
    size_y: i32
    channels: i32
    stbi.set_flip_vertically_on_load(1)
    data := stbi.load_from_memory(
        raw_data(bytes), cast(i32) len(bytes), &size_x, &size_y, &channels, 0,
    )
    assert(data != nil)
    return texture_from_raw_bytes(data, int(size_x), int(size_y), int(channels))
}

texture_from_raw_bytes :: proc(
    bytes: [^]u8,
    size_x: int,
    size_y: int,
    channels: int,
    monochrome_alpha := false,
) -> Texture {
    texture: u32
    gl.GenTextures(1, &texture)
    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, texture)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_BORDER)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_BORDER)
    if channels == 4 {
        gl.TexImage2D(
            gl.TEXTURE_2D,
            0,
            gl.RGBA,
            i32(size_x),
            i32(size_y),
            0,
            gl.RGBA,
            gl.UNSIGNED_BYTE,
            bytes,
        )
    } else if channels == 3 {
        gl.TexImage2D(
            gl.TEXTURE_2D,
            0,
            gl.RGBA,
            i32(size_x),
            i32(size_y),
            0,
            gl.RGB,
            gl.UNSIGNED_BYTE,
            bytes,
        )
    } else if channels == 1 {
        swizzle_mask := monochrome_alpha ? [
            4]i32 {gl.RED, gl.RED, gl.RED, gl.ONE} :
            [4]i32 {gl.ZERO, gl.ZERO, gl.ZERO, gl.RED}
        gl.TexParameteriv(
            gl.TEXTURE_2D,
            gl.TEXTURE_SWIZZLE_RGBA,
            raw_data(swizzle_mask[:]),
        )
        gl.TexImage2D(
            gl.TEXTURE_2D,
            0,
            gl.RGBA,
            i32(size_x),
            i32(size_y),
            0,
            gl.RED,
            gl.UNSIGNED_BYTE,
            bytes,
        )
    }
    return {id = texture }
}
