shader_type canvas_item;

const int MONITOR_RESOLUTION = 256;

uniform vec4 color_value_nil: source_color = vec4(	0.2,		0.1, 		0., 		0.25);
uniform vec4 color_value_max: source_color = vec4( 	0.5,		0.2,		0.1,		0.45);
uniform vec4 color_value_low: source_color = vec4(	0.,			0.1,		0.5,		0.4);
uniform vec4 color_value_avg: source_color = vec4(	0.8,		0.1,		0.,			0.65);
uniform vec4 color_value_clip: source_color = vec4( 1.0,		1.0,		0.6,		0.8);
uniform vec2[MONITOR_RESOLUTION] buffer;


void fragment() {
	vec4 color 		= vec4(vec3(0.5), 0.5);
	float local_y 	= 1. - UV.y;
	int t_cell_idx	= int(floor(UV.x * float(MONITOR_RESOLUTION)));

	color = mix(color_value_nil, color_value_max, float(local_y < buffer[t_cell_idx].x));
	color = mix(color, color_value_clip, float (buffer[t_cell_idx].x > 1.));
	color = mix(
		color, 
		mix(
			color_value_avg, 
			color_value_low, 
			float(local_y > buffer[t_cell_idx].x && local_y < buffer[t_cell_idx].y)), 
		float(local_y < buffer[t_cell_idx].y)
	);

	COLOR = color;
}
