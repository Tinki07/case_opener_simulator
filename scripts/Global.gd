extends Node

@onready var armes = {} # Stocke toutes les armes
@onready var stickers = {} # Stocke tous les stickers
@onready var categories = {} # Stocke toutes les catégories de skins
@onready var categories_stickers = {} # Stocke toutes les catégories de stickers
@onready var skins = {} # Stocke tous les skins
@onready var etats_skins_normaux = {} # Stocke tous les états de skins
@onready var caisses_normales = {} # Stocke toutes les caisses normales
@onready var caisses_collections = {} # Stocke toutes les caisses de collections
@onready var conteneurs = {} # Stocke tous le conteneurs, peut importe le type
@onready var caisses_souvenirs = {} # Stocke toutes les caisses souvenirs
@onready var default_drop_rates = {} # Stocke les drops rates des catégories pour les caisses normales
@onready var types_stickers = {} # Stocke tous les types de stickers
@onready var keys_conteneurs = {} # Stocke toutes les clés pour les conteneurs en nécéssitant

@onready var leJoueur = Joueur.new() #créer le joueu

var pnl_prefab_skin_arme = preload("res://scenes/pnl_visualisation_skin.tscn") # référence le préfab pour les visualisations de skins
var prefab_container_buy_scene = preload("res://scenes/container_buy_scene.tscn")

func _ready():
	default_drop_rates = {
		"mil_spec": 71.0,
		"restricted": 20.25,
		"classified": 6.75,
		"covert": 1.55,
		"knive": 0.45
	}


func charger_armes_depuis_json():
	var fichier = "res://resources/jsons/armes.json"
	var file = FileAccess.open(fichier, FileAccess.READ)
	
	if armes == {}:
		if file:
			var json_as_text = FileAccess.get_file_as_string(fichier)
			var json_as_dict = JSON.parse_string(json_as_text)
			
			if json_as_dict:
				print("----------------------------------------------------")
				print("-- Chargement des armes --")
				var data = json_as_dict["armes"]
				for arme_data in data: 
					var arme = Arme.new(
						arme_data["nom"]
						)
					armes[arme_data["id"]] = arme
					print("Arme créée : %s" % arme.nom)
			else:
				print("Erreur de parsing JSON")
			file.close()
			print("-- armes chargées avec succés --")
			print("----------------------------------------------------")
			print(" ")
		else:
			print("Erreur lors de l'ouverture du fichier: %s" % fichier)
	else:
		print("----------------------------------------------------")
		print("Les armes sont déjà chargées")
		print("----------------------------------------------------")


func charger_skins_depuis_json(): 
	
	var fichier = "res://resources/jsons/skins.json"
	var file = FileAccess.open(fichier, FileAccess.READ)
	
	if file:
		var json_as_text = FileAccess.get_file_as_string(fichier)
		var json_as_dict = JSON.parse_string(json_as_text)
		
		if json_as_dict:
			print("----------------------------------------------------")
			print("-- Chargement des skins --")
			var data = json_as_dict["skins"]
			for categorie in data.keys():
				for sous_categorie in data[categorie].keys():
					var skins_dans_sous_categorie = data[categorie][sous_categorie]
					for skins_data in skins_dans_sous_categorie:
						var skin = SkinArme.new(
							skins_data["nom"],
							skins_data["id"],
							armes[skins_data["arme"]],
							categories[skins_data["categorie"]],
							skins_data["etats_possible"],
							skins_data["prix"],
							skins_data["image_path"]
						)
						if skins.has(skins_data["id"]):
							print("Duplication! Skin déjà présent avec l'ID :", skins_data["id"])
						skins[skins_data["id"]] = skin
						print("Skin créée : " , skin.toTstring(), " ", skin.etats_possible.size())
		else:
			print("Erreur de parsing JSON")
		file.close()
		print("-- skins chargés avec succés --")
		print("----------------------------------------------------")
		print(" ")
	else:
		print("Erreur lors de l'ouverture du fichier: %s" % fichier)

func charger_stickers_depuis_json(): 
	
	var fichier = "res://resources/jsons/stickers.json"
	var file = FileAccess.open(fichier, FileAccess.READ)
	
	if file:
		var json_as_text = FileAccess.get_file_as_string(fichier)
		var json_as_dict = JSON.parse_string(json_as_text)
		
		if json_as_dict:
			print("----------------------------------------------------")
			print("-- Chargement des skins --")
			var data = json_as_dict["stickers"]
			for categorie in data.keys():
				for sous_categorie in data[categorie].keys():
					var sticker_dans_sous_categorie = data[categorie][sous_categorie]
					for sticker_data in sticker_dans_sous_categorie:
						var sticker = Sticker.new(
							sticker_data["nom"],
							sticker_data["id"],
							sticker_data["equipe"],
							categories_stickers[sticker_data["categorie"]],
							types_stickers[sticker_data["type"]],
							sticker_data["image"],
							sticker_data["prix"]
						)
						stickers[sticker_data["id"]] = sticker
						print("Sticker créé : " , sticker_data["id"])
		else:
			print("Erreur de parsing JSON")
		file.close()
		print("-- skins chargés avec succés --")
		print("----------------------------------------------------")
		print(" ")
	else:
		print("Erreur lors de l'ouverture du fichier: %s" % fichier)


func charger_categories_skins_depuis_json():
	
	var fichier = "res://resources/jsons/categories.json"
	var file = FileAccess.open(fichier, FileAccess.READ)
	
	if file:
		var json_as_text = FileAccess.get_file_as_string(fichier)
		var json_as_dict = JSON.parse_string(json_as_text)
		
		if json_as_dict:
			print("----------------------------------------------------")
			print("-- Chargement des catégories --")
			var data = json_as_dict["categories"]["skins_normal"]
			for key in data.keys():
				var category_data = data[key]
				var category = CategorieSkin.new(
					category_data["nom"],
					category_data["color"],
					category_data["drop_anim_sound"]
				)
				categories[category_data["id"]] = category
				print("Catégorie créée : %s" % category.nom)
				
		else:
			print("Erreur de parsing JSON")
		file.close()
		print("-- catégories chargées avec succés --")
		print("----------------------------------------------------")
		print(" ")
	else:
		print("Erreur lors de l'ouverture du fichier: %s" % fichier)

func charger_categories_stickers_depuis_json():
	
	var fichier = "res://resources/jsons/categories.json"
	var file = FileAccess.open(fichier, FileAccess.READ)
	
	if file:
		var json_as_text = FileAccess.get_file_as_string(fichier)
		var json_as_dict = JSON.parse_string(json_as_text)
		
		if json_as_dict:
			print("----------------------------------------------------")
			print("-- Chargement des catégories stickers --")
			var data = json_as_dict["categories"]["stickers"]
			for key in data.keys():
				var category_data = data[key]
				var category = CategorieSticker.new(
					category_data["nom"],
					category_data["color"],
					category_data["drop_anim_sound"]
				)
				categories_stickers[category_data["id"]] = category
				print("Categorie sticker créée : %s" % category.nom)
				
		else:
			print("Erreur de parsing JSON")
		file.close()
		print("-- catégories stickers chargées avec succés --")
		print("----------------------------------------------------")
		print(" ")
	else:
		print("Erreur lors de l'ouverture du fichier: %s" % fichier)


func charger_caisses_normales_depuis_json(): 
	
	var fichier = "res://resources/jsons/conteneurs.json"
	var file = FileAccess.open(fichier, FileAccess.READ)
	
	if file:
		
		var json_as_text = FileAccess.get_file_as_string(fichier)
		var json_as_dict = JSON.parse_string(json_as_text)
		
		if json_as_dict:
			print("----------------------------------------------------")
			print("-- Chargement des caisses --")
			var data = json_as_dict["caisses"]
			for caisse in data.keys():
				var caisse_data = data[caisse]
				var newCaisse = Conteneur.new(
					caisse_data["nom"],
					caisse_data["id"],
					caisse_data["image"],
					caisse_data["image_collection"],
					caisse_data["type_caisse"],
					caisse_data["prix"],
					caisse_data["need_key"],
					caisse_data["skins"]
				)
				conteneurs[caisse_data["id"]] = newCaisse
				print("Caisse créée : ", newCaisse.nom)
		else:
			print("Erreur de parsing JSON")
		file.close()
		print("-- caisses chargées avec succés --")
		print("----------------------------------------------------")
		print(" ")
	else:
		print("Erreur lors de l'ouverture du fichier: %s" % fichier)

func charger_caisses_collections_depuis_json(): 
	
	var fichier = "res://resources/jsons/conteneurs.json"
	var file = FileAccess.open(fichier, FileAccess.READ)
	
	if file:
		
		var json_as_text = FileAccess.get_file_as_string(fichier)
		var json_as_dict = JSON.parse_string(json_as_text)
		
		if json_as_dict:
			print("----------------------------------------------------")
			print("-- Chargement des caisses --")
			var data = json_as_dict["collections"]
			for caisse in data.keys():
				var caisse_data = data[caisse]
				var newCaisse = Conteneur.new(
					caisse_data["nom"],
					caisse_data["id"],
					caisse_data["image"],
					caisse_data["image_collection"],
					caisse_data["type_caisse"],
					caisse_data["prix"],
					caisse_data["need_key"],
					caisse_data["skins"],
					caisse_data.get("drop_rates", {})
				)
				conteneurs[caisse_data["id"]] = newCaisse
				print("Caisse créée : ", newCaisse.nom)
		else:
			print("Erreur de parsing JSON")
		file.close()
		print("-- caisses chargées avec succés --")
		print("----------------------------------------------------")
		print(" ")
	else:
		print("Erreur lors de l'ouverture du fichier: %s" % fichier)

func charger_caisses_souvenirs_depuis_json(): 
	
	var fichier = "res://resources/jsons/conteneurs.json"
	var file = FileAccess.open(fichier, FileAccess.READ)
	
	if file:
		
		var json_as_text = FileAccess.get_file_as_string(fichier)
		var json_as_dict = JSON.parse_string(json_as_text)
		
		if json_as_dict:
			print("----------------------------------------------------")
			print("-- Chargement des caisses souvenirs--")
			var data = json_as_dict["souvenirs"]
			for caisse in data.keys():
				var caisse_data = data[caisse]
				var newCaisse = Conteneur.new(
					caisse_data["nom"],
					caisse_data["id"],
					caisse_data["image"],
					caisse_data["image_collection"],
					caisse_data["type_caisse"],
					caisse_data["prix"],
					caisse_data["need_key"],
					caisse_data["skins"],
					caisse_data.get("drop_rates", {})
				)
				newCaisse.souvenir_stickers = caisse_data["stickers"]
				conteneurs[caisse_data["id"]] = newCaisse
				print("Caisse souvenir créée : ", newCaisse.nom, newCaisse.type_caisse)
		else:
			print("Erreur de parsing JSON")
		file.close()
		print("-- caisses souvenirs chargées avec succés --")
		print("----------------------------------------------------")
		print(" ")
	else:
		print("Erreur lors de l'ouverture du fichier: %s" % fichier)
		

func charger_caisses_capsules_depuis_json(): 
	
	var fichier = "res://resources/jsons/conteneurs.json"
	var file = FileAccess.open(fichier, FileAccess.READ)
	
	if file:
		
		var json_as_text = FileAccess.get_file_as_string(fichier)
		var json_as_dict = JSON.parse_string(json_as_text)
		
		if json_as_dict:
			print("----------------------------------------------------")
			print("-- Chargement des caisses capsules--")
			var data = json_as_dict["capsules"]
			for caisse in data.keys():
				var caisse_data = data[caisse]
				var newCaisse = Conteneur.new(
					caisse_data["nom"],
					caisse_data["id"],
					caisse_data["image"],
					caisse_data["image_collection"],
					caisse_data["type_caisse"],
					caisse_data["prix"],
					caisse_data["need_key"],
					caisse_data["stickers"],
					caisse_data.get("drop_rates", {})
				)
				conteneurs[caisse_data["id"]] = newCaisse
				print("Caisse capsule créée : ", newCaisse.nom)
		else:
			print("Erreur de parsing JSON")
		file.close()
		print("-- caisses capsules chargées avec succés --")
		print("----------------------------------------------------")
		print(" ")
	else:
		print("Erreur lors de l'ouverture du fichier: %s" % fichier)

func charger_etats_skins_depuis_json(): 
	
	var fichier = "res://resources/jsons/etats_skins.json"
	var file = FileAccess.open(fichier, FileAccess.READ)
	
	if file:
		
		var json_as_text = FileAccess.get_file_as_string(fichier)
		var json_as_dict = JSON.parse_string(json_as_text)
		
		if json_as_dict:
			print("----------------------------------------------------")
			print("-- Chargement des états --")
			var data = json_as_dict["etats_skins"]["skins_normaux"]
			for etat_data in data:
				var newEtat = EtatSkin.new(
					etat_data["nom"],
					etat_data["id"],
				)
				etats_skins_normaux[etat_data["id"]] = newEtat
				print("Etat créée : %s" % newEtat.nom)
		else:
			print("Erreur de parsing JSON")
		file.close()
		print("-- etats chargés avec succés --")
		print("----------------------------------------------------")
		print(" ")
	else:
		print("Erreur lors de l'ouverture du fichier: %s" % fichier)

func charger_types_sticker_depuis_json():
	
	var fichier = "res://resources/jsons/stickers_types.json"
	var file = FileAccess.open(fichier, FileAccess.READ)
	
	if file:
		
		var json_as_text = FileAccess.get_file_as_string(fichier)
		var json_as_dict = JSON.parse_string(json_as_text)
		
		if json_as_dict:
			print("----------------------------------------------------")
			print("-- Chargement des types de stickers --")
			var data = json_as_dict["types_stickers"]
			for type_data in data:
				var newType = TypeSticker.new(
					type_data['nom'],
					type_data['id'],
					type_data['appellation']
				)
				types_stickers[type_data['id']] = newType
				print("Type créée : %s" % newType.nom)
		else:
			print("Erreur de parsing JSON")
		file.close()
		print("-- etats chargés avec succés --")
		print("----------------------------------------------------")
		print(" ")
	else:
		print("Erreur lors de l'ouverture du fichier: %s" % fichier)


func charger_keys_conteneurs_depuis_json():
	
	var fichier = "res://resources/jsons/KeyConteneur.json"
	var file = FileAccess.open(fichier, FileAccess.READ)
	
	if file:
		
		var json_as_text = FileAccess.get_file_as_string(fichier)
		var json_as_dict = JSON.parse_string(json_as_text)
		
		if json_as_dict:
			print("----------------------------------------------------")
			print("-- Chargement des keys des conteneurs --")
			var data = json_as_dict["keys"]
			for key_data in data:
				var newKey = KeyConteneur.new(
					key_data['nom'],
					key_data['id'],
					key_data['image_path'],
					conteneurs[key_data['conteneur_unlocker']] ,
					key_data['prix']
				)
				keys_conteneurs[key_data['id']] = newKey
				print("Key créée : %s" % newKey.nom)
		else:
			print("Erreur de parsing JSON")
		file.close()
		print("-- Keys chargées avec succés --")
		print("----------------------------------------------------")
		print(" ")
	else:
		print("Erreur lors de l'ouverture du fichier: %s" % fichier)
