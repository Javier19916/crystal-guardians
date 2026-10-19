extends CanvasLayer

# Pantalla de "Game Over".
# Aparece cuando el jugador muere y permite reiniciar el nivel
# con el boton, con la tecla E o con Enter (sin cerrar el juego).

@onready var panel: Control = $Fondo
@onready var restart_button: Button = $Fondo/Caja/Contenido/RestartButton

func _ready() -> void:
	# Esta capa sigue funcionando aunque el juego este en pausa
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.hide()
	restart_button.pressed.connect(restart_game)

func show_game_over() -> void:
	panel.show()
	# Pauso el juego para que los guardias dejen de moverse
	get_tree().paused = true

func _unhandled_input(event: InputEvent) -> void:
	if not panel.visible:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		restart_game()

func restart_game() -> void:
	get_tree().paused = false
	# La mision vive en un autoload, asi que hay que reiniciarla a mano
	QuestManager.reset_quest()
	# Vuelvo a cargar la escena actual desde cero
	get_tree().reload_current_scene()
