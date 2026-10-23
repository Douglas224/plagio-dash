shader_type canvas_item;

uniform vec4 border_color : source_color = vec4(1.0, 0.9, 0.0, 1.0);
uniform vec4 center_color : source_color = vec4(0.0, 0.9, 1.0, 1.0);
varying vec4 item_tint;

void vertex() {
	item_tint = COLOR;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	// Reemplaza los colores de la hoja del sprite y conserva los detalles negros.
	float colored_pixel = step(0.10, max(tex.r, max(tex.g, tex.b)));
	float border_mask = colored_pixel * step(tex.b, tex.r);
	float center_mask = colored_pixel * (1.0 - step(tex.b, tex.r));
	vec3 result = mix(tex.rgb, border_color.rgb, border_mask);
	result = mix(result, center_color.rgb, center_mask);
	// COLOR ya llega multiplicado por TEXTURE en fragment; usa la modulación capturada en vertex.
	COLOR = vec4(result, tex.a) * item_tint;
}
