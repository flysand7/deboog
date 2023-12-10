#version 330 core

layout (location = 0) in vec2 pos;

uniform vec2 screen;
uniform vec2 scale;
uniform vec2 position;
uniform vec3 color;

out vec3 frag_color;

void main() {
    vec2 vertex_pos = pos;
    vertex_pos *= scale;
    vertex_pos += position;
    vertex_pos /= screen/2.0;
    vertex_pos -= 1.0;
    frag_color = color;
    gl_Position = vec4(vertex_pos.xy, 0.0, 1.0);
}
