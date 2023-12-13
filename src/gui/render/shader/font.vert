#version 330 core

layout (location = 0) in vec2 pos;
layout (location = 1) in vec2 tex_coord;

uniform vec2 screen;
uniform vec2 scale;
uniform vec2 position;

uniform vec2 sample_offset;
uniform vec2 sample_size;

out vec2 frag_tex_coord;

void main() {
    vec2 vertex_pos = pos;
    vertex_pos *= scale;
    vertex_pos += position;
    vertex_pos /= screen/2.0;
    vertex_pos -= 1.0;
    frag_tex_coord = tex_coord * sample_size + sample_offset;
    gl_Position = vec4(vertex_pos.xy, 0.0, 1.0);
}
