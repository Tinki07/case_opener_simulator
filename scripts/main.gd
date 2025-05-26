extends Node2D




@onready var index_skin_a_charger_debut = 0  # Index du premier skin à afficher dans la grille inventaire
@onready var skins_par_page = 24  # Nombre de skins par page à afficher
@onready var page_actuelle = 1

var nbr_container_to_buy = 1

var is_animation_playing = false
var is_fast_opening = false
var timer = Timer.new()

# Variable qui stocke l'item fianl obtenu lors de l'ouverture d'une capsule
var item_choisi_final

var items_to_show_inventaire: Array

var multi_sell_mode: bool = false

var items_selected_multi_sell_mode: Array
var mode_selection_items_inventaire: String = "default"
var mode_selection_items_inventaire_old: String = "default"


# Création de toutes les variables pour les labels etc...
@onready var lbl_money_player: Label = $pnl_principal/pnl_infos_joueur/pnl_infos_1/pnl_money_joueur/hcont/lbl_argent_joueur
@onready var line_edit_console = $/root/Node2D/LineEdit # référence la console
@onready var lbl_nombre_items_inventaire: Label = $pnl_principal/pnl_inventaire/pnl_inventaire_storage/lbl_items_inventaire_joueur/lbl_nombre_items
@onready var btn_page_storage_suivant: Button = $pnl_principal/pnl_inventaire/pnl_inventaire_storage/btn_page_storage_suivant
@onready var btn_page_storage_precedent: Button = $pnl_principal/pnl_inventaire/pnl_inventaire_storage/btn_page_storage_precedent
@onready var lbl_nbr_page_actuelle: Label = $pnl_principal/pnl_inventaire/pnl_inventaire_storage/pnl_prix_inventaire2/lbl_nbr_page
@onready var lbl_prix_total_inventaire: Label = $pnl_principal/pnl_inventaire/pnl_inventaire_storage/pnl_prix_inventaire/lbl_prix


var is_left_button_clicked = false




func _process(delta):
	lbl_money_player.text = str(snapped(Global.leJoueur.money,0.01))

func _ready():
	
	# Bloque les fps à 60
	Engine.max_fps = 60
	
	# Permet de faire le focus sur la zone de text
	#line_edit_console.grab_focus() 
	
	# Connecte le signal text_submitted du LineEdit à la méthode _on_line_edit_text_submitted
	line_edit_console.text_submitted.connect(self._on_line_edit_text_submitted) 
	
	# Charge les différents objets
	Global.charger_armes_depuis_json()
	Global.charger_categories_skins_depuis_json()
	Global.charger_skins_depuis_json()
	Global.charger_caisses_normales_depuis_json()
	Global.charger_caisses_collections_depuis_json()
	Global.charger_etats_skins_depuis_json()
	Global.charger_types_sticker_depuis_json()
	Global.charger_categories_stickers_depuis_json()
	Global.charger_stickers_depuis_json()
	Global.charger_caisses_souvenirs_depuis_json()
	Global.charger_caisses_capsules_depuis_json()
	Global.charger_keys_conteneurs_depuis_json()
	
	# Ajoute de l'argent aux joueurs
	Global.leJoueur.money = 100000.00
	
	# Charge les données de la sauvegarde
	JsonDataInventory.load_all()
	
	# Ajoute le timer à l'architecture du jeu
	add_child(timer)
	
	# Simule l'action de cliquer sur le boutoninventaire
	_on_btn_inventaire_pressed()



# Méthode appelée lorsque le signal text_submitted est émis
func _on_line_edit_text_submitted(new_text: String):
	
	# Vérifie si la méthode existe
	if has_method(new_text):
		# Appelle la méthode entrée dans le LineEdit
		call(new_text)
		#line_edit.clear()
	else:
		print("La fonction '%s' n'existe pas." % new_text)

func fast_open(id_caisse: String):
	Global.leJoueur.inventaire.insert(0,ouvrir_caisse_v2(Global.conteneurs[id_caisse]))
	
	# Repopule la grid de l'inventaire avec les items de l'inventaire du joueur
	populate_grid_skin($pnl_principal/pnl_inventaire/pnl_inventaire_storage/MarginContainer/GridContainer, 0, mode_selection_items_inventaire)	
	
	# Remet l'index du skin à charger dans l'inventaire, ici 0 car on veux revenir au début
	index_skin_a_charger_debut = 0
	# Remet la varible de la page actuelle à 0
	page_actuelle = 1
	# Actualise la page affichée dans l'inventaire
	changer_valeur_page_actuelle_storage()
	
	# Met à jour le nombre d'items dans l'inventaire
	lbl_nombre_items_inventaire.text = str(items_to_show_inventaire.size())
	# Met à jour la valeur totale de l'inventaire
	$pnl_principal/pnl_inventaire/pnl_inventaire_storage/pnl_prix_inventaire/lbl_prix.text = str(snapped(Global.leJoueur.get_value_inventory(),0.01))
	
	

# Peermet de retourner un objet SkinArmeObtenu, d'une caisse donnéee
func ouvrir_caisse_v2(caisse: Conteneur):
	
	var etat_objet
	var stattrack: bool
	var souvenir: bool = 0
	var item_choosed_object =  return_objet_dropable_from_container(caisse)
	var skin_arme_obtenu_final
	
	# On regarde le type d'objet obtenu
	if item_choosed_object is SkinArme:
		
		# Trouve l'état de l'arme et son float
		etat_objet = trouver_wear_skin(item_choosed_object)
		
		# Permet de savoir si un skin doit etre noté souvenir ou stattrack ou rien
		if caisse.type_caisse == "collection":
			# Si le skin provient d'une collection, il ne peut être ni souvenir ni stattrack.
			stattrack = 0
			souvenir = 0
		elif caisse.type_caisse == "souvenir":
			# Si le skin provient d'une caisse à souvenirs, il est forcément un souvenir.
			stattrack = 0
			souvenir = 1
		else:
			# Pour tous les autres types de caisse, on détermine si le skin est un stattrack
			# en appelant la fonction is_the_skin_stattrack().
			stattrack = is_the_skin_stattrack()
		
		# Créer l'objet SkinArmeObtenu avec toutes les infos nécéssaire
		skin_arme_obtenu_final = SkinArmeObtenu.new(item_choosed_object,etat_objet,stattrack,souvenir)
		
		# Trouve le prix du skin
		skin_arme_obtenu_final.prix = trouver_prix_skin_etat(skin_arme_obtenu_final)
		
		# Vérifie si le skin obtenu est un souvenir.
		if skin_arme_obtenu_final.souvenir:
			# Si c'est un souvenir, ajoute des stickers au package associé.
			_add_stickers_to_souvenir_package(caisse,skin_arme_obtenu_final)
		
	elif item_choosed_object is Sticker:
		# Créer un nouveau objet sticker.
		skin_arme_obtenu_final = Sticker.new(
			item_choosed_object.nom,
			item_choosed_object.id,
			item_choosed_object.equipe,
			item_choosed_object.categorie,
			item_choosed_object.type,
			item_choosed_object.image_path,
			item_choosed_object.prix
		)
	
	return skin_arme_obtenu_final

func return_objet_dropable_from_container(container: Conteneur):
	
	var random_num = randf() * 100 # Permet de donner une valeur float entre 0 et 100 en rapport avec le taux de drop
	var drop_rates # Déterminer les taux de drop à utiliser en fonction du type de caisse
	var cumulative_drop_rate = 0.0 # permet de cumuler les taux de drops afin de voir quand, randomNum est >
	var final_quality = "" # Permet de stocker la qualité du skin qui est choisi
	var selected_category_items = [] # Stocke les skins de la catégorie choisi
	var item_choosed_string: String # Nom du skin en valeur string qui est choisi
	var item_choosed_object # Skin choisi
	
	# Regarde si le type de la caisse est normal ou pas, choisi les taux de drops
	if container.type_caisse == "normal":
		drop_rates = Global.default_drop_rates
	else:
		drop_rates = container.drop_rates
	
	# Utilisation des taux de drop pour déterminer la catégorie
	for category in drop_rates.keys():
		cumulative_drop_rate += drop_rates[category]
		if random_num <= cumulative_drop_rate:
			final_quality = category
			break
	
	# Choisir la première catégorie si aucune n'est sélectionnée
	if final_quality == "":
		final_quality = drop_rates.keys()[0]
	
	# Stocke les skins de la qualitée choisie dans une liste
	selected_category_items = get_skins_by_categories(container,final_quality)
	
	# Choisi un skin aléatoire parmis la liste des skins en string
	item_choosed_string = selected_category_items[randi_range(0,selected_category_items.size() - 1)]
	
	# Grace au string de l'arme choisi, je parcours la liste de tout les objets skins et pour le string
	# correspondant, skin_choisi devient l'objet skin
	if Global.skins.has(item_choosed_string):
		item_choosed_object = Global.skins[item_choosed_string]
	elif Global.stickers.has(item_choosed_string):
		item_choosed_object = Global.stickers[item_choosed_string]
	
	return item_choosed_object


# Trouve l'état de l'arme
func trouver_wear_skin(leSkin: SkinArme):
	
	# Sélectionne aléatoirement un état parmi les états possibles du skin
	var random_index = randi_range(0, (leSkin.etats_possible.size() - 1))
	var etat_nom = leSkin.etats_possible[random_index]
	
	# Récupère les informations détaillées sur l'état sélectionné
	var etat = Global.etats_skins_normaux[etat_nom]
	
	return etat # Retourne l'état sélectionné

# Détermine si un skin est un stattrack de manière aléatoire
func is_the_skin_stattrack():
	
	var randomNum = randi_range(0,100) # Génère un nombre aléatoire entre 0 et 99
	
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
	
	if leSkin.etat == Global.etats_skins_normaux["fn"]:
		index = 0
	elif leSkin.etat == Global.etats_skins_normaux["mw"]:
		index = 1
	elif leSkin.etat == Global.etats_skins_normaux["ft"]:
		index = 2
	elif leSkin.etat == Global.etats_skins_normaux["ww"]:
		index = 3
	elif leSkin.etat == Global.etats_skins_normaux["bs"]:
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
			var equipe = sticker[1]
			var signatures_from_equipe_2: Array
			
			if equipe == stickers_teams[random1][1]:
				lesStickersDeLaTeam1.append(sticker_name)
		var random = randi_range(0,(lesStickersDeLaTeam1.size() - 1))
		#print(str(lesStickersDeLaTeam1.size()))
		sticker_signature_choisi = lesStickersDeLaTeam1[random]
		les_stickers_selectiones.append(sticker_signature_choisi)
	elif stickers_signatures == [] and sticker_map != "":
		les_stickers_selectiones.append(sticker_map)
	
	#print(les_stickers_selectiones)
	skin._add_array_sticker(les_stickers_selectiones,Global.stickers)

# Fonction pour effacer tous les enfants d'une grille - est utilisé pour afficher les items mis a jour
func clear_grid(grid):
	for child in grid.get_children(): # On itère sur tous les enfants du nœud `grid`
		grid.remove_child(child) # On supprime l'enfant de la grille
		child.queue_free() # On marque l'enfant pour destruction lors du prochain cycle


# permet de peupler la grille des skins avec les éléments de l'inventaire du joueur
func populate_grid_skin(grid : GridContainer,index_skin_a_charger_debut: int, string_item_to_show: String = "default"):
	
	# On vide la grille pour éviter les doublons
	clear_grid(grid)
	
	#s'occupe de charger toutes les infos nécessaire pour la création des skins
	var skin_index_debut = index_skin_a_charger_debut
	var skin_index_fin = skin_index_debut + 23
	var skins_loaded = 0  # Compteur pour les skins chargés
	
	var items_to_show: Array
	
	if string_item_to_show == "skins":
		for item in Global.leJoueur.inventaire:
			if item is SkinArmeObtenu:
				items_to_show.append(item)
		
	if string_item_to_show == "skins_non_favoris":
		for item in Global.leJoueur.inventaire:
			if item is SkinArmeObtenu:
				if !item.favori:
					items_to_show.append(item)
		
	elif string_item_to_show == "stickers":
		for item in Global.leJoueur.inventaire:
			if item is Sticker:
				items_to_show.append(item)
		
	elif string_item_to_show == "stickers_non_favoris":
		for item in Global.leJoueur.inventaire:
			if item is Sticker:
				if !item.favori:
					items_to_show.append(item)
		
	elif string_item_to_show == "containers" or string_item_to_show == "containers_non_favoris":
		for item in Global.leJoueur.inventaire:
			if item is Conteneur or item is KeyConteneur:
				items_to_show.append(item)
		
	elif string_item_to_show == "favoris":
		for item in Global.leJoueur.inventaire:
			if (item is SkinArmeObtenu or item is Sticker) and item.favori:
				items_to_show.append(item)
		
	elif string_item_to_show == "favoris_non_favoris":
		for item in Global.leJoueur.inventaire:
			if item is SkinArmeObtenu or item is Sticker:
				if !item.favori:
					items_to_show.append(item)
			else:
				items_to_show.append(item)
		
	elif string_item_to_show == "default":
		items_to_show = Global.leJoueur.inventaire
		
	elif string_item_to_show == "default_non_favoris":
		for item in Global.leJoueur.inventaire:
			if item is SkinArmeObtenu or item is Sticker:
				if !item.favori:
					items_to_show.append(item)
			else:
				items_to_show.append(item)
		
	
	items_to_show_inventaire = items_to_show
	
	# On parcourt l'inventaire du joueur et on crée un élément pour chaque skin
	for i in range(skin_index_debut, min(skin_index_fin + 1, items_to_show.size())):
	
		# Met en variable l'objet qui sera attribué au pannel
		var objet = items_to_show[i]
		
		# Récupère les infos du nouveau panel
		var new_panel_objet = Global.pnl_prefab_skin_arme.instantiate() # On crée un bouton
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
			
			if objet.favori:
				new_panel_objet.get_node("Icons8-étoilé-remplie-96").visible = true
			else:
				new_panel_objet.get_node("Icons8-étoilé-remplie-96").visible = false
			
			
			# Gère les stickers si présents pour l'objet/skin
			for j in range(objet.stickers5.size()):
				var sticker_node = new_panel_objet.get_node("pnl_skin/txtr_sticker%d" % (j + 1))
				sticker_node.texture = load(objet.stickers5[j].image_path)
			
			for child in image_objet.get_children():
				child.visible = false
			
			if objet.etat.id == "bs":
				image_objet.get_node("txtr_bs").visible = true
			elif objet.etat.id == "ww":
				image_objet.get_node("txtr_ww").visible = true
			elif objet.etat.id == "ft":
				image_objet.get_node("txtr_ft").visible = true
			elif objet.etat.id == "mw":
				image_objet.get_node("txtr_mw").visible = true
			elif objet.etat.id == "fn":
				image_objet.get_node("txtr_fn").visible = true
			
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
		elif objet is Sticker:
			
			if objet.favori:
				new_panel_objet.get_node("Icons8-étoilé-remplie-96").visible = true
			else:
				new_panel_objet.get_node("Icons8-étoilé-remplie-96").visible = false
			
			lalbel_principal_objet.text = objet.nom # On modifie le label
			label_secondaire_objet.text = "Sticker" # On modifie le label
			color_categorie_objet.color = objet.categorie.color # On modifie la couleur
			image_objet.texture = load(objet.image_path) # On modifie l'image
		
		if objet.sell_selected == true:
			new_panel_objet.get_node("Icons8-vendre-96").visible = true
		else:
			new_panel_objet.get_node("Icons8-vendre-96").visible = false
		
		# Associer l'objet "skin - SkinArmeObtenu" au bouton du panel
		new_panel_objet.set_meta("skin_data", objet)
		
 		# Connecter le signal "pressed" du bouton à une fonction de gestion
		btn_panel_objet.pressed.connect(self._on_objet_inventory_button_pressed.bind(new_panel_objet))
		btn_panel_objet.mouse_entered.connect(self._on_objet_inventory_button_mouse_entered.bind(new_panel_objet))
		
		
		# Ajoute le panneau configuré à la grille
		grid.add_child(new_panel_objet) # On ajoute le panneau à la grille
		
	# On met à jour la visibilité des boutons de navigation (Suivant/Précédent)
	# Activer/Désactiver le bouton suivant
	if skin_index_fin < items_to_show.size() - 1:
		btn_page_storage_suivant.visible = true
	else:
		btn_page_storage_suivant.visible = false
		
	# Activer/Désactiver le bouton précédent
	if index_skin_a_charger_debut > 0:
		btn_page_storage_precedent.visible = true
	else:
		btn_page_storage_precedent.visible = false
	calculer_nombre_page()



# Affiche la page suivante de skins dans l'inventaire
func afficher_skins_suivant():
	# Vérifie s'il y a encore des skins à afficher
	if index_skin_a_charger_debut + skins_par_page < items_to_show_inventaire.size():
		
		# Met à jour l'index de départ pour la prochaine page
		index_skin_a_charger_debut += skins_par_page
		
		page_actuelle += 1
		changer_valeur_page_actuelle_storage()
		
		# Remplit la grille avec les skins de la nouvelle page
		#repopulation_grille_inventaire_sans_retoruner_page_1(mode_selection_items_inventaire)
		populate_grid_skin($pnl_principal/pnl_inventaire/pnl_inventaire_storage/MarginContainer/GridContainer, index_skin_a_charger_debut, mode_selection_items_inventaire)


# Affiche la page précédente de skins dans l'inventaire
func afficher_skins_precedent():
	# Vérifie si on peut revenir à la page précédente
	if index_skin_a_charger_debut - skins_par_page >= 0:
		
		# Met à jour l'index de départ pour la page précédente
		index_skin_a_charger_debut -= skins_par_page
		
		page_actuelle -= 1
		changer_valeur_page_actuelle_storage()
		
		# Remplit la grille avec les skins de la nouvelle page
		#repopulation_grille_inventaire_sans_retoruner_page_1(mode_selection_items_inventaire)
		populate_grid_skin($pnl_principal/pnl_inventaire/pnl_inventaire_storage/MarginContainer/GridContainer, index_skin_a_charger_debut, mode_selection_items_inventaire)

func calculer_nombre_page():
	var nbr_pages = items_to_show_inventaire.size() / skins_par_page
	lbl_nbr_page_actuelle.text = "/" + str( ceil((items_to_show_inventaire.size() - 1)/ skins_par_page) + 1)


# Elle gère l'affichage et la mise à jour de l'inventaire du joueur.
func _on_btn_inventaire_pressed():
	
	var audio_player2 = $pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_inventaire/AudioStreamPlayer2D
	audio_player2.play()
	$pnl_principal/pnl_inventaire.visible = true
	
	# Repopule la grid de l'inventaire avec les items de l'inventaire du joueur
	populate_grid_skin($pnl_principal/pnl_inventaire/pnl_inventaire_storage/MarginContainer/GridContainer, 0, mode_selection_items_inventaire)	
	# Remet l'index du skin à charger dans l'inventaire, ici 0 car on veux revenir au début
	index_skin_a_charger_debut = 0
	# Remet la varible de la page actuelle à 0
	page_actuelle = 1
	# Actualise la page affichée dans l'inventaire
	changer_valeur_page_actuelle_storage()
	
	# Met à jour le nombre d'items dans l'inventaire
	lbl_nombre_items_inventaire.text = str(items_to_show_inventaire.size())
	
	# Met à jour la valeur totale de l'inventaire
	lbl_prix_total_inventaire.text = str(snapped(Global.leJoueur.get_value_inventory(),0.01))
	
	# Cache le panel shoooooooooooop
	$pnl_principal/pnl_shop.visible = false
	
	$pnl_principal/pnl_inventaire/pnl_titre/btn_quitter_caisse_panel.visible = false
	$pnl_principal/pnl_inventaire/pnl_inventaire_storage.visible = true
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse.visible = false
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_conteneur_no_key.visible = false
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_conteneur_with_key.visible = false



# Permet l'affichage des skins suivants dans l'inventaire.
func _on_btn_page_storage_suivant_pressed():
	
	#var audio_player = $pnl_principal/pnl_inventaire/pnl_inventaire_storage/btn_page_storage_suivant/AudioStreamPlayer2D
	var audio_player = btn_page_storage_suivant.get_node("AudioStreamPlayer2D")
	audio_player.play()
	
	afficher_skins_suivant()

# Permet l'affichage des skins précédents dans l'inventaire.
func _on_btn_page_storage_precedent_pressed():
	
	var audio_player = btn_page_storage_precedent.get_node("AudioStreamPlayer2D")
	audio_player.play()
	
	afficher_skins_precedent()

func _on_objet_inventory_button_mouse_entered(button):
	
	# Récupérer les informations sur l'objet clické à partir du metadata
	var item_clicked = button.get_meta("skin_data")
	
	var audio_player = get_node(str(button.get_path()) + "/btn_skin/audio_anim_survole")
	audio_player.play()
	
	if multi_sell_mode:
		if is_left_button_clicked:
			if item_clicked.sell_selected == false:
			
				# Set le mode vente à true
				item_clicked.set_sell_selected(true)
				# Ajoute l'item à la liste des items à vendre
				items_selected_multi_sell_mode.append(item_clicked)
				
				# Repopule la grille avec le mode de sélection des skins seulement 'mode_selection_items_inventaire'
				repopulation_grille_inventaire_sans_retoruner_page_1(mode_selection_items_inventaire)
				# Actualise le label contenant la size de la liste des items à vendre
				$pnl_principal/pnl_inventaire/pnl_inventaire_storage/btn_sell_confirmation/Panel/HBoxContainer/lbl_nombre_items.text = str(items_selected_multi_sell_mode.size())
				
				# Si il y a un item dans la liste des skins à vendre, le bouton n'est plus disable sinon il est disable
				if items_selected_multi_sell_mode.size() > 0:
					$pnl_principal/pnl_inventaire/pnl_inventaire_storage/btn_sell_confirmation.disabled = false
				if items_selected_multi_sell_mode.size() == 0:
					$pnl_principal/pnl_inventaire/pnl_inventaire_storage/btn_sell_confirmation.disabled = true



# Une fois un item clické dans l'inventaire, ca nous ouvre un petit panel qui contient des boutons
# qui permettend de faire des actions différentes.
# C'est ici qu'est la première étape.
func _on_objet_inventory_button_pressed(button):
	
	var audio_player = $pnl_objet_cliked/audio_anim_select
	audio_player.play()
	
	# Récupérer les informations sur l'objet clické à partir du metadata
	var item_clicked = button.get_meta("skin_data")
	
	# On met le pannel et les boutons dans des variables
	var panel_item_cliked = $pnl_objet_cliked
	var btn_inspect: Button = $pnl_objet_cliked/VBoxContainer/btn_inspect
	var btn_delete: Button = $pnl_objet_cliked/VBoxContainer/btn_delete_objet
	var btn_open: Button = $pnl_objet_cliked/VBoxContainer/btn_ouvrir
	var btn_fast_open: Button = $pnl_objet_cliked/VBoxContainer/btn_fast_ouvrir
	
	# Regarde si le multi sell mode est activé ou pas
	if multi_sell_mode == true:
		
		# Regarde si le bouton préssé est déjà noté comme en vente
		if item_clicked.sell_selected == false:
			
			# Set le mode vente à true
			item_clicked.set_sell_selected(true)
			# Ajoute l'item à la liste des items à vendre
			items_selected_multi_sell_mode.append(item_clicked)
		else:
			
			# Set le mode vente à false
			item_clicked.set_sell_selected(false)
			# Retire l'item de la liste des items à vendre
			items_selected_multi_sell_mode.erase(item_clicked)
		
		# Repopule la grille avec le mode de sélection des skins seulement 'mode_selection_items_inventaire'
		repopulation_grille_inventaire_sans_retoruner_page_1(mode_selection_items_inventaire)
		# Actualise le label contenant la size de la liste des items à vendre
		$pnl_principal/pnl_inventaire/pnl_inventaire_storage/btn_sell_confirmation/Panel/HBoxContainer/lbl_nombre_items.text = str(items_selected_multi_sell_mode.size())
		
		# Si il y a un item dans la liste des skins à vendre, le bouton n'est plus disable sinon il est disable
		if items_selected_multi_sell_mode.size() > 0:
			$pnl_principal/pnl_inventaire/pnl_inventaire_storage/btn_sell_confirmation.disabled = false
		if items_selected_multi_sell_mode.size() == 0:
			$pnl_principal/pnl_inventaire/pnl_inventaire_storage/btn_sell_confirmation.disabled = true
		
	else:
		
		# On vérifie quel est le type de l'objet associé au panneau et on vois quels boutons on active ou non
		if item_clicked is SkinArmeObtenu:
			if item_clicked.favori:
				btn_delete.visible = false
			else:
				btn_delete.visible = true
			btn_inspect.visible = true
			btn_open.visible = false
			btn_fast_open.visible = false
			
		elif item_clicked is Conteneur:
			btn_inspect.visible = false
			btn_delete.visible = true
			btn_open.visible = true
			
			if item_clicked.need_key == true:
				
				var key_container = Global.keys_conteneurs[item_clicked.id + "_key"]
				
				var item_found = false  # Variable pour suivre si l'item KEY est trouvé ou non
				for item in Global.leJoueur.inventaire:
					if item is KeyConteneur:
						if item.id == key_container.id:
							item_found = true
							break
				# Si il y a une clé dans l'inventaire du joueur correspondant au conteneur cliké alors :
				if not item_found:
					btn_fast_open.visible = false
					print("pas de clé")
				else: # Sinon :
					btn_fast_open.visible = true
					print("Il y a une clé letsgooo")
			elif  item_clicked.need_key == false: # Sinon :
				print("pas besoin de clé chef")
				btn_fast_open.visible = true
			
		elif item_clicked is Sticker:	
			if item_clicked.favori:
				btn_delete.visible = false
			else:
				btn_delete.visible = true
			btn_inspect.visible = true
			btn_open.visible = false
			btn_fast_open.visible = false
			
		else:
			btn_inspect.visible = false
			btn_delete.visible = true
			btn_open.visible = false
			btn_fast_open.visible = false
			
		
		# Après avoir déterminé quels boutons seront visible, on rend le panel visible
		panel_item_cliked.visible = !panel_item_cliked.visible
		panel_item_cliked.position = get_global_mouse_position()
		
		
		# On gère les boutons -------------------------------------------------------------------------
		
		# Gestion du bouton inspect de l'objet
		if btn_inspect.pressed.is_connected(self._on_inspect_objet_button_pressed):
			btn_inspect.pressed.disconnect(self._on_inspect_objet_button_pressed)
		# Connecter le signal "pressed" du bouton inspect à une fonction de gestion
		btn_inspect.pressed.connect(self._on_inspect_objet_button_pressed.bind(item_clicked))
		
		# Gestion du bouton delete de l'objet
		if btn_delete.pressed.is_connected(self._on_delete_objet_button_pressed):
			btn_delete.pressed.disconnect(self._on_delete_objet_button_pressed)
		btn_delete.pressed.connect(self._on_delete_objet_button_pressed.bind(item_clicked))
		
		# Gestion du bouton open de l'objet
		if btn_open.pressed.is_connected(self._on_ouvrir_objet_button_pressed):
			btn_open.pressed.disconnect(self._on_ouvrir_objet_button_pressed)
		btn_open.pressed.connect(self._on_ouvrir_objet_button_pressed.bind(item_clicked))
		
		# Gestion du bouton fast_open de l'objet
		if btn_fast_open.pressed.is_connected(self._on_fast_ouvrir_objet_button_pressed):
			btn_fast_open.pressed.disconnect(self._on_fast_ouvrir_objet_button_pressed)
		btn_fast_open.pressed.connect(self._on_fast_ouvrir_objet_button_pressed.bind(item_clicked))
		
		# ---------------------------------------------------------------------------------------------

func _on_fast_ouvrir_objet_button_pressed(objet : Conteneur):
	
	# On supprime la caisse et le conteneur et la clé si il y en a une
	Global.leJoueur.inventaire.erase(objet)
	
	if objet.need_key:
		for item in Global.leJoueur.inventaire:
			if item is KeyConteneur:
				if item.id == objet.id + "_key": 
					Global.leJoueur.inventaire.erase(item)
					break
	
	# On ouvre la caisse et on ajoute l'item trouvé dans l'inventaire du joueur
	Global.leJoueur.inventaire.insert(0,ouvrir_caisse_v2(Global.conteneurs[objet.id]))
	
	repopulation_grille_inventaire_sans_retoruner_page_1(mode_selection_items_inventaire)
	
	# On cache le menu des boutons du panel clické dans l'inventaire
	var panel_item_cliked = $pnl_objet_cliked
	panel_item_cliked.visible = false
	
	# On envoi une notif pour montrer quel skin on a eu
	var style_box = get_node("%pnl_notification_buy").get_theme_stylebox("panel")
	style_box.bg_color = Global.leJoueur.inventaire[0].get_color()
	get_node("%pnl_notification_buy/AnimationPlayer").stop()
	get_node("%pnl_notification_buy/txtr_dollar").texture = load(Global.leJoueur.inventaire[0].get_image())
	get_node("%pnl_notification_buy/lbl_infos").text = "You got a " + Global.leJoueur.inventaire[0]._to_string() +" !"
	get_node("%pnl_notification_buy/AnimationPlayer").play("notification_anim")
	
	if Global.leJoueur.inventaire[0] is SkinArmeObtenu:
			
		var anim_sound = load(Global.leJoueur.inventaire[0].skin.categorie.anim_drop_sound)
		
		# Vérifier que anim_sound n'est pas nul et est bien un AudioStream
		if anim_sound is AudioStreamMP3:
			var audio_player = $pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/pnl_principal/txtr_skin/drop_anim_sound
			audio_player.stream = anim_sound
			audio_player.play()
		
	elif Global.leJoueur.inventaire[0] is Sticker:
			
		var anim_sound = load(Global.leJoueur.inventaire[0].categorie.anim_drop_sound)
		
		# Vérifier que anim_sound n'est pas nul et est bien un AudioStream
		if anim_sound is AudioStreamMP3:
			var audio_player = $pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/pnl_principal/txtr_skin/drop_anim_sound
			audio_player.stream = anim_sound
			audio_player.play()
	

# Actions faites quand le bouton delete d'un item est clické
func _on_delete_objet_button_pressed(objet):
	
	var audio_player = $pnl_objet_cliked/audio_anim_vendre
	audio_player.play()
	
	Global.leJoueur.money += objet.prix
	Global.leJoueur.inventaire.erase(objet)
	$pnl_objet_cliked.visible = false
	
	repopulation_grille_inventaire_sans_retoruner_page_1(mode_selection_items_inventaire)

# Actions faites quand le bouton inspect d'un item est clické
func _on_inspect_objet_button_pressed(objet):
	
	get_node("pnl_inspect_skin_grand/pnl_principal/txtr_skin/AnimationPlayer").play("skin_animation")
	
	var audio_player = $pnl_objet_cliked/audio_anim_select
	audio_player.play()
	
	$pnl_inspect_skin_grand/pnl_principal/txtr_favori.visible = false
	$pnl_objet_cliked.visible = false
	$pnl_ombre_panneau_principal.visible = true
	$pnl_inspect_skin_grand.visible = true
	
	$pnl_choose_sticker.set_meta("item", objet)
	
	var panel = $pnl_inspect_skin_grand
	panel.get_node("color_objet").color = objet.get_color()
	panel.get_node("lbl_nom_item").text = objet._to_string()
	panel.get_node("Panel/VBoxContainer/pnl_quality/lbl_info").text = objet.get_quality()
	panel.get_node("pnl_principal/txtr_skin").texture = load(objet.get_image())
	panel.get_node("Panel/VBoxContainer/pnl_price/lbl_info").text = "$" + str(objet.get_price())
	
	for child in panel.get_node("pnl_principal/txtr_skin").get_children():
		if not child is AnimationPlayer:
			child.visible = false
	
	if objet is SkinArmeObtenu:
		
		if objet.favori:
			$pnl_inspect_skin_grand/pnl_principal/txtr_favori.texture = load("res://resources/images/etoile (3).png")
		elif !objet.favori:
			$pnl_inspect_skin_grand/pnl_principal/txtr_favori.texture = load("res://resources/images/etoile (2).png")
		$pnl_inspect_skin_grand/pnl_principal/txtr_favori.visible = true
		
		panel.get_node("Panel/VBoxContainer/pnl_wear").visible = true
		panel.get_node("Panel/VBoxContainer/pnl_wear/lbl_info").text = objet.etat.nom
		
		for child in get_node("pnl_inspect_skin_grand/pnl_principal/hbox_stickers").get_children():
			child.visible = false
		
		
		
		if objet.skin.categorie.nom == "★ Rare Special Item":
			get_node("pnl_inspect_skin_grand/pnl_principal/hbox_stickers/btn_add_sticker").visible = false
		else:
			get_node("pnl_inspect_skin_grand/pnl_principal/hbox_stickers/btn_add_sticker").visible = true
		
		
		if objet.stickers5.size() != 0:
			for j in range(objet.stickers5.size()):
				var sticker_node = get_node("pnl_inspect_skin_grand/pnl_principal/hbox_stickers/txtr_sticker%d" % (j + 1))
				sticker_node.texture = load(objet.stickers5[j].image_path)
				get_node("pnl_inspect_skin_grand/pnl_principal/hbox_stickers/txtr_sticker%d" % (j + 1)).visible = true
			if objet.stickers5.size() == 5 :
				get_node("pnl_inspect_skin_grand/pnl_principal/hbox_stickers/btn_add_sticker").visible = false
		
		if objet.etat.id == "bs":
			panel.get_node("pnl_principal/txtr_skin").get_node("txtr_bs").visible = true
		elif objet.etat.id == "ww":
			panel.get_node("pnl_principal/txtr_skin").get_node("txtr_ww").visible = true
		elif objet.etat.id == "ft":
			panel.get_node("pnl_principal/txtr_skin").get_node("txtr_ft").visible = true
		elif objet.etat.id == "mw":
			panel.get_node("pnl_principal/txtr_skin").get_node("txtr_mw").visible = true
		elif objet.etat.id == "fn":
			panel.get_node("pnl_principal/txtr_skin").get_node("txtr_fn").visible = true
		
		
	elif objet is Sticker:
		
		if objet.favori:
			$pnl_inspect_skin_grand/pnl_principal/txtr_favori.texture = load("res://resources/images/etoile (3).png")
		elif !objet.favori:
			$pnl_inspect_skin_grand/pnl_principal/txtr_favori.texture = load("res://resources/images/etoile (2).png")
		$pnl_inspect_skin_grand/pnl_principal/txtr_favori.visible = true
		
		panel.get_node("Panel/VBoxContainer/pnl_wear").visible = false
		for child in get_node("pnl_inspect_skin_grand/pnl_principal/hbox_stickers").get_children():
			child.visible = false

# Actions faites quand le bouton ouvrir d'un item est clické
func _on_ouvrir_objet_button_pressed(item_clicked):
	
	var audio_player = $pnl_objet_cliked/audio_anim_select
	audio_player.play()
	
	is_animation_playing = false
	var panel_item_cliked = $pnl_objet_cliked
	var btn_exit = $pnl_principal/pnl_inventaire/pnl_titre/btn_quitter_caisse_panel
	var lbl_container_name_top = $pnl_principal/pnl_inventaire/pnl_ouverture_caisse/hbox_nom_caisse/lbl_nom_caisse
	var items_grid_container = get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_items_in_caisse/scroll/margin/grid_items")
	var btn_open_container = $pnl_principal/pnl_inventaire/pnl_ouverture_caisse/btn_ouverture_conteneur
	var lbl_info_key = $pnl_principal/pnl_inventaire/pnl_ouverture_caisse/lbl_info_key
	var pnl_inventaire_storage = $pnl_principal/pnl_inventaire/pnl_inventaire_storage
	var pnl_ouverture_caisse = $pnl_principal/pnl_inventaire/pnl_ouverture_caisse
	var pnl_conteneur_no_key =  $pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_conteneur_no_key
	var pnl_conteneur_with_key =  $pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_conteneur_with_key
	
	
	panel_item_cliked.visible = false # Cache le panel contenant tout les boutons (inspect,ouvrir etc..)
	btn_exit.visible = true # Rend la croix en haut a droite visible
	
	# On vérifie si l'objet est un conteneur ou pas
	if item_clicked is Conteneur:
		
		lbl_container_name_top.text = item_clicked.nom # Affiche le nom du container cliké en haut du panel
		clear_grid(items_grid_container) # On clear la grille de visualisation des objets du conteneur
		
		# On transmet le container afin que quand on aura appuyé sur le bouton "open" container,
		# les skins dans l'animation puisses avoir les infos des objets du container
		$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/btn_ouverture_conteneur.set_meta("container_data", item_clicked)
		
		
		var special_item_found = false  # Drapeau pour indiquer si un couteau a été trouvé
		
		for item_caisse in item_clicked.objets_dropable:
			
			var item = item_caisse[0]
			
			
			# Met les infos de l'objet en rapport avec le type - ici dans le cas ou c'est un SkinArme
			if Global.skins.has(item):
				
				# On regarde si l'item est un couteau, si oui le drapeau devient true
				if Global.skins[item].categorie == Global.categories["knive"] :
					special_item_found = true
				else: # Sinon on créer juste un panel pour chaque skin
					var new_panel_objet = return_new_pnl_prefab_skin_arme_configurated(
						Global.skins[item].arme.nom,
						Global.skins[item].nom,
						Global.skins[item].image_path,
						Global.skins[item].categorie.color
					)
					items_grid_container.add_child(new_panel_objet) # On ajoute le panneau à la grille
			elif Global.stickers.has(item):
				var new_panel_objet = return_new_pnl_prefab_skin_arme_configurated(
					Global.stickers[item].nom,
					"",
					Global.stickers[item].image_path,
					Global.stickers[item].categorie.color
				)
				items_grid_container.add_child(new_panel_objet) # On ajoute le panneau à la grille
		
		# Si le drapeau special_item_found est égal à true alors cela veus dire qu'il y a au moins un objet rare
		# dans la caisse, alors on créer le pannel des objets rares
		if special_item_found:
			
			# Création du pannel des objets rares
			var special_panel = return_new_pnl_prefab_skin_arme_configurated(
				Global.categories['knive'].nom,
				"",
				"res://resources/images/Csgo-default_rare_item.png",
				"ffd700"
			)
			items_grid_container.add_child(special_panel) # On ajoute le panneau à la grille des skins
		
		# On regarde si le conteneur a besoin d'une clé ou pas
		if item_clicked.need_key == true:
			
			# On stocke la clé nécéssaire à l'ouverture du conatianer
			# Ensuite on l'envoi comme le container plus haut,
			var key_container = Global.keys_conteneurs[item_clicked.id + "_key"]
			$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/btn_ouverture_conteneur.set_meta("key_data", key_container)
			
			# On récupère les infos du pnneau du container
			var panel_key = get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_conteneur_with_key/pnl_infos_conteneurs/pnl_visualisation_key")# On crée un bouton
			var label_principal_key = panel_key.get_node("pnl_infos_skin/lbl_nom_arme") # On récupère son label
			var label_secondaire_key = panel_key.get_node("pnl_infos_skin/lbl_nom_skin") # On récupère son label
			var image_key = panel_key.get_node("pnl_skin/txtr_skin") # On récupère son image
			
			# On récupère les infos du pnneau de la clé
			var panel_conteneur = get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_conteneur_with_key/pnl_infos_conteneurs/pnl_visualisation_conteneur")
			var label_principal_conteneur = panel_conteneur.get_node("pnl_infos_skin/lbl_nom_arme") # On récupère son label
			var label_secondaire_conteneur = panel_conteneur.get_node("pnl_infos_skin/lbl_nom_skin") # On récupère son label
			var image_conteneur = panel_conteneur.get_node("pnl_skin/txtr_skin") # On récupère son image
			
			# On modifie les infos du panneau du container
			label_principal_conteneur.text = item_clicked.nom # On modifie le label
			label_secondaire_conteneur.text = "" # On modifie le label
			label_principal_conteneur.autowrap_mode  = TextServer.AUTOWRAP_WORD # Permet au label de pouvoir prendre 2 lignes au lieu de 1
			image_conteneur.texture = load(item_clicked.image_path) # On modifie l'image
			
			# On modifie les infos du panneau de la clé
			label_principal_key.text = key_container.nom # On modifie le label
			label_secondaire_key.text = "" # On modifie le label
			label_principal_key.autowrap_mode  = TextServer.AUTOWRAP_WORD # Permet au label de pouvoir prendre 2 lignes au lieu de 1
			image_key.texture = load(key_container.image_path) # On modifie l'image
			
			# Ici ca nous permet de voir si il y a une clé correspondate au conteneur ou non
			# Dans l'inventaire du joueur pour savoir si on affiche le bouton ouverture ou pas 
			var item_found = false  # Variable pour suivre si l'item KEY est trouvé ou non
			for item in Global.leJoueur.inventaire:
				if item is KeyConteneur:
					if item.id == key_container.id:
						item_found = true
						break
					
			# Si il y a une clé dans l'inventaire du joueur correspondant au conteneur cliké alors :
			if not item_found:
				btn_open_container.visible = false
				lbl_info_key.text = "you need a " + key_container.nom + " to open this container"
			else: # Sinon :
				btn_open_container.visible = true
				btn_open_container.text = "Use Key"
				lbl_info_key.text = "Key can be only use once"
			
			# On affiche le panel qui correspond au conteneur nécessitant une clé
			pnl_conteneur_with_key.visible = true
			
		elif  item_clicked.need_key == false: # Sinon :
			
			# On récupère les infos du pnneau du container
			var panel_conteneur = get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_conteneur_no_key/pnl_infos_conteneurs/pnl_visualisation_conteneur")
			var label_principal_conteneur = panel_conteneur.get_node("pnl_infos_skin/lbl_nom_arme") # On récupère son label
			var label_secondaire_conteneur = panel_conteneur.get_node("pnl_infos_skin/lbl_nom_skin") # On récupère son label
			var image_conteneur = panel_conteneur.get_node("pnl_skin/txtr_skin") # On récupère son image
			
			# On modifie les infos du panneau du container
			label_principal_conteneur.text = item_clicked.nom # On modifie le label
			label_principal_conteneur.autowrap_mode  = TextServer.AUTOWRAP_WORD # Permet au label de pouvoir prendre 2 lignes au lieu de 1
			label_secondaire_conteneur.text = "" # On modifie le label
			image_conteneur.texture = load(item_clicked.image_path) # On modifie l'image
			
			# On modifie des infos UI
			pnl_conteneur_no_key.visible = true # Affichage du panneau pour les coneneurs sans clés
			btn_open_container.text = "Open Container"
			btn_open_container.visible = true
			lbl_info_key.text = "This container can only be opened once"
			
		# On cache le panel de l'inventaire et on rend visible le panel concernant l'ouverture des conteneurs
		pnl_inventaire_storage.visible = false
		pnl_ouverture_caisse.visible = true

# Permet de créer et de configurer un panel pour la visualisation d'un objet
func return_new_pnl_prefab_skin_arme_configurated(infos_lbl_1_item: String, infos_lbl_2_item: String,
	infos_image_path_item: String, infos_color_item: String):
	
	var new_panel_item = Global.pnl_prefab_skin_arme.instantiate() # On crée un bouton
	var lbl_1_new_panel = new_panel_item.get_node("pnl_infos_skin/lbl_nom_arme")
	var lbl_2_new_panel = new_panel_item.get_node("pnl_infos_skin/lbl_nom_skin")
	var txtr_new_panel = new_panel_item.get_node("pnl_skin/txtr_skin")
	var clr_rec_new_panel = new_panel_item.get_node("pnl_infos_skin/color_rect_etat_skin")
	
	lbl_1_new_panel.text = infos_lbl_1_item
	
	if infos_lbl_2_item == "":
		lbl_2_new_panel.text = ""
		lbl_1_new_panel.autowrap_mode  = TextServer.AUTOWRAP_WORD
	else:
		lbl_2_new_panel.text = infos_lbl_2_item
	
	txtr_new_panel.texture = load(infos_image_path_item)
	clr_rec_new_panel.color = infos_color_item
	
	return new_panel_item

# Permet de mettre a jouer l'inventaire du joueur mais aussi la grill de l'inventaire sans revenir à la page 1
func repopulation_grille_inventaire_sans_retoruner_page_1(string_item_to_show: String = "default"):
	
	var inventory_grid = $pnl_principal/pnl_inventaire/pnl_inventaire_storage/MarginContainer/GridContainer
	var lbl_price_inventory = $pnl_principal/pnl_inventaire/pnl_inventaire_storage/pnl_prix_inventaire/lbl_prix
	
	# On repopue la grille a partir de index_skin_a_charger_debut
	populate_grid_skin(inventory_grid, index_skin_a_charger_debut,string_item_to_show)
	
	print(index_skin_a_charger_debut)
	# Ca permet de faire en sorte que si on est sur la page 2 et que qu'il reste qu'un objet et que je viens a le
	# delete, le jeu comprendra qu'il faudra revenir a la page d'avant au lieu que ca me laisse sur une page vide
	if index_skin_a_charger_debut >= items_to_show_inventaire.size():
		afficher_skins_precedent()
	
	# Met à jour le nombre d'items dans l'inventaire
	lbl_nombre_items_inventaire.text = str(items_to_show_inventaire.size())
	
	# Met à jour la valeur totale de l'inventaire
	lbl_prix_total_inventaire.text = str(snapped(Global.leJoueur.get_value_inventory(),0.01))

# Permet de changer le value de la page actuelle dans la page inventaire
func changer_valeur_page_actuelle_storage():
	$pnl_principal/pnl_inventaire/pnl_inventaire_storage/pnl_prix_inventaire2/lbl_page_actuelle.text = str(page_actuelle)


 # Cette fonction est appelée à chaque fois qu'un événement d'entrée (clavier, souris, etc.) est détecté.
 # Ici, nous nous intéressons uniquement aux événements de clic de souris.
func _input(event):
	# Si l'événement est bien un clic de souris et que le bouton est pressé :
	if event is InputEventMouseButton:
		
		# Vérifiez si le clic est à l'intérieur des limites du panneau, on regarde le vbox container
		var rect = Rect2(Vector2.ZERO, $pnl_objet_cliked/VBoxContainer.size)
		var mouse_position = $pnl_objet_cliked/VBoxContainer.get_local_mouse_position()
		
		if rect.has_point(mouse_position):
			# Si le clic est à l'intérieur du panneau, on ne fait rien et on sort de la fonction.
			return
		else:
			# Si le clic est en dehors du panneau, on rend le panneau invisible.
			$pnl_objet_cliked.visible = false
		
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			is_left_button_clicked = true
		elif not event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			is_left_button_clicked = false
		
	if is_animation_playing and $pnl_principal/pnl_inventaire/pnl_titre/btn_quitter_caisse_panel.visible:
		if event is InputEventKey and event.keycode == KEY_ENTER:
			_on_btn_quitter_caisse_panel_pressed()

# Action appelée quand on appuis sur la croix en haut a droite
func _on_btn_quitter_caisse_panel_pressed():
	$pnl_principal/pnl_inventaire/pnl_titre/btn_quitter_caisse_panel.visible = false
	$pnl_principal/pnl_inventaire/pnl_inventaire_storage.visible = true
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse.visible = false
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_conteneur_no_key.visible = false
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_conteneur_with_key.visible = false
	
	var audio_player2 = $pnl_principal/pnl_inventaire/pnl_titre/btn_quitter_caisse_panel/AudioStreamPlayer2D
	audio_player2.play()
	
	repopulation_grille_inventaire_sans_retoruner_page_1(mode_selection_items_inventaire)
	
	# Réinitialisation de la sélection
	item_choisi_final = null
	
	if is_animation_playing:
		
		get_node("pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_inventaire").disabled = false
		get_node("pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_shop").disabled = false
		
		$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_animation_ouverture_conteneur/pnl_animation_principal/audio_player.stop()
		
		timer.stop()
		
		# On rend invisible le panel de l'animation
		$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_animation_ouverture_conteneur.visible = false
		is_fast_opening = true
		
		
		get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_animation_ouverture_conteneur/pnl_info_unlocking_container/animation").stop()
		get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_animation_ouverture_conteneur/pnl_animation_principal/animation").stop()
		
		var style_box = get_node("%pnl_notification_buy").get_theme_stylebox("panel")
		style_box.bg_color = Global.leJoueur.inventaire[0].get_color()
		get_node("%pnl_notification_buy/AnimationPlayer").stop()
		get_node("%pnl_notification_buy/txtr_dollar").texture = load("res://resources/images/Box-106.png")
		get_node("%pnl_notification_buy/lbl_infos").text = "You got a " + Global.leJoueur.inventaire[0].get_quality() +" item !"
		get_node("%pnl_notification_buy/AnimationPlayer").play("notification_anim")
		
		
		if Global.leJoueur.inventaire[0] is SkinArmeObtenu:
			
			var anim_sound = load(Global.leJoueur.inventaire[0].skin.categorie.anim_drop_sound)
			
			# Vérifier que anim_sound n'est pas nul et est bien un AudioStream
			if anim_sound is AudioStreamMP3:
				var audio_player = $pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/pnl_principal/txtr_skin/drop_anim_sound
				audio_player.stream = anim_sound
				audio_player.play()
			
		elif Global.leJoueur.inventaire[0] is Sticker:
			
			var anim_sound = load(Global.leJoueur.inventaire[0].categorie.anim_drop_sound)
			
			# Vérifier que anim_sound n'est pas nul et est bien un AudioStream
			if anim_sound is AudioStreamMP3:
				var audio_player = $pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/pnl_principal/txtr_skin/drop_anim_sound
				audio_player.stream = anim_sound
				audio_player.play()

func _on_btn_ouverture_conteneur_pressed():
	
	var audio_player2 = $pnl_principal/pnl_inventaire/pnl_ouverture_caisse/btn_ouverture_conteneur/AudioStreamPlayer2D
	audio_player2.play()
	
	# Remet la valeur du fast opening à 0
	is_fast_opening = false
	# Ici on cache certain panel
	get_node("pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_inventaire").disabled = true
	get_node("pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_shop").disabled = true
	
	# On rend visible le panel de l'animation
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_animation_ouverture_conteneur.visible = false
	
	# On stop le timer, si il n'a pas été déja coupé
	timer.stop()
	
	# Fait en sorte que l'audio de l'animation d'ouverture/diffilement des skins sois joué
	var audio_anim = $pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_animation_ouverture_conteneur/pnl_animation_principal/audio_player
	audio_anim.play()
	
	# On récupère le conteneur qui est ouvert
	var item_container = $pnl_principal/pnl_inventaire/pnl_ouverture_caisse/btn_ouverture_conteneur.get_meta("container_data")
	
	# On met en variable le panel qui contient tout les panels des skins - animation d'ouverture genre ca contient aussi le panel 24 qui est l'objet final
	var panel_animation = get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_animation_ouverture_conteneur/pnl_animation_principal/pnl_principal/hbox")
	
	# Ici on regarde si la caisse a besoin d'une clé ou pas
	if item_container.need_key == true:
		# Si oui alors on récupère la clé
		var key = $pnl_principal/pnl_inventaire/pnl_ouverture_caisse/btn_ouverture_conteneur.get_meta("key_data")
		
		# On supprime la clé de l'inventaire et le conteneur
		Global.leJoueur.inventaire.erase(item_container)
		
		for item in Global.leJoueur.inventaire:
			if item is KeyConteneur:
				if item.id == item_container.id + "_key": 
					Global.leJoueur.inventaire.erase(item)
					break
		
	else:
		# Si non, on supprime juste la caisse
		Global.leJoueur.inventaire.erase(item_container)
	
	# On rend visible le panel de l'animation
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_animation_ouverture_conteneur.visible = true
	
	# On cache le bouton d'ouverture de la caisse
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/btn_ouverture_conteneur.visible = false
	
	# On lance l'animation qui fait aparaitre le label "unlocking" et l'animation qui fait défiler les panels des skins
	get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_animation_ouverture_conteneur/pnl_info_unlocking_container/animation").play("anim_bouton_spawn")
	get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_animation_ouverture_conteneur/pnl_animation_principal/animation").play("anim_ouverture_conteneur")
	
	# Déterminer les taux de drop à utiliser en fonction du type de caisse
	# Regarde si le type de la caisse est normal ou pas, choisi les taux de drops
	var drop_rates
	if item_container.type_caisse == "normal":
		drop_rates = Global.default_drop_rates
	else:
		drop_rates = item_container.drop_rates
	
	# On créer la variable qui contiendra l'item fianl qui est choisi
	item_choisi_final = null
	
	# Pour tout les panels de l'animation qui défile :
	for child in panel_animation.get_children():
		
		var randomNum = randf() * 100 # Permet de donner une valeur float entre 0 et 100 en rapport avec le taux de drop
		var cumulative_drop_rate = 0.0 # Permet de cumuler les taux de drops afin de voir quand, randomNum est >
		var category_finale = "" # Permet de stocker la qualité du skin qui est choisi
		var items_cat_choisi = [] # Stocke les skins de la catégorie choisi
		var item_choisi_string: String # Nom du skin en valeur string qui est choisi
		var item_choisi # Item choisi
		
		# Utilisation des taux de drop pour déterminer la catégorie
		for category in drop_rates.keys():
			cumulative_drop_rate += drop_rates[category]
			if randomNum <= cumulative_drop_rate:
				category_finale = category
				break
		if category_finale == "knive":
			category_finale = drop_rates.keys()[0]
		
		# Stocke les skins de la qualitée choisie dans une liste
		items_cat_choisi = get_skins_by_categories(item_container,category_finale)
		
		# Choisi un skin aléatoire parmis la liste des skins en string
		item_choisi_string = items_cat_choisi[randi_range(0,items_cat_choisi.size() - 1)]
		
		# Grace au string on peut retrouver l'objet - on choisi bien si c'est un skin ou un sticker
		if Global.skins.has(item_choisi_string):
			item_choisi = Global.skins[item_choisi_string]
		elif Global.stickers.has(item_choisi_string):
			item_choisi = Global.stickers[item_choisi_string]
		
		# On regarde si le panneau actuel est egal à "pnl_visualisation_skin24" car c'est l'item que recevra le joueur
		if child.name == "pnl_visualisation_skin24":
			
			# On met en variable le SkinArmeObtenu
			item_choisi = ouvrir_caisse_v2(item_container)
			# On sauvegarde l'item final choisi pour pouvoir y acceder en dehors du if actuel
			item_choisi_final = item_choisi
			
			# On insert l'item à l'index 0 de l'inventaire du joueur
			Global.leJoueur.inventaire.insert(0,item_choisi_final)
			
			if item_choisi is SkinArmeObtenu:
				# On regarde si le skin est un couteau ou pas, car si c'est un couteau il faut que le pannel soit de couleur
				# jaune avec l'image des items rare - tu connais
				# Sinon, on affiche juste les infos du skin quoi.
				if item_choisi.skin.categorie.nom == Global.categories['knive'].nom:
					child.get_node("pnl_infos_skin/lbl_nom_arme").text = Global.categories['knive'].nom
					child.get_node("pnl_infos_skin/lbl_nom_arme").autowrap_mode  = TextServer.AUTOWRAP_WORD
					child.get_node("pnl_infos_skin/lbl_nom_skin").text  = ""
					child.get_node("pnl_skin/txtr_skin").texture = load("res://resources/images/Csgo-default_rare_item.png")
					child.get_node("pnl_infos_skin/color_rect_etat_skin").color = "ffd700"
				else:
					child.get_node("pnl_skin/txtr_skin").texture = load(item_choisi.skin.image_path)
					child.get_node("pnl_infos_skin/color_rect_etat_skin").color = item_choisi.skin.categorie.color
					child.get_node("pnl_infos_skin/lbl_nom_skin").text = item_choisi.skin.nom
					
					# Fait en sorte d'afficher statrack ou souvenir au skin choisi
					if item_choisi.stat_track == true:
						child.get_node("pnl_infos_skin/lbl_nom_arme").text = "(StatTrack) " + item_choisi.skin.arme.nom
					elif item_choisi.souvenir == true:
						child.get_node("pnl_infos_skin/lbl_nom_arme").text = "(Souvenir) " + item_choisi.skin.arme.nom
					else:
						child.get_node("pnl_infos_skin/lbl_nom_arme").text = item_choisi.skin.arme.nom
			elif item_choisi is Sticker:
				
				child.get_node("pnl_skin/txtr_skin").texture = load(item_choisi.image_path)
				child.get_node("pnl_infos_skin/color_rect_etat_skin").color = item_choisi.categorie.color
				child.get_node("pnl_infos_skin/lbl_nom_arme").text = item_choisi.nom
				child.get_node("pnl_infos_skin/lbl_nom_skin").text  = "Sticker"
			
		# C'est ici qu'on affiche les infos des skins random
		else:
			
			if item_choisi is SkinArme:
				
				child.get_node("pnl_skin/txtr_skin").texture = load(item_choisi.image_path)
				child.get_node("pnl_infos_skin/color_rect_etat_skin").color = item_choisi.categorie.color
				child.get_node("pnl_infos_skin/lbl_nom_skin").text = item_choisi.nom
				
				# Fait en sorte d'afficher statrack ou souvenir aux skins random
				if item_container.type_caisse == "souvenir":
					child.get_node("pnl_infos_skin/lbl_nom_arme").text = "(Souvenir) " + item_choisi.arme.nom
				elif item_container.type_caisse == "collection":
					child.get_node("pnl_infos_skin/lbl_nom_arme").text = item_choisi.arme.nom
				else:
					var random = randf() * 100
					if random >= 90:
						child.get_node("pnl_infos_skin/lbl_nom_arme").text = "(StatTrack) " + item_choisi.arme.nom
					else:
						child.get_node("pnl_infos_skin/lbl_nom_arme").text = item_choisi.arme.nom
			elif item_choisi is Sticker:
				
				child.get_node("pnl_skin/txtr_skin").texture = load(item_choisi.image_path)
				child.get_node("pnl_infos_skin/color_rect_etat_skin").color = item_choisi.categorie.color
				
				child.get_node("pnl_infos_skin/lbl_nom_arme").text = item_choisi.nom
				child.get_node("pnl_infos_skin/lbl_nom_skin").text  = "Sticker"
	# On créer un timer, on lui donne un delta et ensuite on l'active. et on attend
	timer.wait_time = 2 # 2 secondes
	timer.one_shot = true
	
	timer.start()
	await timer.timeout
	$pnl_principal/pnl_inventaire/pnl_titre/btn_quitter_caisse_panel.visible = false
	
	timer.wait_time = 3 # 2 secondes
	timer.one_shot = true
	timer.start()
	# Attendre 2 secondes de manière asynchrone
	await timer.timeout
	
	if is_fast_opening == false:
		var anim_sound
		if item_choisi_final is SkinArmeObtenu:
			anim_sound = load(item_choisi_final.skin.categorie.anim_drop_sound)
		elif item_choisi_final is Sticker:
			anim_sound = load(item_choisi_final.categorie.anim_drop_sound)
		
		# Vérifier que anim_sound n'est pas nul et est bien un AudioStream
		if anim_sound is AudioStreamMP3:
			var audio_player = $pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/pnl_principal/txtr_skin/drop_anim_sound
			audio_player.stream = anim_sound
			audio_player.play()
		
		# Une fois le timer finis, on affiche le panel qui montre le skin obtenu
		$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_ombre_panneau_principal.visible = true
		$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand.visible = true
		
		
		# On lance l'animation qui change la position du skin, de haut en bas
		get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/pnl_principal/txtr_skin/AnimationPlayer").play("skin_animation")
		
		if item_choisi_final is SkinArmeObtenu:
			
			$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/pnl_principal/txtr_skin.texture = load(Global.leJoueur.inventaire[0].skin.image_path)
			$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/color_objet.color = Global.leJoueur.inventaire[0].skin.categorie.color
			$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/lbl_nom_item.text = Global.leJoueur.inventaire[0]._to_string()
			
				# Gère les stickers, si présents pour l'objet/skin, si il y en a on parcours la hbox qui contient 5 stickers,
			# pour chaque sticker on rend visible le sticker et on y met son image,sinon on les rends invisible
			if Global.leJoueur.inventaire[0].stickers5.size() == 0:
				for child in get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/pnl_principal/hbox_stickers").get_children():
					child.visible = false
			else:
				for j in range(Global.leJoueur.inventaire[0].stickers5.size()):
					var sticker_node = get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/pnl_principal/hbox_stickers/txtr_sticker%d" % (j + 1))
					sticker_node.texture = load(Global.leJoueur.inventaire[0].stickers5[j].image_path)
					get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/pnl_principal/hbox_stickers/txtr_sticker%d" % (j + 1)).visible = true
			
		elif item_choisi_final is Sticker:
			
			# Si jamais on a ouvert une caisse souvenir juste avant où il y a de base des stickers, cela permet de les cacher pour les stickers
			for child in get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/pnl_principal/hbox_stickers").get_children():
				child.visible = false
			
			$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/pnl_principal/txtr_skin.texture = load(Global.leJoueur.inventaire[0].image_path)
			$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/color_objet.color = Global.leJoueur.inventaire[0].categorie.color
			$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/lbl_nom_item.text = Global.leJoueur.inventaire[0]._to_string()


func _on_btn_continuer_pressed():
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_ombre_panneau_principal.visible = false
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand.visible = false
	get_node("pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_visualisation_new_skin_grand/pnl_principal/txtr_skin/AnimationPlayer").stop()
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse.visible = false
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_conteneur_no_key.visible = false
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_conteneur_with_key.visible = false
	$pnl_principal/pnl_inventaire/pnl_ouverture_caisse/pnl_animation_ouverture_conteneur.visible = false
	$pnl_principal/pnl_inventaire/pnl_inventaire_storage.visible = true
	$pnl_principal/pnl_inventaire/pnl_titre/btn_quitter_caisse_panel.visible = false
	repopulation_grille_inventaire_sans_retoruner_page_1(mode_selection_items_inventaire)
	
	get_node("pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_inventaire").disabled = false
	get_node("pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_shop").disabled = false


func _on_btn_close_panel_pressed():
	
	var audio_player = $pnl_inspect_skin_grand/btn_close_panel/AudioStreamPlayer2D
	audio_player.play()
	
	$pnl_inspect_skin_grand.visible = false
	$pnl_ombre_panneau_principal.visible = false


func _on_texture_rect_mouse_entered():
	
	var audio_player = $pnl_inspect_skin_grand/pnl_principal/TextureRect/AudioStreamPlayer2D
	audio_player.play()
	
	get_node("pnl_inspect_skin_grand/Panel").visible = true


func _on_texture_rect_mouse_exited():
	get_node("pnl_inspect_skin_grand/Panel").visible = false
	pass # Replace with function body.

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_on_quit()

func _on_quit():
	print("Le jeu est sur le point de se fermer. Sauvegarde des données...")
	JsonDataInventory.save_all()
	get_tree().quit()


func _on_animation_opening_container_started(anim_name):
	is_animation_playing = true


func _on_animation_opening_container_finished(anim_name):
	is_animation_playing = false
	
	


func _on_btn_add_sticker_pressed():
	
	get_node("pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_inventaire").disabled = true
	get_node("pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_shop").disabled = true
	
	var item = $pnl_choose_sticker.get_meta("item")
	
	clear_grid(get_node("pnl_choose_sticker/panel/ScrollContainer/MarginContainer/GridContainer"))
	get_node("pnl_choose_sticker/panel/ScrollContainer").set_v_scroll(0)
	
	for inv_item in Global.leJoueur.inventaire:
		if inv_item is Sticker:
			if !inv_item.favori:
				var new_panel_objet = Global.pnl_prefab_skin_arme.instantiate()
				
				var lalbel_principal_objet = new_panel_objet.get_node("pnl_infos_skin/lbl_nom_arme") # On récupère son label
				var label_secondaire_objet = new_panel_objet.get_node("pnl_infos_skin/lbl_nom_skin") # On récupère son label
				var image_objet = new_panel_objet.get_node("pnl_skin/txtr_skin") # On récupère son image
				var color_categorie_objet = new_panel_objet.get_node("pnl_infos_skin/color_rect_etat_skin")
				var btn_panel_objet = new_panel_objet.get_node("btn_skin")
				
				lalbel_principal_objet.text = inv_item.nom
				label_secondaire_objet.text = "Sticker"
				image_objet.texture = load(inv_item.image_path)
				color_categorie_objet.color = inv_item.categorie.color
				
				new_panel_objet.set_meta("sticker_data", inv_item)
				btn_panel_objet.pressed.connect(self._on_sticker_apply_button_pressed.bind(new_panel_objet))
				
				get_node("pnl_choose_sticker/panel/ScrollContainer/MarginContainer/GridContainer").add_child(new_panel_objet)
	
	get_node("pnl_choose_sticker").visible = true


func _on_button_pressed():
	
	get_node("pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_inventaire").disabled = false
	get_node("pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_shop").disabled = false
	
	get_node("pnl_choose_sticker").visible = false

func _on_sticker_apply_button_pressed(panel):
	
	var item = $pnl_choose_sticker.get_meta("item")
	var sticker_to_be_applied = panel.get_meta("sticker_data")
	
	get_node("pnl_confirmation").set_meta("sticker_data", sticker_to_be_applied)
	
	get_node("pnl_confirmation/panel/lbl_infos").text = "[center]You really wan to apply the sticker [b]'" + sticker_to_be_applied.nom + "'[/b] on your [b]'" + item._to_string() + "'[/b] ?[/center]"
	
	get_node("pnl_confirmation").visible = true


func _on_btn_confirmation_add_sticker_pressed():
	
	var item = $pnl_choose_sticker.get_meta("item")
	var sticker = $pnl_confirmation.get_meta("sticker_data")
	
	var new_item = item
	new_item.stickers5.append(sticker)
	
	Global.leJoueur.inventaire.erase(item)
	Global.leJoueur.inventaire.erase(sticker)
	Global.leJoueur.inventaire.insert(0,new_item)
	
	get_node("pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_inventaire").disabled = false
	get_node("pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_shop").disabled = false
	
	get_node("pnl_confirmation").visible = false
	get_node("pnl_choose_sticker").visible = false
	get_node("pnl_ombre_panneau_principal").visible = false
	get_node("pnl_inspect_skin_grand").visible = false
	
	repopulation_grille_inventaire_sans_retoruner_page_1(mode_selection_items_inventaire)
	


func _on_btn_cancel_add_sticker_pressed():
	get_node("pnl_confirmation").visible = false


func _on_btn_item_fav_pressed():
	var item = $pnl_choose_sticker.get_meta("item")
	
	if item is SkinArmeObtenu or item is Sticker:
		
		if item.favori:
			get_node("pnl_inspect_skin_grand/pnl_principal/txtr_favori").texture = load("res://resources/images/etoile (2).png")
			item.favori = false
		elif !item.favori:
			get_node("pnl_inspect_skin_grand/pnl_principal/txtr_favori").texture = load("res://resources/images/etoile (3).png")
			item.favori = true
	
	repopulation_grille_inventaire_sans_retoruner_page_1(mode_selection_items_inventaire)


# Quand le bouton de vente du multi sell mode est préssé
func _on_btn_multi_sell_pressed():
	
	if mode_selection_items_inventaire_old != mode_selection_items_inventaire and "non_favoris" not in mode_selection_items_inventaire:
		mode_selection_items_inventaire_old = mode_selection_items_inventaire
	
	
	var mode_selection_items_inventaire_temp
	
	# Regarde si le le mode multi sell est activé ou pas
	if multi_sell_mode == false:
		
		$pnl_principal/pnl_inventaire/pnl_inventaire_storage/HBoxContainer/btn_filters.visible = false
		$pnl_principal/pnl_inventaire/pnl_inventaire_storage/HBoxContainer/btn_multi_sell_sell_all_blue.visible = true
		
		# On met le mode multi sell a true
		multi_sell_mode = true
		
		# Disable des boutons principaux
		get_node("pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_inventaire").disabled = true
		get_node("pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_shop").disabled = true
		
		# Met le mode de sélection des skins uniquement pour l'inventaire
		mode_selection_items_inventaire = mode_selection_items_inventaire + "_non_favoris"
		
		# Affiche le bouton de confirmation
		$pnl_principal/pnl_inventaire/pnl_inventaire_storage/btn_sell_confirmation.visible = true
		
		# Créer une notification avec toutes les infos qu'il faut
		var style_box = get_node("%pnl_notification_buy").get_theme_stylebox("panel")
		style_box.bg_color = "30ac1f"
		get_node("%pnl_notification_buy/AnimationPlayer").stop()
		get_node("%pnl_notification_buy/txtr_dollar").texture = load("res://resources/images/Information_grey.svg.png")
		get_node("%pnl_notification_buy/lbl_infos").text = "Multi sell mode is active !"
		get_node("%pnl_notification_buy/AnimationPlayer").play("notification_anim")
		
	elif multi_sell_mode == true:
		
		$pnl_principal/pnl_inventaire/pnl_inventaire_storage/HBoxContainer/btn_filters.visible = true
		$pnl_principal/pnl_inventaire/pnl_inventaire_storage/HBoxContainer/btn_multi_sell_sell_all_blue.visible = false
		
		# On met le mode multi sell a false
		multi_sell_mode = false
		
		# Enleve le disable des boutons principaux
		get_node("pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_inventaire").disabled = false
		get_node("pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_shop").disabled = false
		
		# Remet le mode de sélection des items par défaut pour l'inventaire
		mode_selection_items_inventaire = mode_selection_items_inventaire_old
		
		# Cache le bouton de confirmation
		$pnl_principal/pnl_inventaire/pnl_inventaire_storage/btn_sell_confirmation.visible = false
		
		# Créer une notification avec toutes les infos qu'il faut
		var style_box = get_node("%pnl_notification_buy").get_theme_stylebox("panel")
		style_box.bg_color = "ac1f1f"
		get_node("%pnl_notification_buy/AnimationPlayer").stop()
		get_node("%pnl_notification_buy/txtr_dollar").texture = load("res://resources/images/Information_grey.svg.png")
		get_node("%pnl_notification_buy/lbl_infos").text = "Multi sell mode is unactive !"
		get_node("%pnl_notification_buy/AnimationPlayer").play("notification_anim")
		
		# Parcours tout les items sélec et on fait en sorte de ne plus les marquer comme en vente
		for item in items_selected_multi_sell_mode:
			item.set_sell_selected(false)
		# Remet la liste vide
		items_selected_multi_sell_mode = []
	
	# Repopule la grid de l'inventaire avec les items de l'inventaire du joueur
	populate_grid_skin($pnl_principal/pnl_inventaire/pnl_inventaire_storage/MarginContainer/GridContainer, 0, mode_selection_items_inventaire)
	# Remet l'index du skin à charger dans l'inventaire, ici 0 car on veux revenir au début
	index_skin_a_charger_debut = 0
	# Remet la varible de la page actuelle à 0
	page_actuelle = 1
	# Actualise la page affichée dans l'inventaire
	changer_valeur_page_actuelle_storage()
	
	lbl_nombre_items_inventaire.text = str(items_to_show_inventaire.size())


# Qaund le bouton de confirmation du multi sell mode est préssé
func _on_btn_sell_confirmation_pressed():
	
	$pnl_principal/pnl_inventaire/pnl_inventaire_storage/HBoxContainer/btn_filters.visible = true
	$pnl_principal/pnl_inventaire/pnl_inventaire_storage/HBoxContainer/btn_multi_sell_sell_all_blue.visible = false
	
	# nbre total d'items à delete
	var nb_items_deleted = items_selected_multi_sell_mode.size()
	# MOntant total de la vente
	var montant_vente = 0
	
	# Pour chaque item sélectionné on compt ele montant total, on ajoute l'argent au joueur et on supprime l'item de l'inventaire
	for item in items_selected_multi_sell_mode:
		montant_vente += item. get_price()
		Global.leJoueur.money += item.get_price()
		Global.leJoueur.inventaire.erase(item)
	
	items_selected_multi_sell_mode = []
	
	# Enleve le mode multi sell
	multi_sell_mode = false
	
	# Enleve le disable des boutons principaux
	get_node("pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_inventaire").disabled = false
	get_node("pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_shop").disabled = false
	
	# Remet le mode de sélection des items par défaut pour l'inventaire
	mode_selection_items_inventaire = mode_selection_items_inventaire_old
	
	# Cache le bouton de confirmation
	$pnl_principal/pnl_inventaire/pnl_inventaire_storage/btn_sell_confirmation.visible = false
	
	# Créer une notification avec toutes les infos qu'il faut
	var style_box = get_node("%pnl_notification_buy").get_theme_stylebox("panel")
	style_box.bg_color = "ac1f1f"
	get_node("%pnl_notification_buy/AnimationPlayer").stop()
	get_node("%pnl_notification_buy/txtr_dollar").texture = load("res://resources/images/Information_grey.svg.png")
	get_node("%pnl_notification_buy/lbl_infos").text = "You sold " + str(nb_items_deleted) + " items, for a total cost of : $" + str(montant_vente)
	get_node("%pnl_notification_buy/AnimationPlayer").play("notification_anim")
	
	# Repopule la grid de l'inventaire avec les items de l'inventaire du joueur
	populate_grid_skin($pnl_principal/pnl_inventaire/pnl_inventaire_storage/MarginContainer/GridContainer, 0, mode_selection_items_inventaire)	
	
	# Remet l'index du skin à charger dans l'inventaire, ici 0 car on veux revenir au début
	index_skin_a_charger_debut = 0
	# Remet la varible de la page actuelle à 0
	page_actuelle = 1
	# Actualise la page affichée dans l'inventaire
	changer_valeur_page_actuelle_storage()
	
	# Met à jour le nombre d'items dans l'inventaire
	lbl_nombre_items_inventaire.text = str(items_to_show_inventaire.size())
	# Met à jour la valeur totale de l'inventaire
	$pnl_principal/pnl_inventaire/pnl_inventaire_storage/pnl_prix_inventaire/lbl_prix.text = str(snapped(Global.leJoueur.get_value_inventory(),0.01))
	# Disable le bouton de confirmation
	$pnl_principal/pnl_inventaire/pnl_inventaire_storage/btn_sell_confirmation.disabled = true
	# Remet le nbr d'item selec à 0
	$pnl_principal/pnl_inventaire/pnl_inventaire_storage/btn_sell_confirmation/Panel/HBoxContainer/lbl_nombre_items.text = "0"


func _on_btn_filters_pressed():
	
	# Disable des boutons principaux
	get_node("pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_inventaire").disabled = true
	get_node("pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_shop").disabled = true
	
	$pnl_principal/pnl_inventaire/pnl_inventaire_storage/pnl_filter.visible = true


func _on_btn_filters_confirmation_pressed():
	
	var option_button: OptionButton = get_node("pnl_principal/pnl_inventaire/pnl_inventaire_storage/pnl_filter/Panel/VBoxContainer/OptionButton")
	
	if option_button.get_selected_id() == 0:
		mode_selection_items_inventaire = "default"
	elif option_button.get_selected_id() == 1:
		mode_selection_items_inventaire = "containers"
	elif option_button.get_selected_id() == 2:
		mode_selection_items_inventaire = "skins"
	elif option_button.get_selected_id() == 3:
		mode_selection_items_inventaire = "stickers"
	elif option_button.get_selected_id() == 4:
		mode_selection_items_inventaire = "favoris"
	
	
	# Disable des boutons principaux
	get_node("pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_inventaire").disabled = false
	get_node("pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_shop").disabled = false
	
	$pnl_principal/pnl_inventaire/pnl_inventaire_storage/pnl_filter.visible = false
	
	# Repopule la grid de l'inventaire avec les items de l'inventaire du joueur
	populate_grid_skin($pnl_principal/pnl_inventaire/pnl_inventaire_storage/MarginContainer/GridContainer, 0, mode_selection_items_inventaire)	
	
	# Remet l'index du skin à charger dans l'inventaire, ici 0 car on veux revenir au début
	index_skin_a_charger_debut = 0
	# Remet la varible de la page actuelle à 0
	page_actuelle = 1
	# Actualise la page affichée dans l'inventaire
	changer_valeur_page_actuelle_storage()
	# Met à jour le nombre d'items dans l'inventaire
	lbl_nombre_items_inventaire.text = str(items_to_show_inventaire.size())



func _on_btn_multi_sell_sell_all_blue_pressed() -> void:
	var item_selected
	var total_skins = Global.leJoueur.inventaire.size()
	var index = 0
	for i in range(total_skins):  
		index = index_skin_a_charger_debut + i
		if index >= total_skins:
			break # Sort de la boucle si on dépasse la taille de l'inventaire
		
		item_selected = Global.leJoueur.inventaire[index]
		
		if !item_selected.favori:
			
			if item_selected is SkinArmeObtenu:
				if item_selected.skin.categorie.nom == "Mil-Spec":
					
					# Regarde si le bouton préssé est déjà noté comme en vente
					if item_selected.sell_selected == false:
						
						# Set le mode vente à true
						item_selected.set_sell_selected(true)
						# Ajoute l'item à la liste des items à vendre
						items_selected_multi_sell_mode.append(item_selected)
		
		
		
	# Repopule la grille avec le mode de sélection des skins seulement 'mode_selection_items_inventaire'
	repopulation_grille_inventaire_sans_retoruner_page_1(mode_selection_items_inventaire)
	# Actualise le label contenant la size de la liste des items à vendre
	$pnl_principal/pnl_inventaire/pnl_inventaire_storage/btn_sell_confirmation/Panel/HBoxContainer/lbl_nombre_items.text = str(items_selected_multi_sell_mode.size())
	
	# Si il y a un item dans la liste des skins à vendre, le bouton n'est plus disable sinon il est disable
	if items_selected_multi_sell_mode.size() > 0:
		$pnl_principal/pnl_inventaire/pnl_inventaire_storage/btn_sell_confirmation.disabled = false
	if items_selected_multi_sell_mode.size() == 0:
		$pnl_principal/pnl_inventaire/pnl_inventaire_storage/btn_sell_confirmation.disabled = true
