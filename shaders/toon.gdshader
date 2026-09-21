// Toon shader — soft color bands + rim light + optional outline.
// Used on parts so they look cartoony instead of PBR-realistic.

shader_type spatial;
render_mode
	cull_back,
	diffuse_lambert,
	specular_disabled,
	shadows_disabled;

uniform vec4 albedo : source_color = vec4(0.95, 0.95, 1.0, 1.0);
uniform vec4 accent : source_color = vec4(1.0, 0.5, 0.2, 1.0);
uniform float bands : hint_range(2.0, 6.0, 1.0) = 3.0;
uniform float rim_strength : hint_range(0.0, 4.0, 0.05) = 1.4;
uniform float rim_power : hint_range(0.5, 8.0, 0.1) = 2.5;
uniform float emission_strength : hint_range(0.0, 5.0, 0.05) = 0.0;
uniform float pattern_mix : hint_range(0.0, 1.0, 0.01) = 0.0;

void fragment() {
	// Quantize lambert into N bands for the toon look.
	float n_dot_l = dot(NORMAL, LIGHT);
	float lit = clamp(n_dot_l * 0.5 + 0.5, 0.0, 1.0);
	float bands_f = max(bands, 1.0);
	float toon_lit = floor(lit * bands_f) / bands_f;

	// Base albedo blended with accent in shadowed areas.
	vec3 base = mix(accent.rgb, albedo.rgb, toon_lit);

	// Rim light — bright edge facing away from the view.
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), rim_power);
	vec3 rim_color = mix(albedo.rgb, vec3(1.0), 0.5) * rim * rim_strength;

	// Decorative accent pattern (used for painted stripes).
	float pattern = step(0.5, fract(UV.y * 6.0)) * pattern_mix;
	vec3 mixed = mix(base, accent.rgb, pattern * 0.25);

	ALBEDO = mixed;
	EMISSION = rim_color + albedo.rgb * emission_strength;
}
