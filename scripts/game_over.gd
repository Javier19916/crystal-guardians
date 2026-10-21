extends CanvasLayer

# Pantalla de "Game Over".
# Aparece cuando el jugador muere y deja elegir:
#  - Volver al checkpoint: carga la ultima partida guardada (tecla E / Enter).
#  - Reiniciar nivel: empieza el nivel desde cero (tecla R).
# Si todavia no paso por ningun checkpoint, solo sale "Reiniciar nivel".

@onready var panel: Control = $Fondo
@onready var load_button: Button = $Fondo/Caja/Contenido/LoadButton
@onready var restart_button: Button = $Fondo/Caja/Contenido/RestartButton

func _ready() -> void:
	# Esta capa sigue funcionando aunque el juego este en pausa
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.hide()
	load_button.pressed.connect(load_checkpoint)
	restart_button.pressed.connect(restart_game)

func show_game_over() -> void:
	# El boton del checkpoint solo aparece si hay algo guardado
	load_button.visible = SaveManager.has_save()
	panel.show()
	# Pauso el juego para que los guardias dejen de moverse
	get_tree().paused = true

func _unhandled_input(event: InputEvent) -> void:
	if not panel.visible:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		restart_game()
	elif event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		if load_button.visible:
			load_checkpoint()
		else:
			restart_game()

func load_checkpoint() -> void:
	# El SaveManager quita la pausa y cambia al nivel guardado;
	# al cargar, el nivel llama a apply_save_data() para dejar todo como estaba.
	SaveManager.load_game()

func restart_game() -> void:
	get_tree().paused = false
	# La mision vive en un autoload, asi que hay que reiniciarla a mano
	QuestManager.reset_quest()
	# Vuelvo a cargar la escena actual desde cero
	get_tree().reload_current_scene()
