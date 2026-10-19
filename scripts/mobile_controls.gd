extends CanvasLayer
## Controles táctiles: joystick virtual (movimiento) + botones de ataque e interacción.
##
## Idea clave: en vez de mover al jugador desde aquí, el joystick "presiona"
## las mismas acciones del Input Map que usa el teclado (move_left, move_right,
## move_up, move_down). Así player.gd no necesita saber si el jugador usa
## teclado o pantalla táctil: Input.get_vector() funciona igual en ambos casos.
## Los botones de ataque e interacción son TouchScreenButton con su propiedad
## "action" configurada en la escena (player_attack / interact).

@onready var joystick_base: Control = $Controls/JoystickBase
@onready var joystick_knob: Control = $Controls/JoystickBase/JoystickKnob

@export var joystick_radius: float = 65.0
@export var deadzone: float = 0.15

var joystick_direction: Vector2 = Vector2.ZERO
var active_touch_index: int = -1

func _ready() -> void:
	reset_joystick()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if active_touch_index == -1:
				if is_inside_joystick(event.position):
					active_touch_index = event.index
					update_joystick(event.position)
					get_viewport().set_input_as_handled()
		elif event.index == active_touch_index:
			active_touch_index = -1
			reset_joystick()
	elif event is InputEventScreenDrag:
		if event.index == active_touch_index:
			update_joystick(event.position)
			get_viewport().set_input_as_handled()

## Devuelve true si el toque cayó dentro del círculo del joystick.
## Se usa un margen extra para que sea fácil "atinarle" con el pulgar.
func is_inside_joystick(screen_position: Vector2) -> bool:
	var center := _get_joystick_center()
	var touch_radius := joystick_base.size.x / 2.0 + 40.0
	return screen_position.distance_to(center) <= touch_radius

## Mueve la perilla hacia el dedo (sin salir del radio) y calcula la dirección.
func update_joystick(screen_position: Vector2) -> void:
	var center := _get_joystick_center()
	var offset := (screen_position - center).limit_length(joystick_radius)

	# La perilla se posiciona relativa a la base (centrada + desplazamiento).
	joystick_knob.position = _get_knob_rest_position() + offset

	# Dirección normalizada entre 0 y 1; debajo de la zona muerta no se mueve.
	var direction := offset / joystick_radius
	if direction.length() < deadzone:
		direction = Vector2.ZERO
	joystick_direction = direction
	_apply_direction_to_actions(joystick_direction)

## Devuelve la perilla al centro y suelta las acciones de movimiento.
func reset_joystick() -> void:
	joystick_direction = Vector2.ZERO
	joystick_knob.position = _get_knob_rest_position()
	_apply_direction_to_actions(Vector2.ZERO)

# --- Funciones auxiliares ---------------------------------------------------

func _get_joystick_center() -> Vector2:
	return joystick_base.get_global_rect().get_center()

func _get_knob_rest_position() -> Vector2:
	return (joystick_base.size - joystick_knob.size) / 2.0

## Traduce la dirección del joystick a las acciones del Input Map.
## La "fuerza" de cada acción (0..1) permite caminar lento si el dedo
## está cerca del centro y rápido si está en el borde.
func _apply_direction_to_actions(direction: Vector2) -> void:
	_set_axis("move_left", "move_right", direction.x)
	_set_axis("move_up", "move_down", direction.y)

func _set_axis(negative_action: String, positive_action: String, value: float) -> void:
	if value < 0.0:
		Input.action_release(positive_action)
		Input.action_press(negative_action, -value)
	elif value > 0.0:
		Input.action_release(negative_action)
		Input.action_press(positive_action, value)
	else:
		Input.action_release(negative_action)
		Input.action_release(positive_action)
