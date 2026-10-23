extends CharacterBody2D
# Solución del Taller 3 (solo profesor).

signal llegada
signal recolectado(nombre: String)

@export var speed = 380.0       # px/s hacia la derecha
@export var gravedad = 2400.0   # px/s²
@export var salto = 880.0       # px/s hacia arriba
@export var giro = 300.0        # grados por segundo en el aire
@export var meta_x = 4000.0     # dónde termina el nivel

var inicio = Vector2.ZERO
var muriendo = false
var intentos = 1

@onready var sprite = $AnimatedSprite2D
@onready var musica = $Musica
@onready var sonido_explosion = $Explosion


func _ready():
	inicio = position
	$Sensor.area_entered.connect(_al_tocar_area)
	$Hurtbox.area_entered.connect(_al_tocar_pincho)
	var cfg := ConfigFile.new()
	if cfg.load("user://plagio_dash.cfg") == OK and sprite.material is ShaderMaterial:
		var shader_material := sprite.material as ShaderMaterial
		shader_material.set_shader_parameter("border_color", cfg.get_value("player", "border", Color("#ffe600")))
		shader_material.set_shader_parameter("center_color", cfg.get_value("player", "center", cfg.get_value("player", "color", Color("#00e5ff"))))
	musica.play()   # una sola vez: el archivo ya viene en bucle

func _al_tocar_area(area: Area2D) -> void:
	if area.is_in_group("monedas"):
		recolectado.emit("LLAVE" if area.is_in_group("llaves") else "MONEDA")
		area.queue_free()

func _al_tocar_pincho(area: Area2D) -> void:
	if area.is_in_group("enemigos") and not muriendo:
		morir()


func _physics_process(delta):
	if muriendo:
		return
	mover(delta)
	if position.y > 760.0:
		morir()
		return
	if position.x >= meta_x:
		llegada.emit()
		return
	if is_on_wall():
		morir()
		return
	girar(delta)


func mover(delta):
	velocity.x = speed
	if is_on_floor():
		if Input.is_action_pressed("saltar"):
			velocity.y = -salto
	else:
		velocity.y += gravedad * delta
	move_and_slide()


# Nivel 1: gira en el aire (lo decide is_on_floor, no la tecla). Nivel 2: aterriza derecho.
func girar(delta):
	if not is_on_floor():
		sprite.rotation += deg_to_rad(giro) * delta
	else:
		sprite.rotation = snappedf(sprite.rotation, PI / 2)


# Nivel 3
func progreso() -> int:
	return int(clampf((position.x - inicio.x) / (meta_x - inicio.x), 0.0, 1.0) * 100)


func morir():
	muriendo = true
	print("Intento %d: %d%%" % [intentos, progreso()])
	velocity = Vector2.ZERO
	musica.stop()
	sonido_explosion.play()
	sprite.rotation = 0.0
	sprite.play("explotar")
	await sprite.animation_finished
	position = inicio
	sprite.play("normal")
	intentos += 1
	musica.play()   # en Geometry Dash la música sí vuelve a empezar con cada intento
	muriendo = false
