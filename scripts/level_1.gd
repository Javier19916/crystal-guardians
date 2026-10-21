extends Node2D

# Nivel 1.
# El contador de cristales y la mision los maneja el GameHUD con el
# QuestManager, por eso aqui ya no se usa el CrystalLabel viejo.

@onready var player = $player
@onready var game_hud = $GameHUD
@onready var game_over = $GameOver


func _ready() -> void:
	player.health_changed.connect(game_hud.update_health)
	game_hud.update_health(player.health, player.max_health)

	# Cuando el jugador muere sale la pantalla de Game Over
	player.died.connect(game_over.show_game_over)

	# Si venimos de "Volver al checkpoint", dejo al jugador
	# con la vida, posicion y mision que tenia guardadas
	SaveManager.apply_save_data(player)
