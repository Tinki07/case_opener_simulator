extends Panel  # Utilise Panel au lieu de TextureRect

@export var tween_intensity: float = 1.1
@export var tween_duration: float = 0.3

@onready var panel: Panel = self

func _process(delta: float) -> void:
	panel_hovered(panel)

func start_tween(object: Object, property: String, final_val: Variant, duration: float):
	var tween = create_tween()  # Crée un Tween
	tween.tween_property(object, property, final_val, duration)

func panel_hovered(panel: Panel):
	# Centrer le pivot pour la mise à l'échelle depuis le milieu
	panel.pivot_offset = panel.size / 2
	
	# Définir un Rect2 basé sur la taille du Panel
	var rect = Rect2(Vector2.ZERO, panel.size)
	var mouse_position = panel.get_local_mouse_position()

	# Vérifier si la souris est dans les limites du Panel
	if rect.has_point(mouse_position):
		start_tween(panel, "scale", Vector2.ONE * tween_intensity, tween_duration)
	else:
		start_tween(panel, "scale", Vector2.ONE, tween_duration)
