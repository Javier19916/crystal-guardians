extends CanvasLayer

# Script del cuadro de dialogo.
# El panel empieza escondido y solo lo muestro cuando el profesor
# (el NPC) me llama a show_dialogue().

# Aqui guardo los nodos de la escena que voy a usar
@onready var panel: Panel = $Panel
@onready var name_label: Label = $Panel/NameLabel
@onready var dialogue_label: Label = $Panel/DialogueLabel
@onready var continue_button: Button = $Panel/ContinueButton

# Aqui guardo las lineas que se van a decir y en cual voy
var current_dialogues: Array[String] = []
var dialogue_index: int = 0
var is_open: bool = false

func _ready() -> void:
	# Lo meto a un grupo para que el NPC lo pueda encontrar facil
	add_to_group("dialogue")
	# Al iniciar el juego escondo el panel
	panel.hide()
	# Cuando le doy clic al boton paso a la siguiente linea
	continue_button.pressed.connect(next_dialogue)

func show_dialogue(character_name: String, dialogues: Array[String]) -> void:
	# Si no hay nada que decir no abro el panel
	if dialogues.is_empty():
		return
	current_dialogues = dialogues
	dialogue_index = 0
	is_open = true
	name_label.text = character_name
	# Pongo la primera linea, si no el panel saldria vacio
	dialogue_label.text = current_dialogues[dialogue_index]
	panel.show()

func next_dialogue() -> void:
	dialogue_index += 1
	# Si ya no hay mas lineas cierro el dialogo
	if dialogue_index >= current_dialogues.size():
		close_dialogue()
		return
	dialogue_label.text = current_dialogues[dialogue_index]

func close_dialogue() -> void:
	panel.hide()
	is_open = false
