shader_type canvas_item;

void fragment() {
    COLOR = texture(TEXTURE, UV) * vec4(1.0, 0.0, 0.0, 1.0); // Teinte rouge
}
