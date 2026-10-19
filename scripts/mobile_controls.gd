extends CanvasLayer
# Controles tactiles con joystick FLOTANTE.
#
# El joystick no esta fijo: aparece justo donde pongo el dedo
# dentro de la zona izquierda de la pantalla. Mientras arrastro,
# la perilla sigue al dedo (sin salirse del aro) y el personaje
# camina hacia ese lado. Al soltar, el joystick vuelve a su lugar
# de descanso y el personaje se detiene.
#
# Para mover al jugador no lo toco directamente: "presiono" las
# mismas acciones del teclado (move_left, move_right, move_up,
# move_down). Asi player.gd sigue igual y sirve con ambos controles.

signal direction_changed(direction: Vector2)

@export var max_distance: float = 70.0     # cuanto se puede alejar la perilla
@export_range(0.0, 0.5) var dead_zone: float = 0.2   # zona donde no se mueve
@export var idle_opacity: float = 0.35     # que tan visible esta sin usarse

@onready var touch_zone: Control = $TouchZone
@onready var ring: Control = $TouchZone/Ring
@onready var stick: Control = $TouchZone/Ring/Stick

var finger_id: int = -1           # dedo que esta usando el joystick (-1 = ninguno)
var origin: Vector2 = Vector2.ZERO  # donde empezo el toque
var rest_center: Vector2 = Vector2.ZERO  # donde descansa el aro
var current_direction: Vector2 = Vector2.ZERO

const MOVE_ACTIONS := {
	"move_left": Vector2.LEFT,
	"move_right": Vector2.RIGHT,
	"move_up": Vector2.UP,
	"move_down": Vector2.DOWN,
}

func _ready() -> void:
	# Guardo la posicion inicial del aro para regresar ahi al soltar
	rest_center = ring.position + ring.size / 2.0
	reset_joystick()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and finger_id == -1 and is_inside_joystick(event.position):
			# Empieza un toque nuevo dentro de la zona del joystick
			finger_id = event.index
			origin = event.position
			_place_ring_at(origin)
			update_joystick(event.position)
			get_viewport().set_input_as_handled()
		elif not event.pressed and event.index == finger_id:
			# Solte el dedo que manejaba el joystick
			reset_joystick()
	elif event is InputEventScreenDrag and event.index == finger_id:
		update_joystick(event.position)
		get_viewport().set_input_as_handled()

# ¿El toque cayo en la zona del joystick?
# La zona es la mitad izquierda de la pantalla, de la mitad hacia abajo,
# asi el dedo puede apoyarse en cualquier parte comoda.
func is_inside_joystick(screen_position: Vector2) -> bool:
	var zone := touch_zone.get_global_rect()
	return zone.has_point(screen_position)

# Calcula la direccion a partir de donde esta el dedo y mueve la perilla.
func update_joystick(screen_position: Vector2) -> void:
	var drag := screen_position - origin
	var distance := minf(drag.length(), max_distance)
	var dir_unit := drag.normalized() if drag.length() > 0.0 else Vector2.ZERO

	# La perilla se queda dentro del aro
	stick.position = (ring.size - stick.size) / 2.0 + dir_unit * distance

	# Fuerza de 0 a 1. Lo que este dentro de la zona muerta cuenta como 0
	# y el resto se reescala para que el movimiento empiece suave.
	var strength := distance / max_distance
	if strength < dead_zone:
		strength = 0.0
	else:
		strength = (strength - dead_zone) / (1.0 - dead_zone)

	_set_direction(dir_unit * strength)

# Regresa todo a como estaba: aro en su lugar, perilla centrada y sin movimiento.
func reset_joystick() -> void:
	finger_id = -1
	_place_ring_at(touch_zone.global_position + rest_center)
	stick.position = (ring.size - stick.size) / 2.0
	ring.modulate.a = idle_opacity
	_set_direction(Vector2.ZERO)

# --- Ayudantes ---------------------------------------------------------------

func _place_ring_at(screen_point: Vector2) -> void:
	# Pongo el centro del aro en el punto tocado (convertido a la zona)
	ring.global_position = screen_point - ring.size / 2.0
	ring.modulate.a = 1.0

func _set_direction(direction: Vector2) -> void:
	if direction == current_direction:
		return
	current_direction = direction
	# Cada accion recibe la parte de la direccion que le toca
	for action in MOVE_ACTIONS:
		var amount: float = maxf(direction.dot(MOVE_ACTIONS[action]), 0.0)
		if amount > 0.0:
			Input.action_press(action, amount)
		else:
			Input.action_release(action)
	direction_changed.emit(direction)
