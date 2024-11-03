extends TextureRect

@export var tween_intensity: float = 1.1
@export var tween_duration: float = 0.5

@onready var texture_rect: TextureRect = self

func _process(delta: float) -> void:
	texture_hovered(texture_rect)

func start_tween(object: Object, property: String, final_val: Variant, duration: float):
	var tween = create_tween()
	tween.tween_property(object, property, final_val, duration)

func texture_hovered(texture: TextureRect):
	# Centrer le pivot pour la mise à l'échelle depuis le milieu
	texture.pivot_offset = texture.size / 2
	
	# Définir un Rect2 basé sur la taille de TextureRect
	var rect = Rect2(Vector2.ZERO, texture.size)
	var mouse_position = texture.get_local_mouse_position()
	
	# Vérifier si la souris est dans les limites de TextureRect
	if rect.has_point(mouse_position):
		start_tween(texture, "scale", Vector2.ONE * tween_intensity, tween_duration)
	else:
		start_tween(texture, "scale", Vector2.ONE, tween_duration)
