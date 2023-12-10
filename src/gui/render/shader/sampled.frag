#version 330 core

uniform sampler2D our_texture;

in vec3 frag_color;
in vec2 frag_tex_coord;

out vec4 color;

void main() {
    color = texture(our_texture, frag_tex_coord);
}
