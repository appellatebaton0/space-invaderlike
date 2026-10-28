shader_type canvas_item;

uniform vec2 multiplier = vec2(2.);
uniform float smoothing = 0.2;
uniform sampler2D transition_noise;

uniform float threshold = 0.5;
uniform vec4 transition_color_a:source_color = vec4(1.0);
uniform vec4 transition_color_b:source_color = vec4(1.0);

uniform float density = 100.;
uniform float speed = 20.0;

//// A linear function that passes through (0.5, 0.5), with a slope that makes
//// it start at (0.5 - smoothing) and end at (0.5 + smoothing), and then clamps
//// where it leaves 0.0 - 1.0 to those values.
//float ease(float a)
//{
	//if (a < 0.5 - smoothing){return 0.0;}
	//if (a > 0.5 + smoothing){return 1.0;}
	//return (a - 0.5) / (2.0 * smoothing) + 0.5;
//}
//
//// Stretches the given value vertically, keeping (0.5,0.5) the same.
//// Used to transform a threshold range from (0.0 - 1.0) to 
//// (0.0 - smoothing, 1.0 + smoothing).
//float stretch(float a)
//{
	//return (2.0*smoothing + 1.0) * a - smoothing;
//}

// Combined the old calculation functions into one.
// Same as ease(a - 0.5 + stretch(threshold))
float get_value(float a, float t)
{
	return (a + t * (2.0 * smoothing + 1.) - smoothing - 1.) / (2.0 * smoothing) + 0.5;
}

bool index_check(sampler2D noise, vec2 uv, float thresh)
{
	return get_value(uv.y, thresh) >= texture(noise, uv).r;
}

vec4 get_color(vec2 uv)
{
	
	if (int((uv.x + uv.y + (speed * TIME)) * density) % 2 == 1)
	{
		return transition_color_b;
	}
	
	return transition_color_a;
}

void fragment() {
	
	vec2 new_uv = floor(UV * multiplier) / multiplier;
	
	if (index_check(transition_noise, new_uv, threshold))
	{
		COLOR = get_color(new_uv);
	}
	
	// DEBUG VIEW
	//COLOR.b = index;
	//COLOR.r = texture(noise, new_uv).r;
}
