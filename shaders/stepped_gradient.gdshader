shader_type canvas_item;

uniform vec4 first_color = vec4(1.0);
uniform vec4 second_color = vec4(0, 0, 0, 1.0);
uniform float position : hint_range(-2, 2) = 0.5;
uniform int stepIntensify : hint_range(1, 100) = 10;

void fragment() {
	float pos = round(smoothstep(0,1,(position + UV.y) / 2.0) * float(stepIntensify));
	COLOR = mix(first_color,second_color,pos/float(stepIntensify)); 
}