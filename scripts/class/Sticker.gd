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
	
