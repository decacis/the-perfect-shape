shader_type spatial;
render_mode depth_prepass_alpha, blend_add, cull_disabled;

uniform sampler2D noise_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform float vapor_speed : hint_range(0.0, 1.0, 0.01) = 1.0;

uniform float distortionVertex : hint_range(0.0, 0.3, 0.005) = 0.03;
uniform float speedVertex : hint_range(0.0, 1.0, 0.005) = 0.1;
uniform sampler2D noiseVertex;


void vertex() {
	float noiseVal = (texture(noiseVertex, UV + (TIME * speedVertex)).r * 2.0) - 1.0; // Range: -1.0 to 1.0
	vec3 displacement = NORMAL * noiseVal * distortionVertex;
	VERTEX = VERTEX + displacement;
}

void fragment() {
	float time = TIME * vapor_speed;
	
	vec2 new_uv = UV;
	new_uv.x += cos(time);
	new_uv.y += sin(time);
	vec4 noise_tex = texture(noise_texture, new_uv);
	float alpha = 0.0 - (noise_tex.r - 0.55);
	ALPHA = alpha;
}