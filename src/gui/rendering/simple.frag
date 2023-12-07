#version 330 core

out vec4 color;

in vec3 frag_color;

void main() {
    color = vec4(frag_color.xyz, 1.0f);
} 