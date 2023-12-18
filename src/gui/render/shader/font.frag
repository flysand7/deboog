#version 330 core

uniform sampler2D our_texture;

in vec2 frag_tex_coord;
uniform vec3 color;

out vec4 frag_color;

void main() {
    float alpha = texture(our_texture, frag_tex_coord).a;
    frag_color = vec4(color.xyz, alpha);
}
