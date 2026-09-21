// Toon shader — soft color bands + rim light + subtle outlines.
// Phase 3: simplified to use render_mode = unshaded so the lighting math
// is fully manual. We compute a fake "lit" factor from a hard-coded light
// direction (default: above-and-slightly-forward). This avoids fragile
// LIGHT built-ins that changed between Godot versions.

shader_type spatial;
render_mode
	cull_back,
	unshaded,
	shadows_disabled;

uniform vec4 albedo : source_color = vec4(0.95, 0.95, 1.0, 1.0);
uniform vec4 accent : source_color = vec4(1.0, 0.5, 0.2, 1.0);
uniform vec3 light_dir : source_color = vec3(0.3, 1.0, 0.5);   // direction toward the light
uniform float bands : hint_range(2.0, 6.0, 1.0) = 3.0;
uniform float rim_strength : hint_range(0.0, 4.0, 0.05) = 1.6;
uniform float rim_power : hint_range(0.5, 8.0, 0.1) = 2.5;
uniform float emission_strength : hint_range(0.0, 5.0, 0.05) = 0.0;
uniform float band_softness : hint_range(0.0, 0.3, 0.005) = 0.04;
uniform float ambient_boost : hint_range(0.0, 0.5, 0.01) = 0.30;

void fragment() {
	vec3 n = normalize(NORMAL);
	vec3 l = normalize(light_dir);
	// Lambert with manual 0.5 offset so the back isn't pure black.
	float lit = clamp(dot(n, l) * 0.5 + 0.5, 0.0, 1.0);
	float bands_f = max(bands, 1.0);
	float band_index = floor(lit * bands_f);
	float band_next = band_index + 1.0;
	float band_lo = band_index / bands_f;
	float band_hi = band_next / bands_f;
	float soft = smoothstep(band_lo - band_softness, band_lo + band_softness, lit);
	float toon_lit = mix(band_lo, band_hi, soft);

	vec3 base = mix(accent.rgb, albedo.rgb, toon_lit);

	// Sky/ambient add.
	base += vec3(ambient_boost * 0.6, ambient_boost * 0.65, ambient_boost * 0.8);

	// Rim light — bright edge facing away from the view.
	float rim = pow(1.0 - clamp(dot(n, VIEW), 0.0, 1.0), rim_power);
	vec3 rim_color = mix(albedo.rgb, vec3(1.0), 0.5) * rim * rim_strength;

	ALBEDO = base;
	EMISSION = rim_color + albedo.rgb * emission_strength;
}
