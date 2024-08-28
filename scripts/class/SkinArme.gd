extends Node

class_name SkinArme

var nom: String
var arme: Arme
var categorie: CategorieSkin
var etats_possible: Array
var prix: Array
var image_path: String

func _init(nom, arme, categorie, etats_possible, prix, image_path):
	self.nom = nom
	self.arme = arme
	self.categorie = categorie
	self.etats_possible = etats_possible
	self.prix = prix
	self.image_path = image_path

func toTstring():
	var string
	string =  arme.nom + " | " + nom
	return string
