shader_type canvas_item;
// Door peephole: barrel distortion inside a round lens, dark vignette, a
// faint warm tint and a little film grain.

uniform float bulge = 0.55;
uniform vec3 tint : source_color = vec3(1.0, 0.96, 0.86);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float r = length(p);
	if (r > 1.0) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		// Sample further out toward the rim: the fisheye squeeze.
		vec2 q = p * (1.0 + bulge * r * r) / (1.0 + bulge);
		vec3 c = texture(TEXTURE, q * 0.5 + 0.5).rgb * tint;
		c *= smoothstep(1.02, 0.45, r);
		c += (hash(UV * 512.0 + TIME) - 0.5) * 0.035;
		float rim = smoothstep(0.94, 1.0, r);
		COLOR = vec4(mix(c, vec3(0.0), rim), 1.0);
	}
}
