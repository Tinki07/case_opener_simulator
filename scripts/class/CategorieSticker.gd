extends Node

class_name CategorieSticker

var nom: String
var color: String
var anim_drop_sound: String

func _init(nom_cat,color_cat,anim_drop_sound_cat):
	self.nom = nom_cat
	self.color = color_cat
	self.anim_drop_sound = anim_drop_sound_cat
