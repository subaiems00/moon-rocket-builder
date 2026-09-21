// Cartoon moon shader — toon bands + procedural craters via a
// noise function in fragment space. Reads the normal direction and
// bakes dark spots where (theta, phi) land on a hash grid.

shader_type spatial;
render_mode
	cull_back,
	diffuse_lambert,
	specular_disabled,
	shadows_disabled;

uniform vec4 albedo : source_color = vec4(0.97, 0.94, 0.86, 1.0);
uniform vec4 crater_color : source_color = vec4(0.55, 0.45, 0.34, 1.0);
uniform float crater_density : hint_range(0.0, 30.0, 0.5) = 8.0;
uniform float crater_size : hint_range(0.0, 0.5, 0.01) = 0.18;
uniform float crater_softness : hint_range(0.01, 0.5, 0.005) = 0.06;
uniform float rim_strength : hint_range(0.0, 3.0, 0.05) = 0.4;
uniform float band_strength : hint_range(0.0, 0.3, 0.01) = 0.08;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

void fragment() {
	vec3 n = normalize(NORMAL);
	vec2 uv = vec2(atan(n.z, n.x), asin(n.y));
	// Crater field — loop over a grid of points on the sphere.
	float crater_mask = 0.0;
	for (int gx = -3; gx <= 3; gx++) {
		for (int gy = -2; gy <= 2; gy++) {
			vec2 cell = floor(uv * crater_density) + vec2(float(gx), float(gy));
			vec2 jitter = vec2(
				hash21(cell),
				hash21(cell + 17.3)
			);
			vec2 center = (cell + jitter) / crater_density;
			float d = distance(uv, center);
			float k = 1.0 - smoothstep(crater_size - crater_softness, crater_size, d);
			crater_mask = max(crater_mask, k);
		}
	}
	vec3 base_color = mix(albedo.rgb, crater_color.rgb, crater_mask);

	// Soft toon banding on top of the crater field.
	float lit = clamp(dot(n, LIGHT) * 0.5 + 0.5, 0.0, 1.0);
	float toon = floor(lit * 3.0) / 3.0;
	base_color *= mix(1.0, toon * 1.0 + 0.5, band_strength);

	// Soft rim — gives the moon its glow against space.
	float rim = pow(1.0 - clamp(dot(n, VIEW), 0.0, 1.0), 2.0);
	vec3 rim_color = albedo.rgb * rim * rim_strength;

	ALBEDO = base_color;
	EMISSION = rim_color;
}
