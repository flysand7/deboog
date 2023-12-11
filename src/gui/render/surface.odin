package gui_render

import gl "vendor:OpenGL"

Surface :: struct {
    id: u32, // framebuffer object
    texture: Texture,
    size: Vec,
}

create_surface :: proc(size: Vec) -> Surface {
    fbo: u32
    gl.GenFramebuffers(1, &fbo)
    gl.BindFramebuffer(gl.FRAMEBUFFER, fbo)
    fbo_texture := texture_from_raw_bytes(nil, cast(int) size.x, cast(int) size.y, 4)
    gl.FramebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, fbo_texture.id, 0)
    status := gl.CheckFramebufferStatus(gl.FRAMEBUFFER)
    assert(status == gl.FRAMEBUFFER_COMPLETE, "Incomplete framebuffer")
    return {
        id = fbo,
        texture = fbo_texture,
        size = size,
    }
}

delete_surface :: proc(surface: ^Surface) {
    gl.DeleteTextures(1, &surface.texture.id)
    gl.DeleteFramebuffers(1, &surface.id)
}

surface_start :: proc(surface: ^Surface) {
    gl.BindFramebuffer(gl.FRAMEBUFFER, surface.id)
    gl.ClearColor(1.0, 1.0, 0.5, 1.0)
    gl.Clear(gl.COLOR_BUFFER_BIT)
}

surface_end :: proc() {
    gl.BindFramebuffer(gl.FRAMEBUFFER, 0)
}

surface_draw :: proc(surface: ^Surface, pos: Vec) {
    bounds := Rect {pos.x, pos.y, pos.x + surface.size.x, pos.y + surface.size.y}
    textured_rect(bounds, surface.texture)
}

surface_clip :: proc(surface: ^Surface, pos: Vec, clip: Rect) {
    bounds := Rect {pos.x, pos.y, pos.x + surface.size.x, pos.y + surface.size.y}
    textured_rect_clip(bounds, clip, surface.texture)
}

