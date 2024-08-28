extends Node2D


@onready var line_edit_console = $/root/Node2D/LineEdit # référence la console

@onready var leJoueur = Joueur.new() #créer le joueu

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

@onready var index_skin_a_charger_debut = 0  # Index du premier skin à afficher dans la grille inventaire
@onready var skins_par_page = 24  # Nombre de skins par page à afficher
@onready var page_actuelle = 1

var pnl_prefab_skin_arme = preload("res://scenes/pnl_visualisation_skin.tscn") # référence le préfab pour les visualisations de skins

func _process(delta):
	$pnl_principal/pnl_infos_joueur/pnl_infos_1/pnl_money_joueur/hcont/lbl_argent_joueur.text = str(leJoueur.money)

func _ready():
	Engine.max_fps = 60
	line_edit_console.grab_focus() # Permet de faire le focus sur la zone de text
	
	line_edit_console.text_submitted.connect(self._on_line_edit_text_submitted) # Connecte le signal text_submitted du LineEdit à la méthode _on_line_edit_text_submitted
	
	# Définis les taux de drops des caisses normales
	default_drop_rates = {
		"mil_spec": 71.40,
		"restricted": 21.20,
		"classified": 6.00,
		"covert": 1.1,
		"knive": 0.30
	}
	
	# Charge les différents objets
	charger_armes_depuis_json()
	charger_categories_skins_depuis_json()
	charger_skins_depuis_json()
	charger_caisses_normales_depuis_json()
	charger_caisses_collections_depuis_json()
	charger_etats_skins_depuis_json()
	charger_types_sticker_depuis_json()
	charger_categories_stickers_depuis_json()
	charger_stickers_depuis_json()
	charger_caisses_souvenirs_depuis_json()
	charger_keys_conteneurs_depuis_json()
	
	leJoueur.money = 1000.00



# Méthode appelée lorsque le signal text_submitted est émis
func _on_line_edit_text_submitted(new_text: String):
	
	# Vérifie si la méthode existe
	if has_method(new_text):
		# Appelle la méthode entrée dans le LineEdit
		call(new_text)
		#line_edit.clear()
	else:
		print("La fonction '%s' n'existe pas." % new_text)





# -----------------------------------------------------------------------





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
							armes[skins_data["arme"]],
							categories[skins_data["categorie"]],
							skins_data["etats_possible"],
							skins_data["prix"],
							skins_data["image_path"]
						)
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
					category_data["color"]
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
					category_data["color"]
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



# -----------------------------------------------------------------------




# Ancienne facon de drop les skins
func ouvrir_caisse_normale(caisse: Conteneur):
	
	# Parcours toutes les caisses
	for uneCaisse in conteneurs.values():
		
		# Si la caisse en paramètre correspond a "uneCaisse", c'est bon
		if caisse == uneCaisse:
			
			# Variable permettant de choisir une catégorie aléatoirement (entre 0 et 100)
			var randomNum = randf() * 100
			# 
			var etat
			var stattrack: bool
			var skins_cat_choisi = []
			var etat_final
			var skin_choisi_string: String
			var skin_choisi: SkinArme
			
			# Permet de trouver la catégorie du skin
			if randomNum >= categories["covert"].drop_rate: # knife
				
				etat_final = "knive"
				
				#skins_cat_choisi = get_skins_by_categories(caisse,"knive")
				#etats = trouver_wear_skin()
				#stattrack = is_the_skin_stattrack()
				#print(categories["knive"].nom, " ", etats, " - ", stattrack)
				
			elif randomNum >= categories["classified"].drop_rate: # rouge
				
				etat_final = "covert"
				
				#etats = trouver_wear_skin()
				#stattrack = is_the_skin_stattrack()
				#print(categories["covert"].nom, " ", etats, " - ", stattrack)
				
			elif randomNum >= categories["restricted"].drop_rate: # rose
				
				etat_final = "classified"
				
				#etats = trouver_wear_skin()
				#stattrack = is_the_skin_stattrack()
				#print(categories["classified"].nom, " ", etats, " - ", stattrack)
				
			elif randomNum >= categories["mil_spec"].drop_rate: # violet
				
				etat_final = "restricted"
				
				#etats = trouver_wear_skin()
				#stattrack = is_the_skin_stattrack()
				#print(categories["restricted"].nom, " ", etats, " - ", stattrack)
				
			else: # bleu
				
				etat_final = "mil_spec"
				
				#etats = trouver_wear_skin()
				#stattrack = is_the_skin_stattrack()
				#print(categories["mil_spec"].nom, " ", etats, " - ", stattrack)
			
			# met dans une liste tout les skins de la catégorie qui a été choisie
			skins_cat_choisi = get_skins_by_categories(caisse,etat_final)
			
			# Choisi un skin aléatoire parmis la liste des skins en string
			skin_choisi_string = skins_cat_choisi[randi_range(0,skins_cat_choisi.size() - 1)]
			
			# Grace au string de l'arme choisi, je parcours la liste de tout les objets skins et pour le string
			# correspondant, skin_choisi devient l'objet skin
			skin_choisi = skins[skin_choisi_string]
			
			# Trouve l'état de l'arme et son float
			etat = trouver_wear_skin(skin_choisi)
			
			# Trouve si le skin est StatTrack ou pas
			stattrack = is_the_skin_stattrack()
			
			
			
			var leSkinObtenu = SkinArmeObtenu.new(skin_choisi,etat,stattrack,0)
			
			leSkinObtenu.prix = trouver_prix_skin_etat(leSkinObtenu)
			
			print(leSkinObtenu._to_string())


# Peermet d'ouvrir des caisses
func ouvrir_caisse_v2(caisse: Conteneur, type_caisse: String):
	
	var randomNum = randf() * 100 # Permet de donner une valeur float entre 0 et 100 en rapport avec le taux de drop
	var cumulative_drop_rate = 0.0 #permet de cumuler les taux de drops afin de voir quand, randomNum est > 
	var qualite_finale = "" # Permet de stocker la qualité du skin qui est choisi
	var drop_rates # Déterminer les taux de drop à utiliser en fonction du type de caisse
	var skins_cat_choisi = [] # Stocke les skins de la catégorie choisi
	var skin_choisi_string: String # Nom du skin en valeur string qui est choisi
	var skin_choisi: SkinArme # Skin choisi
	var etat
	var stattrack: bool
	var souvenir: bool = 0
	
	# Regarde si le type de la caisse est normal ou pas, choisi les taux de drops
	if caisse.type_caisse == "normal":
		drop_rates = default_drop_rates
	else:
		drop_rates = caisse.drop_rates
	
	# Utilisation des taux de drop pour déterminer la catégorie
	for category in drop_rates.keys():
		cumulative_drop_rate += drop_rates[category]
		if randomNum <= cumulative_drop_rate:
			qualite_finale = category
			break
	
	# Choisir la première catégorie si aucune n'est sélectionnée
	if qualite_finale == "":
		qualite_finale = drop_rates.keys()[0]
	
	# Stocke les skins de la qualitée choisie dans une liste
	skins_cat_choisi = get_skins_by_categories(caisse,qualite_finale)
	
	# Choisi un skin aléatoire parmis la liste des skins en string
	skin_choisi_string = skins_cat_choisi[randi_range(0,skins_cat_choisi.size() - 1)]
	
	# Grace au string de l'arme choisi, je parcours la liste de tout les objets skins et pour le string
	# correspondant, skin_choisi devient l'objet skin
	skin_choisi = skins[skin_choisi_string]
	
	# Trouve l'état de l'arme et son float
	etat = trouver_wear_skin(skin_choisi)
	
	# Permet de savoir si un skin doit etre noté souvenir ou stattrack ou rien
	if type_caisse == "collection":
		# Si le skin provient d'une collection, il ne peut être ni souvenir ni stattrack.
		stattrack = 0
		souvenir = 0
	elif type_caisse == "souvenir":
		# Si le skin provient d'une caisse à souvenirs, il est forcément un souvenir.
		stattrack = 0
		souvenir = 1
	else:
		# Pour tous les autres types de caisse, on détermine si le skin est un stattrack
		# en appelant la fonction is_the_skin_stattrack().
		stattrack = is_the_skin_stattrack()
	
	# Créer l'objet SkinArmeObtenu avec toutes les infos nécéssaire
	var leSkinObtenu = SkinArmeObtenu.new(skin_choisi,etat,stattrack,souvenir)
	
	# Trouve le prix du skin
	leSkinObtenu.prix = trouver_prix_skin_etat(leSkinObtenu)
	
	# Vérifie si le skin obtenu est un souvenir
	if leSkinObtenu.souvenir:
		# Si c'est un souvenir, ajoute des stickers au package associé
		_add_stickers_to_souvenir_package(caisse,leSkinObtenu)
		
		print(leSkinObtenu._to_string())
		leSkinObtenu._stickers_to_string()
	else:
		print(leSkinObtenu._to_string(), "         ", randomNum, "         ", cumulative_drop_rate, "         ", qualite_finale, "           ", skin_choisi_string)
	
	# Ajoute le skin à l'inventaire du joueur
	#leJoueur.inventaire.insert(0,leSkinObtenu)
	
	#repopulation_grille_inventaire_sans_retoruner_page_1()
	return leSkinObtenu

# Trouve l'état de l'arme
func trouver_wear_skin(leSkin: SkinArme):
	
	# Sélectionne aléatoirement un état parmi les états possibles du skin
	var random_index = randi_range(0, (leSkin.etats_possible.size() - 1))
	var etat_nom = leSkin.etats_possible[random_index]
	
	# Récupère les informations détaillées sur l'état sélectionné
	var etat = etats_skins_normaux[etat_nom]
	
	# Retourne l'état sélectionné
	return etat

# Détermine si un skin est un stattrack de manière aléatoire
func is_the_skin_stattrack():
	
	# Génère un nombre aléatoire entre 0 et 99
	var randomNum = randi_range(0,100)
	
	# Si le nombre aléatoire est inférieur ou égal à 20, le skin est un stattrack
	if randomNum <= 15:
		return true
	else:
		return false

# Permet de donner une liste de tout les skins pour une qualitée donnée pour une certaine caisse
# Permet aussi de de choisir une variante. 10% de chances pour le moment
func get_skins_by_categories(caisse: Conteneur,etat):
	var skins = [] # Liste des skins
	
	# Parcours tout les skins de la caisse donnée
	for skin in caisse.objets_dropable:
		# Regarde l'état du skin, si il est pareil que celui renseigné alors ca passe
		if skin[1] == etat:
			# Ici on regarde si le skin a une ou des variantes
			if skin[2][0] != "":
				var random = randf() * 100 # Retourne une valeur entre 0 et 100
				var chance_variante = 95.00 # Chance pour le choix de la variante
				var nb_variantes = skin[2].size() # Retourne le nombre de variantes
				
				# Vois si la variante est choisie ou non
				if random > chance_variante:
					# Dans ce cas, on choisi une variante dans la liste
					skins.append(skin[2][randi_range(0,nb_variantes -1)])
				else:
					# Ne choisi pas de variante
					skins.append(skin[0])
			else:
				# Ne choisi pas de variante
				skins.append(skin[0])
	
	return skins # On retourne les skins dans une liste

func trouver_prix_skin_etat(leSkin: SkinArmeObtenu):
	var prix: float
	var index
	
	if leSkin.etat == etats_skins_normaux["fn"]:
		index = 0
	elif leSkin.etat == etats_skins_normaux["mw"]:
		index = 1
	elif leSkin.etat == etats_skins_normaux["ft"]:
		index = 2
	elif leSkin.etat == etats_skins_normaux["ww"]:
		index = 3
	elif leSkin.etat == etats_skins_normaux["bs"]:
		index = 4
	
	# Si StatTrack, on ajoute 5 à l'index
	if leSkin.stat_track or leSkin.souvenir:
		index += 5
	
	prix = leSkin.skin.prix[index]
	
	return prix

func _add_stickers_to_souvenir_package(caisse: Conteneur,skin: SkinArmeObtenu):
	var stickers_teams: Array = []
	var stickers_signatures: Array = []
	var sticker_orga: String = ""
	var sticker_map: String = ""
	var sticker_team1: String
	var sticker_team2: String
	var lesStickersDeLaTeam1 = []
	var sticker_signature_choisi = ""
	var les_stickers_selectiones: Array
	
	for sticker in caisse.souvenir_stickers:
		var sticker_name = sticker[0]  # Nom du sticker
		var sticker_type = sticker[1]  # Type du sticker
		var equipe = sticker[2]
		
		if sticker_type == "team":
			stickers_teams.append([sticker_name,equipe])
		elif sticker_type == "organisateur":
			sticker_orga = sticker_name
		elif sticker_type == "map":
			sticker_map = sticker_name
		elif sticker_type == "signature":
			stickers_signatures.append([sticker_name,equipe])
	
	var random1 = randi_range(0,stickers_teams.size() - 1)
	var random2 = randi_range(0,stickers_teams.size() - 1)
	
	while random2 == random1:
		random2 = randi_range(0, stickers_teams.size() - 1)
	
	sticker_team1 = stickers_teams[random1][0]
	sticker_team2 = stickers_teams[random2][0]
	
	les_stickers_selectiones.append_array([sticker_team1,sticker_team2,sticker_orga])
	
	if stickers_signatures != [] and sticker_map == "": 
		for sticker in stickers_signatures:
			var sticker_name = sticker[0]  # Nom du sticker
			var equipe = sticker[2]
			if equipe == stickers_teams[random1][1]:
				lesStickersDeLaTeam1.append(sticker_name)
		var random = randi_range(0,lesStickersDeLaTeam1.size() - 1)
		sticker_signature_choisi = lesStickersDeLaTeam1[random]
		les_stickers_selectiones.append(sticker_signature_choisi)
	elif stickers_signatures == [] and sticker_map != "":
		les_stickers_selectiones.append(sticker_map)
	
	#print(les_stickers_selectiones)
	skin._add_array_sticker(les_stickers_selectiones,stickers)
	
	


# -----------------------------------------------------------------------

func kil_caisse():
	leJoueur.inventaire.insert(0,conteneurs["caisse_kilowatt"])
	repopulation_grille_inventaire_sans_retoruner_page_1()

func dream_caisse():
	leJoueur.inventaire.insert(0,conteneurs["caisse_dreams_&_nightmares"])
	repopulation_grille_inventaire_sans_retoruner_page_1()

func mir_caisse():
	leJoueur.inventaire.insert(0,conteneurs["collection_mirage_2021"])
	repopulation_grille_inventaire_sans_retoruner_page_1()

func kilo():
	ouvrir_caisse_v2(conteneurs["caisse_kilowatt"], conteneurs["caisse_kilowatt"].type_caisse)
	ouvrir_caisse_v2(conteneurs["caisse_kilowatt"], conteneurs["caisse_kilowatt"].type_caisse)
	ouvrir_caisse_v2(conteneurs["caisse_kilowatt"], conteneurs["caisse_kilowatt"].type_caisse)
	ouvrir_caisse_v2(conteneurs["caisse_kilowatt"], conteneurs["caisse_kilowatt"].type_caisse)
	ouvrir_caisse_v2(conteneurs["caisse_kilowatt"], conteneurs["caisse_kilowatt"].type_caisse)
	ouvrir_caisse_v2(conteneurs["caisse_kilowatt"], conteneurs["caisse_kilowatt"].type_caisse)
	ouvrir_caisse_v2(conteneurs["caisse_kilowatt"], conteneurs["caisse_kilowatt"].type_caisse)
	ouvrir_caisse_v2(conteneurs["caisse_kilowatt"], conteneurs["caisse_kilowatt"].type_caisse)
	ouvrir_caisse_v2(conteneurs["caisse_kilowatt"], conteneurs["caisse_kilowatt"].type_caisse)
	ouvrir_caisse_v2(conteneurs["caisse_kilowatt"], conteneurs["caisse_kilowatt"].type_caisse)
	ouvrir_caisse_v2(conteneurs["caisse_kilowatt"], conteneurs["caisse_kilowatt"].type_caisse)
	ouvrir_caisse_v2(conteneurs["caisse_kilowatt"], conteneurs["caisse_kilowatt"].type_caisse)
	repopulation_grille_inventaire_sans_retoruner_page_1()

func dream():
	ouvrir_caisse_v2(conteneurs["caisse_dreams_&_nightmares"], conteneurs["caisse_dreams_&_nightmares"].type_caisse)
	repopulation_grille_inventaire_sans_retoruner_page_1()

func colec():
	ouvrir_caisse_v2(conteneurs["collection_mirage_2021"], conteneurs["collection_mirage_2021"].type_caisse)
	repopulation_grille_inventaire_sans_retoruner_page_1()

func key():
	leJoueur.inventaire.insert(0,keys_conteneurs["caisse_kilowatt_key"])
	repopulation_grille_inventaire_sans_retoruner_page_1()

func souv():
	ouvrir_caisse_v2(conteneurs["souvenir_blast_paris_2023_mirage_2021"], conteneurs["souvenir_blast_paris_2023_mirage_2021"].type_caisse)
	repopulation_grille_inventaire_sans_retoruner_page_1()

func colec_caisse():
	leJoueur.inventaire.insert(0,conteneurs["souvenir_blast_paris_2023_mirage_2021"])
	repopulation_grille_inventaire_sans_retoruner_page_1()

func test():
	print("")
# -----------------------------------------------------------------------




# Fonction pour effacer tous les enfants d'une grille - est utilisé pour afficher les items mis a jour
func clear_grid(grid):
	for child in grid.get_children(): # On itère sur tous les enfants du nœud `grid`
		grid.remove_child(child) # On supprime l'enfant de la grille
		child.queue_free() # On marque l'enfant pour destruction lors du prochain cycle


# permet de peupler la grille des skins avec les éléments de l'inventaire du joueur
func populate_grid_skin(grid : GridContainer,index_skin_a_charger_debut: int):
	
	# On vide la grille pour éviter les doublons
	clear_grid(grid) 
	
	#s'occupe de charger toutes les infos nécessaire pour la création des skins
	var skin_index_debut = index_skin_a_charger_debut
	var skin_index_fin = skin_index_debut + 23
	var skins_loaded = 0  # Compteur pour les skins chargés
	
	# On parcourt l'inventaire du joueur et on crée un élément pour chaque skin
	for i in range(skin_index_debut, min(skin_index_fin + 1, leJoueur.inventaire.size())):

		# Met en variable l'objet qui sera attribué au pannel
		var objet = leJoueur.inventaire[i]
		
		# Récupère les infos du nouveau panel
		var new_panel_objet = pnl_prefab_skin_arme.instantiate() # On crée un bouton
		var lalbel_principal_objet = new_panel_objet.get_node("pnl_infos_skin/lbl_nom_arme") # On récupère son label
		var label_secondaire_objet = new_panel_objet.get_node("pnl_infos_skin/lbl_nom_skin") # On récupère son label
		var image_objet = new_panel_objet.get_node("pnl_skin/txtr_skin") # On récupère son image
		var color_categorie_objet = new_panel_objet.get_node("pnl_infos_skin/color_rect_etat_skin")
		var btn_panel_objet = new_panel_objet.get_node("btn_skin")
		
		# Dans le cas où l'objet est un skin :
		if objet is SkinArmeObtenu:
			
			# Modifie les infos du panel de l'objet
			lalbel_principal_objet.text = objet._to_string_arme() # On modifie le label
			label_secondaire_objet.text = objet.skin.nom # On modifie le label
			color_categorie_objet.color = objet.skin.categorie.color # On modifie la couleur
			image_objet.texture = load(objet.skin.image_path) # On modifie l'image
			
			# Gère les stickers si présents pour l'objet/skin
			for j in range(objet.stickers5.size()):
				var sticker_node = new_panel_objet.get_node("pnl_skin/txtr_sticker%d" % (j + 1))
				sticker_node.texture = load(objet.stickers5[j].image_path)
			
			
		# Dans le cas où l'objet est une caisse
		elif objet is Conteneur:
			
			# Modifie les infos du panel de l'objet
			lalbel_principal_objet.text = objet.nom # On modifie le label
			label_secondaire_objet.text = "" # On modifie le label
			lalbel_principal_objet.autowrap_mode  = TextServer.AUTOWRAP_WORD # Permet au label de pouvoir prendre 2 lignes au lieu de 1
			image_objet.texture = load(objet.image_path) # On modifie l'image
			
		elif objet is KeyConteneur:
			# Modifie les infos du panel de l'objet
			lalbel_principal_objet.text = objet.nom # On modifie le label
			label_secondaire_objet.text = "" # On modifie le label
			lalbel_principal_objet.autowrap_mode  = TextServer.AUTOWRAP_WORD # Permet au label de pouvoir prendre 2 lignes au lieu de 1
			image_objet.texture = load(objet.image_path) # On modifie l'image
		
		
		# Associer l'objet "skin - SkinArmeObtenu" au bouton du panel
		new_panel_objet.set_meta("skin_data", objet)
		
 		# Connecter le signal "pressed" du bouton à une fonction de gestion
		btn_panel_objet.pressed.connect(self._on_objet_inventory_button_pressed.bind(new_panel_objet))
		
		# Ajoute le panneau configuré à la grille
		grid.add_child(new_panel_objet) # On ajoute le panneau à la grille
		
	# On met à jour la visibilité des boutons de navigation (Suivant/Précédent)
	# Activer/Désactiver le bouton suivant
	if skin_index_fin < leJoueur.inventaire.size() - 1:
		$pnl_principal/pnl_inventaire/pnl_inventaire_storage/btn_page_storage_suivant.visible = true
	else:
		$pnl_principal/pnl_inventaire/pnl_inventaire_storage/btn_page_storage_suivant.visible = false
		
	# Activer/Désactiver le bouton précédent
	if index_skin_a_charger_debut > 0:
		$pnl_principal/pnl_inventaire/pnl_inventaire_storage/btn_page_storage_precedent.visible = true
	else:
		$pnl_principal/pnl_inventaire/pnl_inventaire_storage/btn_page_storage_precedent.visible = false
	calculer_nombre_page()

# Affiche la page suivante de skins dans l'inventaire
func afficher_skins_suivant():
	# Vérifie s'il y a encore des skins à afficher
	if index_skin_a_charger_debut + skins_par_page < leJoueur.inventaire.size():
		
		# Met à jour l'index de départ pour la prochaine page
		index_skin_a_charger_debut += skins_par_page
		
		page_actuelle += 1
		changer_valeur_page_actuelle_storage()
		
		# Remplit la grille avec les skins de la nouvelle page
		populate_grid_skin($pnl_principal/pnl_inventaire/pnl_inventaire_storage/MarginContainer/GridContainer, index_skin_a_charger_debut)


# Affiche la page précédente de skins dans l'inventaire
func afficher_skins_precedent():
	# Vérifie si on peut revenir à la page précédente
	if index_skin_a_charger_debut - skins_par_page >= 0:
		
		# Met à jour l'index de départ pour la page précédente
		index_skin_a_charger_debut -= skins_par_page
		
		page_actuelle -= 1
		changer_valeur_page_actuelle_storage()
		
		# Remplit la grille avec les skins de la nouvelle page
		populate_grid_skin($pnl_principal/pnl_inventaire/pnl_inventaire_storage/MarginContainer/GridContainer, index_skin_a_charger_debut)

func calculer_nombre_page():
	var nbr_pages = leJoueur.inventaire.size() / skins_par_page
	$pnl_principal/pnl_inventaire/pnl_inventaire_storage/pnl_prix_inventaire2/lbl_nbr_page.text = "/" + str( ceil((leJoueur.inventaire.size() - 1)/ skins_par_page) + 1)


# Elle gère l'affichage et la mise à jour de l'inventaire du joueur.
func _on_btn_inventaire_pressed():
	# Affiche ou cache le panneau de l'inventaire
	page_actuelle = 1
	changer_valeur_page_actuelle_storage()
	$pnl_principal/pnl_inventaire.visible = true
	# Remplit la grille de l'inventaire avec les skins du joueur
	populate_grid_skin($pnl_principal/pnl_inventaire/pnl_inventaire_storage/MarginContainer/GridContainer, 0)
	
	# Initialise l'index du premier skin à charger
	index_skin_a_charger_debut = 0
	
	# Met à jour le nombre d'items dans l'inventaire
	$pnl_principal/pnl_inventaire/pnl_inventaire_storage/lbl_items_inventaire_joueur/lbl_nombre_items.text = str(leJoueur.inventaire.size())
	
	# Met à jour la valeur totale de l'inventaire
	$pnl_principal/pnl_inventaire/pnl_inventaire_storage/pnl_prix_inventaire/lbl_prix.text = str(snapped(leJoueur.get_value_inventory(),0.01))

# Permet l'affichage des skins suivants dans l'inventaire.
func _on_btn_page_storage_suivant_pressed():
	afficher_skins_suivant()

# Permet l'affichage des skins précédents dans l'inventaire.
func _on_btn_page_storage_precedent_pressed():
	afficher_skins_precedent()


func _on_objet_inventory_button_pressed(button):
	
	# Récupérer les informations supplémentaires sur l'objet à partir du metadata
	var objet = button.get_meta("skin_data")
	
	# On vérifie quel est le type de l'objet associé au panneau
	if objet is SkinArmeObtenu:
		$pnl_objet_cliked/VBoxContainer/btn_inspect.visible = true
		$pnl_objet_cliked/VBoxContainer/btn_delete_objet.visible = true
		$pnl_objet_cliked/VBoxContainer/btn_ouvrir.visible = false
	elif objet is Conteneur:
		$pnl_objet_cliked/VBoxContainer/btn_inspect.visible = false
		$pnl_objet_cliked/VBoxContainer/btn_delete_objet.visible = true
		$pnl_objet_cliked/VBoxContainer/btn_ouvrir.visible = true
	else:
		$pnl_objet_cliked/VBoxContainer/btn_inspect.visible = false
		$pnl_objet_cliked/VBoxContainer/btn_delete_objet.visible = true
		$pnl_objet_cliked/VBoxContainer/btn_ouvrir.visible = false
	
	$pnl_objet_cliked.visible = !$pnl_objet_cliked.visible
	$pnl_objet_cliked.position = get_global_mouse_position()
	
	var panel =  $pnl_objet_cliked
	var btn_inspect = panel.get_node("VBoxContainer/btn_inspect")
	var btn_supprimer = panel.get_node("VBoxContainer/btn_delete_objet")
	var btn_ouvrir = panel.get_node("VBoxContainer/btn_ouvrir")
	
	# Gestion du bouton inspect de l'objet
	if btn_inspect.pressed.is_connected(self._on_inspect_objet_button_pressed):
		btn_inspect.pressed.disconnect(self._on_inspect_objet_button_pressed)
	# Connecter le signal "pressed" du bouton inspect à une fonction de gestion
	btn_inspect.pressed.connect(self._on_inspect_objet_button_pressed.bind(objet))
	
	# Gestion du bouton delete de l'objet
	if btn_supprimer.pressed.is_connected(self._on_delete_objet_button_pressed):
		btn_supprimer.pressed.disconnect(self._on_delete_objet_button_pressed)
	btn_supprimer.pressed.connect(self._on_delete_objet_button_pressed.bind(objet))
	
	if btn_ouvrir.pressed.is_connected(self._on_ouvrir_objet_button_pressed):
		btn_ouvrir.pressed.disconnect(self._on_ouvrir_objet_button_pressed)
	btn_ouvrir.pressed.connect(self._on_ouvrir_objet_button_pressed.bind(objet))

func _on_delete_objet_button_pressed(objet):
	
	leJoueur.money += objet.prix
	leJoueur.inventaire.erase(objet)
	$pnl_objet_cliked.visible = false
	
	repopulation_grille_inventaire_sans_retoruner_page_1()

func _on_inspect_objet_button_pressed(objet):
	if objet is SkinArmeObtenu:
		print(objet.skin.nom)
	else:
		print(objet.nom)

func _on_ouvrir_objet_button_pressed(objet):
	$pnl_objet_cliked.visible = false
	$pnl_principal/pnl_inventaire/pnl_titre/btn_quitter_caisse_panel.visible = true
	if objet is Conteneur:
		$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/hbox_nom_caisse/lbl_nom_caisse.text = objet.nom
		var grille_items_conteneur = get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_items_in_caisse/scroll/margin/grid_items")
		clear_grid(grille_items_conteneur)
		
		$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/btn_ouverture_conteneur.set_meta("container_data", objet)
		
		var special_item_found = false  # Drapeau pour indiquer si un couteau a été trouvé
		for item_caisse in objet.objets_dropable:
			
			
			var item = item_caisse[0]
			
			# Met les infos de l'objet en rapport avec le type - ici dans le cas ou c'est un SkinArme
			if skins[item] != null:
				
				if skins[item].categorie == categories["knive"] :
					special_item_found = true
				else:
					var new_panel_objet = pnl_prefab_skin_arme.instantiate() # On crée un bouton
					new_panel_objet.get_node("pnl_infos_skin/lbl_nom_arme").text = skins[item].arme.nom
					new_panel_objet.get_node("pnl_infos_skin/lbl_nom_skin").text = skins[item].nom
					new_panel_objet.get_node("pnl_skin/txtr_skin").texture = load(skins[item].image_path)
					new_panel_objet.get_node("pnl_infos_skin/color_rect_etat_skin").color = skins[item].categorie.color
					grille_items_conteneur.add_child(new_panel_objet) # On ajoute le panneau à la grille
				
		if special_item_found:
			var special_panel = pnl_prefab_skin_arme.instantiate() # On crée un bouton
			special_panel.get_node("pnl_infos_skin/lbl_nom_arme").text = categories['knive'].nom
			special_panel.get_node("pnl_infos_skin/lbl_nom_arme").autowrap_mode = TextServer.AUTOWRAP_WORD
			special_panel.get_node("pnl_infos_skin/lbl_nom_skin").text = ""
			special_panel.get_node("pnl_skin/txtr_skin").texture = load("res://resources/images/Csgo-default_rare_item.png")
			special_panel.get_node("pnl_infos_skin/color_rect_etat_skin").color = "ffd700"
			grille_items_conteneur.add_child(special_panel) # On ajoute le panneau à la grille
		
		
		if objet.need_key == true:
			
			var key = keys_conteneurs[objet.id + "_key"]
			$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/btn_ouverture_conteneur.set_meta("key_data", key)
			var panel_key = get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_conteneur_with_key/pnl_infos_conteneurs/pnl_visualisation_key")# On crée un bouton
			var label_principal_key = panel_key.get_node("pnl_infos_skin/lbl_nom_arme") # On récupère son label
			var label_secondaire_key = panel_key.get_node("pnl_infos_skin/lbl_nom_skin") # On récupère son label
			var image_key = panel_key.get_node("pnl_skin/txtr_skin") # On récupère son image
			
			var panel_conteneur = get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_conteneur_with_key/pnl_infos_conteneurs/pnl_visualisation_conteneur")
			var label_principal_conteneur = panel_conteneur.get_node("pnl_infos_skin/lbl_nom_arme") # On récupère son label
			var label_secondaire_conteneur = panel_conteneur.get_node("pnl_infos_skin/lbl_nom_skin") # On récupère son label
			var image_conteneur = panel_conteneur.get_node("pnl_skin/txtr_skin") # On récupère son image
			var color_categorie_conteneur = panel_conteneur.get_node("pnl_infos_skin/color_rect_etat_skin")
			
			label_principal_conteneur.text = objet.nom # On modifie le label
			label_secondaire_conteneur.text = "" # On modifie le label
			label_principal_conteneur.autowrap_mode  = TextServer.AUTOWRAP_WORD # Permet au label de pouvoir prendre 2 lignes au lieu de 1
			image_conteneur.texture = load(objet.image_path) # On modifie l'image
			
			label_principal_key.text = key.nom # On modifie le label
			label_secondaire_key.text = "" # On modifie le label
			label_principal_key.autowrap_mode  = TextServer.AUTOWRAP_WORD # Permet au label de pouvoir prendre 2 lignes au lieu de 1
			image_key.texture = load(key.image_path) # On modifie l'image
			
			var item_found = false  # Variable pour suivre si l'item KEY est trouvé ou non
			for item in leJoueur.inventaire:
				if item == key:
					item_found = true
					break
			
			# Si aucun item correspondant n'est trouvé
			if not item_found:
				$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/btn_ouverture_conteneur.visible = false
				$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/lbl_info_key.text = "you need a " + key.nom + " to open this container"
			else:
				$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/lbl_info_key.text = "Key can be only use once"
				$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/btn_ouverture_conteneur.text = "Use Key"
				$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/btn_ouverture_conteneur.visible = true
			
			
			$pnl_principal/pnl_inventaire/pnl_inventaire_storage.visible = false
			$pnl_principal/pnl_inventaire/pnl_ouverture_caisse.visible = true
			$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_conteneur_with_key.visible = true
			
			
			
		if  objet.need_key == false:
			
			var panel_conteneur = get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_conteneur_no_key/pnl_infos_conteneurs/pnl_visualisation_conteneur")	
			panel_conteneur.get_node("pnl_infos_skin/lbl_nom_arme").text = objet.nom # On modifie le label
			panel_conteneur.get_node("pnl_infos_skin/lbl_nom_arme").autowrap_mode  = TextServer.AUTOWRAP_WORD # Permet au label de pouvoir prendre 2 lignes au lieu de 1
			panel_conteneur.get_node("pnl_infos_skin/lbl_nom_skin").text = "" # On modifie le label
			panel_conteneur.get_node("pnl_skin/txtr_skin").texture = load(objet.image_path) # On modifie l'image
			
			$pnl_principal/pnl_inventaire/pnl_inventaire_storage.visible = false
			$pnl_principal/pnl_inventaire/pnl_ouverture_caisse.visible = true
			$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_conteneur_no_key.visible = true
			$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/btn_ouverture_conteneur.text = "Open Container"
			$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/lbl_info_key.text = "This container can only be opened once"
			$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/btn_ouverture_conteneur.visible = true
			
	

func repopulation_grille_inventaire_sans_retoruner_page_1():
	
	populate_grid_skin($pnl_principal/pnl_inventaire/pnl_inventaire_storage/MarginContainer/GridContainer, index_skin_a_charger_debut)
	
	if index_skin_a_charger_debut >= leJoueur.inventaire.size():
		afficher_skins_precedent()
	
	# Met à jour le nombre d'items dans l'inventaire
	$pnl_principal/pnl_inventaire/pnl_inventaire_storage/lbl_items_inventaire_joueur/lbl_nombre_items.text = str(leJoueur.inventaire.size())
	
	# Met à jour la valeur totale de l'inventaire
	$pnl_principal/pnl_inventaire/pnl_inventaire_storage/pnl_prix_inventaire/lbl_prix.text = str(snapped(leJoueur.get_value_inventory(),0.01))

func changer_valeur_page_actuelle_storage():
	$pnl_principal/pnl_inventaire/pnl_inventaire_storage/pnl_prix_inventaire2/lbl_page_actuelle.text = str(page_actuelle)


 # Cette fonction est appelée à chaque fois qu'un événement d'entrée (clavier, souris, etc.) est détecté.
 # Ici, nous nous intéressons uniquement aux événements de clic de souris.
func _input(event):
	# Si l'événement est bien un clic de souris et que le bouton est pressé :
	if event is InputEventMouseButton and event.pressed:
		
		# Vérifiez si le clic est à l'intérieur des limites du panneau, on regarde le vbox container
		var rect = Rect2(Vector2.ZERO, $pnl_objet_cliked/VBoxContainer.size)
		var mouse_position = $pnl_objet_cliked/VBoxContainer.get_local_mouse_position()
		
		if rect.has_point(mouse_position):
			# Si le clic est à l'intérieur du panneau, on ne fait rien et on sort de la fonction.
			return
		# Si le clic est en dehors du panneau, on rend le panneau invisible.
		$pnl_objet_cliked.visible = false




func _on_btn_quitter_caisse_panel_pressed():
	$pnl_principal/pnl_inventaire/pnl_inventaire_storage.visible = true
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse.visible = false
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_conteneur_no_key.visible = false
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_conteneur_with_key.visible = false
	pass # Replace with function body.


func _on_btn_ouverture_conteneur_pressed():
	
	var objet = $pnl_principal/pnl_inventaire/pnl_ouverture_caisse/btn_ouverture_conteneur.get_meta("container_data")
	var panel = get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_animation_ouverture_conteneur/pnl_animation_principal/pnl_principal/hbox")
	
	if $pnl_principal/pnl_inventaire/pnl_ouverture_caisse/btn_ouverture_conteneur.get_meta("container_data") != null:
		var key = $pnl_principal/pnl_inventaire/pnl_ouverture_caisse/btn_ouverture_conteneur.get_meta("key_data")
		leJoueur.inventaire.erase(objet)
		leJoueur.inventaire.erase(key)
	else:
		leJoueur.inventaire.erase(objet)
	
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_animation_ouverture_conteneur.visible = true
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/btn_ouverture_conteneur.visible = false
	get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_animation_ouverture_conteneur/pnl_info_unlocking_container/animation").play("anim_bouton_spawn")
	get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_animation_ouverture_conteneur/pnl_animation_principal/animation").play("anim_ouverture_conteneur")
	
	var drop_rates # Déterminer les taux de drop à utiliser en fonction du type de caisse
	
		# Regarde si le type de la caisse est normal ou pas, choisi les taux de drops
	if objet.type_caisse == "normal":
		drop_rates = default_drop_rates
	else:
		drop_rates = objet.drop_rates
	
	for child in panel.get_children():
		
		if child is Panel:
			
			var randomNum = randf() * 100 # Permet de donner une valeur float entre 0 et 100 en rapport avec le taux de drop
			var cumulative_drop_rate = 0.0 #permet de cumuler les taux de drops afin de voir quand, randomNum est > 
			var category_finale = "" # Permet de stocker la qualité du skin qui est choisi
			var skins_cat_choisi = [] # Stocke les skins de la catégorie choisi
			var skin_choisi_string: String # Nom du skin en valeur string qui est choisi
			var skin_choisi # Skin choisi
			
			# Utilisation des taux de drop pour déterminer la catégorie
			for category in drop_rates.keys():
				cumulative_drop_rate += drop_rates[category]
				if randomNum <= cumulative_drop_rate:
					category_finale = category
					break
			if category_finale == "knive":
				category_finale = drop_rates.keys()[0]
			
			
			# Stocke les skins de la qualitée choisie dans une liste
			skins_cat_choisi = get_skins_by_categories(objet,category_finale)
			print(str(randomNum), " ", str(category_finale))
			# Choisi un skin aléatoire parmis la liste des skins en string
			skin_choisi_string = skins_cat_choisi[randi_range(0,skins_cat_choisi.size() - 1)]
			skin_choisi = skins[skin_choisi_string]
			
			if child.name == "pnl_visualisation_skin24":
				skin_choisi = ouvrir_caisse_v2(objet,objet.type_caisse)
				child.get_node("pnl_skin/txtr_skin").texture = load(skin_choisi.skin.image_path)
				child.get_node("pnl_infos_skin/color_rect_etat_skin").color = skin_choisi.skin.categorie.color
				leJoueur.inventaire.insert(0,skin_choisi)
				
				child.get_node("pnl_infos_skin/lbl_nom_arme").text = skin_choisi.skin.arme.nom
				child.get_node("pnl_infos_skin/lbl_nom_skin").text = skin_choisi.skin.nom
				
				print(skin_choisi.skin.nom)
			else:
				child.get_node("pnl_skin/txtr_skin").texture = load(skin_choisi.image_path)
				child.get_node("pnl_infos_skin/color_rect_etat_skin").color = skin_choisi.categorie.color
				child.get_node("pnl_infos_skin/lbl_nom_arme").text = skin_choisi.arme.nom
				child.get_node("pnl_infos_skin/lbl_nom_skin").text = skin_choisi.nom
	
	var timer = Timer.new()
	timer.wait_time = 6 # 2 secondes
	timer.one_shot = true
	add_child(timer)
	timer.start()
	# Attendre 2 secondes de manière asynchrone
	await timer.timeout
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_ombre_panneau_principal.visible = true
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand.visible = true
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/lbl_nom_item.text = leJoueur.inventaire[0]._to_string()
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/pnl_principal/txtr_skin.texture = load(leJoueur.inventaire[0].skin.image_path)
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/color_objet.color = leJoueur.inventaire[0].skin.categorie.color
	get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/pnl_principal/txtr_skin/AnimationPlayer").play("skin_animation")
	
# Gère les stickers si présents pour l'objet/skin
	for j in range(leJoueur.inventaire[0].stickers5.size()):
		var sticker_node = get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/pnl_principal/hbox_stickers/txtr_sticker%d" % (j + 1))
		sticker_node.texture = load(leJoueur.inventaire[0].stickers5[j].image_path)
		get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/pnl_principal/hbox_stickers/txtr_sticker%d" % (j + 1)).visible = true


func _on_btn_continuer_pressed():
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_ombre_panneau_principal.visible = false
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand.visible = false
	get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/pnl_principal/txtr_skin/AnimationPlayer").stop()
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse.visible = false
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_conteneur_no_key.visible = false
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_conteneur_with_key.visible = false
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_animation_ouverture_conteneur.visible = false
	$pnl_principal/pnl_inventaire/pnl_inventaire_storage.visible = true
	repopulation_grille_inventaire_sans_retoruner_page_1()
