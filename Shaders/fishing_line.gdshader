shader_type particles;


uniform int amount : hint_range(1, 1000) = 8;


uniform float max_rope_distance : hint_range(1.0, 1000.0) = 20.0;
uniform float scale : hint_range(0.0, 10.0) = 1.0;


uniform vec3 start = vec3(-5.0, 5.0, 0.0);
uniform vec3 end = vec3(5.0, 5.0, 0.0);
uniform vec3 curve_direction = vec3(0.0, -1.0, 0.0);


uniform vec4 color : source_color = vec4(1.0);


uniform sampler2D color_gradient : hint_default_white;


void process() {
	float new_index = float(INDEX) / float(amount - 1);
	
	TRANSFORM[0].x = scale;
	TRANSFORM[1].y = scale;
	TRANSFORM[2].z = scale;
	TRANSFORM[3].xyz = mix(start, end, new_index) - curve_direction * (new_index * new_index - new_index) * 4.0 * max((max_rope_distance - distance(start, end)) * 0.5, 0.0);
	
	COLOR.rgb = texture(color_gradient, vec2(new_index, 0.0)).rgb * color.rgb;
}