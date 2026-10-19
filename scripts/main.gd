extends Node2D

@onready var player = $player
@onready var game_hud = $GameHUD
# Controles táctiles (joystick + botones). No necesitan conexión de señales:
# se comunican con el jugador a través de las acciones del Input Map.
@onready var mobile_controls = $MobileControls


func _ready() -> void:
	player.health_changed.connect(game_hud.update_health)
	game_hud.update_health(player.health, player.max_health)
