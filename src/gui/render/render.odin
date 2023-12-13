package gui_render

import gl   "vendor:OpenGL"

import "src:gui/types"

import "core:intrinsics"

Vec   :: types.Vec
Rect  :: types.Rect
Quad  :: types.Quad
Color :: types.Color

rect_size :: types.rect_size
quad_size :: types.quad_size
rect_position :: types.rect_position

@(private)
render_state: struct {
    framebuffer_size: Vec,
}

@(private) quad_data: Buffer
@(private) textured_quad_data: Buffer

@(private)
simple_shader: Shader(struct {
    screen:        Uniform(Vec),
    scale:         Uniform(Vec),
    position:      Uniform(Vec),
    color:         Uniform(Color),
})

@(private)
texture_shader: Shader(struct {
    screen:        Uniform(Vec),
    scale:         Uniform(Vec),
    position:      Uniform(Vec),
    our_texture:   Uniform(Texture),
})

@(private)
sampled_shader: Shader(struct {
    screen:        Uniform(Vec),
    scale:         Uniform(Vec),
    position:      Uniform(Vec),
    sample_offset: Uniform(Vec),
    sample_size:   Uniform(Vec),
    our_texture:   Uniform(Texture),
})

@(private)
font_shader: Shader(struct {
    screen:        Uniform(Vec),
    scale:         Uniform(Vec),
    position:      Uniform(Vec),
    sample_offset: Uniform(Vec),
    sample_size:   Uniform(Vec),
    our_texture:   Uniform(Texture),
})


init :: proc() {
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
        #load("./shader/simple.vert"),
        #load("./shader/simple.frag"),
    )
    init_shader(
        &texture_shader,
        #load("./shader/textured.vert"),
        #load("./shader/textured.frag"),
    )
    init_shader(
        &sampled_shader,
        #load("./shader/sampled.vert"),
        #load("./shader/sampled.frag"),
    )
    init_shader(
        &font_shader,
        #load("./shader/font.vert"),
        #load("./shader/font.frag"),
    )
}

rect :: proc(bounds: Rect, color: [3]f32) {
    shader_uniform(&simple_shader.screen,   render_state.framebuffer_size)
    shader_uniform(&simple_shader.scale,    rect_size(bounds))
    shader_uniform(&simple_shader.position, rect_position(bounds))
    shader_uniform(&simple_shader.color,    color)
    shader_use(&simple_shader)
    draw_buffer(quad_data)
}

textured_rect :: proc(bounds: Rect, texture: Texture) {
    shader_uniform(&texture_shader.screen,      render_state.framebuffer_size)
    shader_uniform(&texture_shader.scale,       rect_size(bounds))
    shader_uniform(&texture_shader.position,    rect_position(bounds))
    shader_uniform(&texture_shader.our_texture, texture)
    shader_use(&texture_shader)
    draw_buffer(textured_quad_data)
}

textured_rect_clip :: proc(bounds: Rect, clip: Rect, texture: Texture) {
    shader_uniform(&sampled_shader.screen,        render_state.framebuffer_size)
    shader_uniform(&sampled_shader.scale,         rect_size(bounds))
    shader_uniform(&sampled_shader.position,      rect_position(bounds))
    shader_uniform(&sampled_shader.sample_size,   rect_size(clip))
    shader_uniform(&sampled_shader.sample_offset, rect_position(clip))
    shader_uniform(&sampled_shader.our_texture, texture)
    shader_use(&sampled_shader)
    draw_buffer(textured_quad_data)
}

char :: proc(bounds: Rect, clip: Rect, atlas: Texture) {
    shader_uniform(&font_shader.screen,        render_state.framebuffer_size)
    shader_uniform(&font_shader.scale,         rect_size(bounds))
    shader_uniform(&font_shader.position,      rect_position(bounds))
    shader_uniform(&font_shader.sample_size,   rect_size(clip))
    shader_uniform(&font_shader.sample_offset, rect_position(clip))
    shader_uniform(&font_shader.our_texture,   atlas)
    shader_use(&font_shader)
    draw_buffer(textured_quad_data)
}

tell_framebuffer_size :: proc "contextless" (size: Vec) {
    render_state.framebuffer_size = size
    gl.Viewport(0, 0, cast(i32) size.x, cast(i32) size.y)
}
