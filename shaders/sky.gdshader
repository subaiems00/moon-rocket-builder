// Sky shader — used by the background skybox in flight scene.
// Phase 3: 3-band blend (ground blue → atmosphere purple → space black)
// driven by `altitude_mix` which the player updates from GDScript.

shader_type sky;

uniform vec3 ground_color : source_color = vec3(0.55, 0.78, 0.96);
uniform vec3 horizon_color : source_color = vec3(0.85, 0.75, 0.95);
uniform vec3 zenith_color : source_color = vec3(0.18, 0.16, 0.42);
uniform vec3 space_color : source_color = vec3(0.03, 0.02, 0.10);
uniform float atmosphere_mix : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float space_mix : hint_range(0.0, 1.0, 0.01) = 0.0;

void sky() {
	float h = clamp(EYEDIR.y, -0.1, 1.0);
	vec3 g_to_zenith = mix(ground_color, zenith_color, smoothstep(0.0, 0.6, h));
	vec3 atmosphere = mix(g_to_zenith, horizon_color, atmosphere_mix * (1.0 - smoothstep(0.5, 1.0, h)));
	COLOR = mix(atmosphere, space_color, space_mix);
}
