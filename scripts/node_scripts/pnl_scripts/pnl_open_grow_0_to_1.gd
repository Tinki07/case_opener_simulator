extends Panel  # Remplace par le type exact du panneau si ce n'est pas un Control

@export var open_duration: float = 0.5  # Durée de l'animation d'ouverture

@onready var tween: Tween = create_tween()

func _ready():
	# Définir le pivot au centre pour l'animation d'ouverture
	self.pivot_offset = self.size / 2
	# Masquer le panneau au début
	self.scale = Vector2.ZERO

func open_panel():
	# Anime l'ouverture du panneau depuis une échelle de 0 à 1
	tween.tween_property(self, "scale", Vector2.ONE, open_duration)
