shader_type spatial;
render_mode cull_front, unshaded, depth_draw_always;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width = 0.02;

void vertex() {
    // This pushes the vertices out relative to the object center
    // rather than just the flat face normal.
    VERTEX += normalize(VERTEX) * outline_width;
}

void fragment() {
    ALBEDO = outline_color.rgb;
    ALPHA = outline_color.a;
}