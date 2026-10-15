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
var player_near: bool = false

func _ready() -> void:
	# Escondo el letrero de "Presiona E" al inicio
	interact_hint.hide()
	# Me conecto al area para saber cuando entra y sale el jugador
	interactive_area.body_entered.connect(_on_body_entered)
	interactive_area.body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	# El letrero "Presiona E" solo sale si estoy cerca y el dialogo esta cerrado
	var dialogue = get_tree().get_first_node_in_group("dialogue")
	var dialogue_open: bool = dialogue != null and dialogue.is_open
	interact_hint.visible = player_near and not dialogue_open

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_near = false
		# Si el jugador se aleja, cierro el dialogo
		var dialogue = get_tree().get_first_node_in_group("dialogue")
		if dialogue and dialogue.is_open:
			dialogue.close_dialogue()

func _unhandled_input(event: InputEvent) -> void:
	# Si el jugador no esta cerca, la E no hace nada
	if not player_near:
		return
	if not event.is_action_pressed("interact"):
		return

	var dialogue = get_tree().get_first_node_in_group("dialogue")
	if dialogue == null:
		return

	if dialogue.is_open:
		# Si ya esta abierto, la E pasa a la siguiente linea
		dialogue.next_dialogue()
	else:
		# Si esta cerrado, lo abro con el nombre y las lineas del profesor
		dialogue.show_dialogue(npc_name, dialogues)

	get_viewport().set_input_as_handled()
