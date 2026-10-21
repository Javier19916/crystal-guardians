extends Node
const SAVE_PATH: String = "user://savegame.json"
var pending_data: Dictionary = {}

func save_game(
	player: CharacterBody2D,
	level_path: String
) -> bool:
	var data: Dictionary = {
		"version": 1,
		"level_path": level_path,
		"health": player.health,
		"position_x": player.global_position.x,
		"position_y": player.global_position.y,
		"quest_state": QuestManager.quest_state,
		"collected_crystals": QuestManager.collected_crystals,
		# Nombres de los cristales que siguen en el mapa (los recogidos ya no estan)
		"remaining_crystals": _get_remaining_crystals()
	}
	var file: FileAccess = FileAccess.open(
		SAVE_PATH,
		FileAccess.WRITE
	)
	if file == null:
		push_error("No se pudo guardar la partida")
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	print("La partida se creo correctamente")
	return true

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No hay partida guardada")
		return
	var file: FileAccess = FileAccess.open(
		SAVE_PATH,
		FileAccess.READ
	)
	if file == null:
		push_error("No se pudo abrir la partida")
		return
	var json_text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(json_text)
	if not (parsed is Dictionary):
		push_error("Archivo de guardado invalido")
		return
	var data: Dictionary = parsed
	var level_path: String = str(
		data.get("level_path")
	)
	if level_path.is_empty():
		return
	if not ResourceLoader.exists(level_path):
		push_error("El nivel guardado no existe")
		return
	pending_data = data
	get_tree().paused = false
	get_tree().change_scene_to_file.call_deferred(level_path)

# ¿Hay una partida guardada en el disco?
func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func apply_save_data(player: CharacterBody2D) -> void:
	if pending_data.is_empty():
		return
	player.health = clampi(
		int(pending_data.get("health", player.max_health)),
		0,
		player.max_health
	)
	player.global_position = Vector2(
		float(pending_data.get("position_x", 0)),
		float(pending_data.get("position_y", 0))
	)
	# La vida ahora se dibuja con corazones en el HUD, que se
	# actualiza solo con la señal health_changed de abajo.
	player.health_changed.emit(
		player.health,
		player.max_health
	)
	QuestManager.collected_crystals = int(
		pending_data.get("collected_crystals", 0)
	)
	QuestManager.quest_state = int(
		pending_data.get("quest_state", 
		QuestManager.QuestState.NOT_STARTED)
	) as QuestManager.QuestState
	QuestManager.quest_updated.emit()
	_remove_collected_crystals(pending_data.get("remaining_crystals", null))
	pending_data.clear()

# Devuelve los nombres de los cristales que todavia no se recogen
func _get_remaining_crystals() -> Array:
	var names: Array = []
	var crystals := get_tree().current_scene.get_node_or_null("crystals")
	if crystals:
		for crystal in crystals.get_children():
			names.append(String(crystal.name))
	return names

# Al cargar, quito del mapa los cristales que ya se habian recogido
func _remove_collected_crystals(remaining: Variant) -> void:
	if not (remaining is Array):
		return
	var crystals := get_tree().current_scene.get_node_or_null("crystals")
	if crystals == null:
		return
	for crystal in crystals.get_children():
		if not remaining.has(String(crystal.name)):
			crystal.queue_free()
