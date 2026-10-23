extends Control

const COLOR_PATH = "user://plagio_dash.cfg"
const BORDE_DEFAULT = Color("#ffe600")
const CENTRO_DEFAULT = Color("#00e5ff")

func _ready() -> void:
	_build_menu()

func _build_menu() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#10132d")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var deco := ColorRect.new()
	deco.color = Color("#1a2050")
	deco.position = Vector2(0, 540)
	deco.size = Vector2(1280, 180)
	add_child(deco)

	var title := Label.new()
	title.text = "PLAGIO DASH"
	title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 58
	title.offset_bottom = 145
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 68)
	title.add_theme_color_override("font_color", Color("#35f2ff"))
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = "UN SALTO. UN RITMO. ¿HASTA DÓNDE LLEGAS?"
	subtitle.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	subtitle.offset_top = 148
	subtitle.offset_bottom = 184
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color("#a9b2df"))
	add_child(subtitle)

	var card := PanelContainer.new()
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.position = Vector2(-205, -116)
	card.custom_minimum_size = Vector2(410, 232)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#20264f")
	style.border_color = Color("#46518e")
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 24
	style.content_margin_bottom = 24
	card.add_theme_stylebox_override("panel", style)
	add_child(card)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	card.add_child(content)
	var level_title := Label.new()
	level_title.text = "NIVEL 01  ·  PULSO NEÓN"
	level_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_title.add_theme_font_size_override("font_size", 25)
	level_title.add_theme_color_override("font_color", Color.WHITE)
	content.add_child(level_title)
	var info := Label.new()
	info.text = "Dificultad: INTERMEDIA     •     Duración: ~20 s\nSalta con ESPACIO, W, ↑ o clic."
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", 16)
	info.add_theme_color_override("font_color", Color("#c1c8eb"))
	content.add_child(info)
	var play := Button.new()
	play.text = "▶   JUGAR"
	play.custom_minimum_size = Vector2(0, 54)
	play.add_theme_font_size_override("font_size", 23)
	play.add_theme_color_override("font_color", Color("#10132d"))
	var play_style := StyleBoxFlat.new()
	play_style.bg_color = Color("#35f2ff")
	play_style.set_corner_radius_all(12)
	play.add_theme_stylebox_override("normal", play_style)
	play.pressed.connect(func(): get_tree().change_scene_to_file("res://mundo.tscn"))
	content.add_child(play)

	var customize := VBoxContainer.new()
	customize.set_anchors_preset(Control.PRESET_TOP_LEFT)
	customize.offset_left = 38
	customize.offset_top = 285
	customize.offset_right = 245
	customize.offset_bottom = 495
	customize.add_theme_constant_override("separation", 10)
	add_child(customize)
	var color_label := Label.new()
	color_label.text = "PERSONALIZA TU CUBO"
	color_label.add_theme_font_size_override("font_size", 15)
	color_label.add_theme_color_override("font_color", Color.WHITE)
	customize.add_child(color_label)
	_add_color_picker(customize, "Borde", "border", _load_color("border", BORDE_DEFAULT))
	_add_color_picker(customize, "Centro", "center", _load_color("center", CENTRO_DEFAULT))

	var footer := Label.new()
	footer.text = "PLAGIO DASH  •  HECHO PARA JUGAR"
	footer.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_top = -48
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 13)
	footer.add_theme_color_override("font_color", Color("#7882b8"))
	add_child(footer)

func _add_color_picker(parent: VBoxContainer, label_text: String, key: String, initial: Color) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 72
	label.add_theme_color_override("font_color", Color("#c1c8eb"))
	row.add_child(label)
	var picker := ColorPickerButton.new()
	picker.custom_minimum_size = Vector2(120, 36)
	picker.color = initial
	picker.color_changed.connect(func(color: Color): _save_color(key, color))
	row.add_child(picker)
	parent.add_child(row)

func _load_color(key: String, fallback: Color) -> Color:
	var cfg := ConfigFile.new()
	if cfg.load(COLOR_PATH) == OK:
		if key == "center":
			fallback = cfg.get_value("player", "color", fallback)
		return cfg.get_value("player", key, fallback)
	return fallback

func _save_color(key: String, color: Color) -> void:
	var cfg := ConfigFile.new()
	cfg.load(COLOR_PATH)
	cfg.set_value("player", key, color)
	cfg.save(COLOR_PATH)
