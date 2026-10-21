extends Area2D

# Checkpoint (punto de guardado).
# Cuando el jugador pasa por la bandera, se guarda la partida con el
# SaveManager: nivel, vida, posicion, mision y cristales.
# La bandera cambia de gris a dorado y sale el aviso "¡Partida guardada!".

const COLOR_OFF := Color(0.55, 0.58, 0.62)
const COLOR_ON := Color(1.0, 0.8, 0.3)

@onready var flag: Polygon2D = $Flag
@onready var message: Label = $Message

var activated: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	flag.color = COLOR_OFF
	message.hide()

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	# Si el jugador esta muerto no guardo nada
	if body.is_dead:
		return

	var level_path: String = get_tree().current_scene.scene_file_path
	if SaveManager.save_game(body, level_path):
		activate()

func activate() -> void:
	# Aunque ya este activo, vuelvo a guardar (por si cambio la vida o la mision),
	# pero la animacion solo la muestro la primera vez.
	if activated:
		return
	activated = true
	flag.color = COLOR_ON
	_show_message()

func _show_message() -> void:
	message.show()
	message.modulate.a = 1.0
	message.position.y = -70.0
	var tween := create_tween()
	tween.tween_property(message, "position:y", -95.0, 1.2)
	tween.parallel().tween_property(message, "modulate:a", 0.0, 1.2).set_delay(0.6)
	tween.tween_callback(message.hide)
