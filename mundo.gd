extends Node2D
# Base del Taller 4. construir() arma el nivel a partir del MAPA:
# "#" bloque, "." moneda, "o" llave, "^" pinchos.

const ANCHO = 96
const CELDA = 64
const META_X = 6080.0
const PERFIL_SUELO = [
	Vector2(0, 576), Vector2(12 * 64, 576), Vector2(20 * 64, 480),
	Vector2(28 * 64, 480), Vector2(36 * 64, 576), Vector2(44 * 64, 576),
	Vector2(52 * 64, 464), Vector2(60 * 64, 464), Vector2(68 * 64, 576),
	Vector2(76 * 64, 576), Vector2(84 * 64, 480), Vector2(90 * 64, 480),
	Vector2(96 * 64, 576)
]
var coleccionables := 0
var llaves_recogidas := 0

var moneda_escena = preload("res://moneda.tscn")
var llave_escena = preload("res://llave.tscn")
var pinchos_escena = preload("res://pinchos.tscn")


func _ready():
	$Cubo.meta_x = META_X
	construir()
	$HUD/Mensaje.text = "PULSO NEÓN  ·  INTERMEDIO"
	$Cubo.position = Vector2(160, 540)
	$Cubo.llegada.connect(_nivel_completado)
	$Cubo.recolectado.connect(_sumar_recoleccion)
	$HUD/Menu.pressed.connect(func(): get_tree().change_scene_to_file("res://menu.tscn"))
	$HUD/Reintentar.pressed.connect(func(): get_tree().reload_current_scene())
	$HUD/Pausa.pressed.connect(_pausar)
	$HUD/PausaPanel/Contenido/Continuar.pressed.connect(_continuar)
	$HUD/PausaPanel/Contenido/Salir.pressed.connect(_salir_al_menu)

func _process(_delta: float) -> void:
	$HUD/Puntaje.text = "PROGRESO  %d%%     ·     OBJETOS  %d     ·     LLAVES  %d/3" % [$Cubo.progreso(), coleccionables, llaves_recogidas]

func _sumar_recoleccion(_nombre: String) -> void:
	coleccionables += 1
	if _nombre == "LLAVE":
		llaves_recogidas += 1


func construir():
	var mapa := _crear_mapa()
	_crear_terreno()
	for fila in mapa.size():
		for col in mapa[fila].length():
			var escena = null
			match mapa[fila][col]:
				".":
					escena = moneda_escena
				"o":
					escena = llave_escena
				"^":
					escena = pinchos_escena
			if escena:
				var nodo = escena.instantiate()
				var x := (col + 0.5) * CELDA
				nodo.position = Vector2(x, _altura_suelo(x) + (fila - 8.5) * CELDA)
				$Mapa.add_child(nodo)

func _crear_mapa() -> Array[String]:
	var mapa: Array[String] = []
	for i in 10:
		mapa.append(" ".repeat(ANCHO))
	# Tramos con espacio para reaccionar y saltos encadenados; el último deja ver la meta.
	for col in [10, 22, 23, 35, 36, 48, 60, 61, 73, 74, 85]:
		_poner(mapa, 8, col, "^")
	# Los objetos quedan al nivel del cubo en tramos despejados: se recogen al avanzar.
	for col in [5, 32, 44, 64, 70, 91]:
		_poner(mapa, 7, col, ".")
	for col in [18, 51, 82]:
		_poner(mapa, 7, col, "o")
	return mapa

func _poner(mapa: Array[String], fila: int, col: int, simbolo: String) -> void:
	var linea := mapa[fila]
	mapa[fila] = linea.substr(0, col) + simbolo + linea.substr(col + 1)

func _altura_suelo(x: float) -> float:
	for i in range(PERFIL_SUELO.size() - 1):
		var inicio: Vector2 = PERFIL_SUELO[i]
		var fin: Vector2 = PERFIL_SUELO[i + 1]
		if x <= fin.x:
			var t := clampf((x - inicio.x) / (fin.x - inicio.x), 0.0, 1.0)
			t = t * t * (3.0 - 2.0 * t)
			return lerpf(inicio.y, fin.y, t)
	return PERFIL_SUELO[-1].y

func _crear_terreno() -> void:
	# Dos huecos obligan a saltar; no tienen pared lateral, así que el cubo cae al vacío.
	var tramos := [Vector2(0, 27 * CELDA), Vector2(30 * CELDA, 65 * CELDA), Vector2(68 * CELDA, ANCHO * CELDA)]
	for tramo in tramos:
		_agregar_tramo_suelo(int(tramo.x), int(tramo.y))

func _agregar_tramo_suelo(x_inicio: int, x_fin: int) -> void:
	var puntos := PackedVector2Array()
	for x in range(x_inicio, x_fin, 8):
		puntos.append(Vector2(x, _altura_suelo(x)))
	puntos.append(Vector2(x_fin, _altura_suelo(x_fin)))
	var dibujo_puntos := puntos.duplicate()
	dibujo_puntos.append(Vector2(x_fin, 900))
	dibujo_puntos.append(Vector2(x_inicio, 900))
	var dibujo := Polygon2D.new()
	dibujo.polygon = dibujo_puntos
	dibujo.color = Color("#20264f")
	$Mapa.add_child(dibujo)
	var borde := Line2D.new()
	for punto in puntos:
		borde.add_point(punto)
	borde.width = 5.0
	borde.default_color = Color("#35f2ff")
	$Mapa.add_child(borde)
	var segmentos := PackedVector2Array()
	for i in range(puntos.size() - 1):
		segmentos.append(puntos[i])
		segmentos.append(puntos[i + 1])
	var forma_suelo := ConcavePolygonShape2D.new()
	forma_suelo.set_segments(segmentos)
	var suelo := StaticBody2D.new()
	var colision := CollisionShape2D.new()
	colision.shape = forma_suelo
	suelo.add_child(colision)
	$Mapa.add_child(suelo)

func _nivel_completado() -> void:
	$Cubo.set_physics_process(false)
	$Cubo/Musica.stop()
	$HUD/Mensaje.text = "¡NIVEL COMPLETADO!  LLAVES: %d/3" % llaves_recogidas
	$HUD/Mensaje.add_theme_color_override("font_color", Color("#35f2ff"))
	$HUD/Menu.visible = true
	$HUD/Reintentar.visible = true
	$HUD/Pausa.visible = false

func _pausar() -> void:
	get_tree().paused = true
	$HUD/PausaPanel.visible = true

func _continuar() -> void:
	$HUD/PausaPanel.visible = false
	get_tree().paused = false

func _salir_al_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu.tscn")
