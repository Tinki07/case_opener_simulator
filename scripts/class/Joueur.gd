extends Node

class_name Joueur

var pseudo: String
var inventaire: Array
var money: float

func ajouter_skin_ouvert_a_inventaire(skin: SkinArmeObtenu):
	inventaire.append(skin)

func get_value_inventory():
	var value: float = 0
	
	for objet in inventaire:
		
		if objet is SkinArmeObtenu:
			value += objet.prix
	
	return value
