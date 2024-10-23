extends Node

class_name Conteneur

var nom: String
var id: String
var image_path: String
var image_collection_path: String
var objets_dropable: Array
var drop_rates: Dictionary
var type_caisse: String
var souvenir_stickers: Array
var prix: float
var need_key: bool
var sell_selected: bool

func _init(nom,id_conteneur, image_path, image_collection_path, type_caisse,prix_conteneur,need_key_caisse, objets_dropable=[],drop_rates={}):
	self.nom = nom
	self.id = id_conteneur
	self.image_path = image_path
	self.objets_dropable = objets_dropable
	self.prix = prix_conteneur
	self.drop_rates = drop_rates
	self.type_caisse = type_caisse
	self.need_key = need_key_caisse
	self.image_collection_path = image_collection_path

func set_sell_selected(state:bool):
	self.sell_selected = state
