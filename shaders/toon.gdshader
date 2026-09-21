// Toon shader — soft color bands + rim light + optional outline pass.
// Phase 3: cleaner bands, supports an optional cartoon outline via the
// duplicate-inverted-hull technique (callers add the outline mesh themselves).
//
// Used on every rocket part (primitive OR .glb mesh) and on the moon, clouds,
// launch tower — anything that wants the chunky cartoon look.

shader_type spatial;
render_mode
	cull_back,
	diffuse_lambert,
	specular_disabled,
	shadows_disabled;

uniform vec4 albedo : source_color = vec4(0.95, 0.95, 1.0, 1.0);
uniform vec4 accent : source_color = vec4(1.0, 0.5, 0.2, 1.0);
uniform float bands : hint_range(2.0, 6.0, 1.0) = 3.0;
uniform float rim_strength : hint_range(0.0, 4.0, 0.05) = 1.6;
uniform float rim_power : hint_range(0.5, 8.0, 0.1) = 2.5;
uniform float emission_strength : hint_range(0.0, 5.0, 0.05) = 0.0;
uniform float band_softness : hint_range(0.0, 0.3, 0.005) = 0.04;

// World-space gentle gradient — adds a subtle horizontal tonal shift that
// breaks up the flat color without breaking the cartoon feel.
uniform float ambient_boost : hint_range(0.0, 0.5, 0.01) = 0.15;

void fragment() {
	// Quantize lambert into N bands for the toon look. Add a soft edge
	// so the band transitions aren't pure steps (reads better on rounded
	// geometry).
	float n_dot_l = dot(NORMAL, LIGHT);
	float lit = clamp(n_dot_l * 0.5 + 0.5, 0.0, 1.0);
	float bands_f = max(bands, 1.0);
	float band_index = floor(lit * bands_f);
	float band_next = band_index + 1.0;
	float soft = smoothstep(band_index / bands_f - band_softness,
		band_index / bands_f + band_softness, lit);
	float toon_lit = mix(band_index / bands_f, band_next / bands_f, soft);

	// Base albedo mixed with accent in shadowed areas.
	vec3 base = mix(accent.rgb, albedo.rgb, toon_lit);

	// Sky/ambient add — gentle warm fill so back-of-rocket isn't pitch black.
	base += vec3(ambient_boost * 0.6, ambient_boost * 0.65, ambient_boost * 0.8);

	// Rim light — bright edge facing away from the view.
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), rim_power);
	vec3 rim_color = mix(albedo.rgb, vec3(1.0), 0.5) * rim * rim_strength;

	ALBEDO = base;
	EMISSION = rim_color + albedo.rgb * emission_strength;
}
