// Sky gradient shader — used by the background skybox in flight scene.
// Phases blend: ground (warm blue) → atmosphere (purple) → space (deep navy).

shader_type sky;

uniform vec3 ground_color : source_color = vec3(0.55, 0.78, 0.96);
uniform vec3 zenith_color : source_color = vec3(0.12, 0.10, 0.30);
uniform vec3 space_color  : source_color = vec3(0.03, 0.02, 0.10);
uniform float space_mix : hint_range(0.0, 1.0, 0.01) = 0.0;

void sky() {
	float h = clamp(EYEDIR.y, -0.1, 1.0);
	vec3 ground_to_zenith = mix(ground_color, zenith_color, smoothstep(0.0, 0.7, h));
	COLOR = mix(ground_to_zenith, space_color, space_mix);
}
