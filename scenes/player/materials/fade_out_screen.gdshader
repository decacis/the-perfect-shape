shader_type spatial;
render_mode cull_back,unshaded,depth_test_disabled;

uniform vec4 albedo_color : source_color;


void vertex() {
	VERTEX *= 1.0;
	POSITION = vec4(VERTEX, 1.0);
}


void fragment() {
	ALBEDO = albedo_color.rgb;
	ALPHA = albedo_color.a;
}
