shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float alpha : hint_range(0.0, 1.0, 0.01) = 1.0;

void fragment() {
	ALBEDO = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
	ALPHA = alpha;
}
