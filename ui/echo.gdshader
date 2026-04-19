shader_type canvas_item;

uniform float thickness = 0.05;
uniform float speed = 0.5;
uniform float max_radius = 0.3;
uniform vec4 color : source_color = vec4(1.0);

uniform float time = 0.0;

void fragment() {
    float dist = distance(UV, vec2(0.5));

    float radius = time * speed;

    float fade_start = max_radius * 0.3;
    float fade = 1.0 - smoothstep(fade_start, max_radius, radius);

    float d = abs(dist - radius);
    float ring = 1.0 - smoothstep(0.0, thickness, d);

    float alpha = ring * fade;

    COLOR = vec4(color.rgb, color.a * alpha);
}