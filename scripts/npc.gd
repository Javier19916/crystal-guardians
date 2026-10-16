extends Node2D

# Script del profesor (NPC).
# El dialogo solo se abre si el jugador esta cerca del profesor
# Y ADEMAS presiona la tecla E (la accion "interact" del proyecto).

@export var npc_name: String = "Profesor"
@export var dialogues: Array[String] = [
	"¡Hola, guardian! Que bueno que llegaste.",
	"Los guardias se robaron los cristales del templo.",
	"Necesito que recojas los 3 cristales y me los traigas.",
	"Ten cuidado con los guardias. ¡Suerte!"
]

@onready var interactive_area: Area2D = $InteractiveArea
@onready var interact_hint: Label = $InteractHint

# Aqui guardo si el jugador esta cerca o no
var player_nearby: bool = false

func _ready() -> void:
	# Escondo el letrero de "Presiona E" al inicio
	interact_hint.hide()
	# Las señales body_entered y body_exited del InteractiveArea
	# ya las conecte desde el editor (pestaña Nodo > Señales),
	# por eso no las vuelvo a conectar aqui con codigo.

func _process(_delta: float) -> void:
	# El letrero "Presiona E" solo sale si estoy cerca y el dialogo esta cerrado
	var dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")
	var dialogue_open: bool = dialogue_ui != null and dialogue_ui.is_open
	interact_hint.visible = player_nearby and not dialogue_open

	# Si estoy cerca y presiono E, hablo con el profesor
	if player_nearby and Input.is_action_just_pressed("interact"):
		interact()

func interact() -> void:
	var dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")
	if dialogue_ui == null:
		return

	if dialogue_ui.is_open:
		# Si ya esta abierto, la E pasa a la siguiente linea
		dialogue_ui.next_dialogue()
	else:
		# Si esta cerrado, lo abro con el nombre y las lineas del profesor
		dialogue_ui.show_dialogue(npc_name, dialogues)

# Se llama cuando algo ENTRA al area del profesor
func _on_interactive_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true

# Se llama cuando algo SALE del area del profesor
func _on_interactive_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		# Si el jugador se aleja, cierro el dialogo
		var dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")
		if dialogue_ui and dialogue_ui.is_open:
			dialogue_ui.close_dialogue()
