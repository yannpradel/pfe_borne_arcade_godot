shader_type spatial;

uniform sampler2D lava_texture;
uniform sampler2D noise_texture;
uniform float time_speed = 0.1;
uniform float distortion_strength = 1.0;
uniform float emission_strength = 0.01; // Contrôle de la luminosité de l'émission
uniform float red_boost = 1.3;        // Amplification des teintes rouges

void fragment() {
    vec2 uv = UV;
    float time = TIME * time_speed;

    // Calcul de la distorsion
    vec2 noise_uv = uv + vec2(time * 0.1, time * 0.1);
    vec2 distortion = texture(noise_texture, noise_uv).rg * distortion_strength;

    // Récupération de la couleur de la lave
    vec4 lava_color = texture(lava_texture, uv + distortion);

    // Amplification du rouge
    lava_color.r *= red_boost;

    // Ajustement de l'ALBEDO et de l'EMISSION
    ALBEDO = lava_color.rgb;
    EMISSION = lava_color.rgb * emission_strength;
}
