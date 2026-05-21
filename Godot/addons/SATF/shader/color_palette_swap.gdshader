// recolor

shader_type canvas_item;

// hard coded maximum supported replace colors (increase if more needed)
const int MAX_COLORS = 32;

// real used number of used colors that are to replace (less then MAX_COLORS)
uniform int used_colors = 8;

uniform vec4[MAX_COLORS] original_colors: source_color;
uniform vec4[MAX_COLORS] replace_colors: source_color;

// for team colors do a pixel exact color swap
const float precision = 0.0;

vec4 swap_color(vec4 color){
	int real_used_color = min(used_colors, MAX_COLORS);
	for (int i = 0; i < real_used_color; i ++) {
		if (distance(color, original_colors[i]) <= precision){
			return replace_colors[i];
		}
	}
	return color;
}

void fragment() {
	COLOR = swap_color(texture(TEXTURE, UV));
}
