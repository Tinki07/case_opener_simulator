extends Node

class_name KeyConteneur

var nom: String
var image_path: String
var conteneur_unlocker : Conteneur
var prix: float

func _init(nom_key,image_path_key,conteneur_unlocker_key,prix_key):
	self.nom = nom_key
	self.image_path = image_path_key
	self.conteneur_unlocker = conteneur_unlocker_key
	self.prix = prix_key
	
	
