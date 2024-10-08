extends Node

class_name Sticker

var nom: String
var id: String
var equipe: String
var categorie: CategorieSticker
var type: TypeSticker
var prix: float
var image_path: String

func _init(nom,id,equipe,categorie,type,image_path,prix):
	self.nom = nom
	self.id = id
	self.equipe = equipe
	self.categorie = categorie
	self.type = type
	self.image_path = image_path
	self.prix = prix
	

func get_quality():
	return self.categorie.nom

func get_color():
	return self.categorie.color

func get_image():
	return self.image_path

func get_price():
	return self.prix

func _to_string():
	return "Sticker | " + self.nom
