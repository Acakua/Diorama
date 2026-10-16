shader_type spatial;
// Wooden floor boards laid out in world space: staggered joints, a tint per
// board, thin dark gaps, faint grain, and a little wear where people walk.
// Boards run along X.

uniform vec3 board_color : source_color = vec3(0.47, 0.31, 0.2);
uniform vec3 board_color_alt : source_color = vec3(0.35, 0.22, 0.13);
uniform vec3 gap_color : source_color = vec3(0.09, 0.06, 0.04);
uniform float board_width = 0.2;
uniform float board_length = 1.8;
uniform float gap_width = 0.01;
uniform float roughness_base : hint_range(0.0, 1.0) = 0.72;
uniform float wear : hint_range(0.0, 1.0) = 0.35;
uniform vec2 wear_center = vec2(0.0, 0.3);

varying vec3 world_pos;

float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash12(i), hash12(i + vec2(1.0, 0.0)), u.x),
			mix(hash12(i + vec2(0.0, 1.0)), hash12(i + vec2(1.0, 1.0)), u.x), u.y);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = world_pos.xz;
	float row = floor(p.y / board_width);
	float shift = hash12(vec2(row, 7.0)) * board_length;
	float col = floor((p.x + shift) / board_length);
	vec2 id = vec2(row, col);
	vec2 local = vec2(mod(p.x + shift, board_length), mod(p.y, board_width));
	float edge = min(min(local.x, board_length - local.x), min(local.y, board_width - local.y));
	float aa = fwidth(edge) + 0.0005;
	float board = smoothstep(gap_width * 0.5 - aa, gap_width * 0.5 + aa, edge);

	float tint = hash12(id * 1.37 + 0.5);
	float grain = value_noise(vec2(p.x * 2.0, p.y * 24.0) + id * 13.0);
	float blotch = value_noise(p * 1.3 + id * 3.1);
	vec3 wood = mix(board_color, board_color_alt, clamp(tint * 0.85 + (grain - 0.5) * 0.35, 0.0, 1.0));
	wood *= 0.9 + 0.2 * blotch;

	float traffic = wear * (1.0 - smoothstep(0.5, 3.5, length(p - wear_center)));
	wood = mix(wood, wood * 1.12 + vec3(0.015), traffic * 0.5);

	ALBEDO = mix(gap_color, wood, board);
	ROUGHNESS = clamp(roughness_base + (grain - 0.5) * 0.15 + traffic * 0.1 + (1.0 - board) * 0.2, 0.0, 1.0);
	SPECULAR = 0.4;
}
