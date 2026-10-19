extends CanvasLayer
## HUD del juego: corazones de vida, contador de cristales y misión actual.
##
## Cada corazón vale HP_PER_HEART puntos de vida. Se dibuja con un
## TextureProgressBar: abajo el corazón gris (vacío) y encima el rojo (lleno),
## que se "recorta" de izquierda a derecha según la vida que le queda.
## Así, con 10 de daño se ve medio corazón, sin necesitar más imágenes.

const HP_PER_HEART: int = 20
const HEART_SHEET: Texture2D = preload("res://assets/ui/44_corazones_vida.png")
# Recortes dentro de la hoja 44_corazones_vida.png (1er corazón rojo y el gris).
const FULL_HEART_REGION := Rect2(6, 0, 30, 28)
const EMPTY_HEART_REGION := Rect2(138, 0, 30, 28)
const HEART_SIZE := Vector2(32, 30)

@onready var health_panel: PanelContainer = $HUDContainer/TopLeft/HealthPanel
@onready var hearts_container: HBoxContainer = $HUDContainer/TopLeft/HealthPanel/HBox/HeartsContainer
@onready var health_label: Label = $HUDContainer/TopLeft/HealthPanel/HBox/HealthLabel
@onready var crystal_label: Label = $HUDContainer/TopLeft/CrystalsPanel/HBox/CrystalLabel
@onready var quest_label: Label = $HUDContainer/QuestPanel/VBox/QuestLabel

var full_heart_texture: AtlasTexture
var empty_heart_texture: AtlasTexture
var last_health: int = -1

func _ready() -> void:
	full_heart_texture = _make_heart_texture(FULL_HEART_REGION)
	empty_heart_texture = _make_heart_texture(EMPTY_HEART_REGION)
	QuestManager.quest_updated.connect(update_quest_info)
	update_quest_info()

func update_health(current: int, max: int) -> void:
	var heart_count: int = ceili(float(max) / HP_PER_HEART)
	if hearts_container.get_child_count() != heart_count:
		_build_hearts(heart_count)

	for i in heart_count:
		var heart: TextureProgressBar = hearts_container.get_child(i)
		heart.value = clampi(current - i * HP_PER_HEART, 0, HP_PER_HEART)

	health_label.text = "%d/%d" % [current, max]

	# Pequeño destello rojo cuando el jugador recibe daño.
	if last_health != -1 and current < last_health:
		_play_damage_feedback()
	last_health = current

func update_quest_info() -> void:
	crystal_label.text = "%d/%d" % [
		QuestManager.collected_crystals,
		QuestManager.required_crystals
	]
	match QuestManager.quest_state:
		QuestManager.QuestState.NOT_STARTED:
			quest_label.text = "Habla con Han Solo"
		QuestManager.QuestState.ACTIVE:
			quest_label.text = "Recolecta los cristales"
		QuestManager.QuestState.READY_TO_DELIVER:
			quest_label.text = "Entrega los cristales a Han Solo"
		QuestManager.QuestState.COMPLETED:
			quest_label.text = "¡Misión completada!"

# --- Funciones auxiliares ---------------------------------------------------

func _make_heart_texture(region: Rect2) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = HEART_SHEET
	texture.region = region
	return texture

func _build_hearts(count: int) -> void:
	for child in hearts_container.get_children():
		child.queue_free()
		hearts_container.remove_child(child)
	for i in count:
		var heart := TextureProgressBar.new()
		heart.texture_under = empty_heart_texture
		heart.texture_progress = full_heart_texture
		heart.nine_patch_stretch = true
		heart.custom_minimum_size = HEART_SIZE
		heart.max_value = HP_PER_HEART
		heart.value = HP_PER_HEART
		heart.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hearts_container.add_child(heart)

func _play_damage_feedback() -> void:
	var tween := create_tween()
	health_panel.modulate = Color(1.0, 0.45, 0.45)
	tween.tween_property(health_panel, "modulate", Color.WHITE, 0.35)
