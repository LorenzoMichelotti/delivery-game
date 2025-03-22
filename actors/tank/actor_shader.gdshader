shader_type canvas_item;

// damage
uniform bool active = false;
uniform vec3 shock_color : source_color = vec3(0.965, 0.186, 0.0);
uniform float amplitude = 2.0;
uniform float frequency = 10.0;

void vertex() {
	// damage
    float phase = mod(TIME, 0.3) / 0.3; // Normalize time into a 0 to 1 range
    float amp_factor = sin(phase * PI); // Smooth transition from 0 to 1 to 0
    if (active) {
        float attenuated_amplitude = amplitude * amp_factor * exp(-3.0 * phase);
        VERTEX.x += attenuated_amplitude * sin(frequency * phase);
        VERTEX.y += attenuated_amplitude * sin(frequency * phase);
    }
}

void fragment() {
	// damage
    float phase = mod(TIME, 0.3) / 0.3;
    float amp_factor = sin(phase * PI);
    vec3 normal_color = texture(TEXTURE, UV).rgb;
    if (active) {
        COLOR.rgb = normal_color + shock_color * amp_factor * exp(2.0 * amp_factor);
    }
}
