extends Panel

var type_container_show

func clear_grid(grid):
	for child in grid.get_children(): # On itère sur tous les enfants du nœud `grid`
		grid.remove_child(child) # On supprime l'enfant de la grille
		child.queue_free() # On marque l'enfant pour destruction lors du prochain cycle

func _on_btn_shop_pressed():
	
	var audio_player2 = $%pnl_principal/pnl_menu_principal/pnl_menu_principal/btn_shop/AudioStreamPlayer2D
	audio_player2.play()
	
	get_node("%pnl_principal/pnl_inventaire").visible = false
	get_node("%pnl_principal/pnl_shop").visible = true
	load_scroll_panel_container("normal")
	get_node("%pnl_principal/pnl_shop/pnl_principal/pnl_containers_scroll/hbox_filters/ledit_filtre").text = ""

## Remplis la liste des conteneurs dans le shop
func load_scroll_panel_container(type_container: String, filter_string: String = ""):
	var items_filters
	clear_grid($%pnl_principal/pnl_shop/pnl_principal/pnl_containers_scroll/scroll/marg/vbox_containers)
	## Stock tout les containers du type que l'on veux
	var type_wanted_containers : Array
	
	
	type_container_show = type_container
	## On parcours toutes les caisses
	for i in Global.conteneurs:
		
		## On met en variable le container de l'itération actuelle
		var container = Global.conteneurs[i]
		
		## On regarde si le container actuel est du type que l'on veux
		if container.type_caisse == type_container:
			
			if filter_string == "" or container.nom.to_lower().find(filter_string.to_lower()) != -1:
				## On ajoute le container à la liste des containers voulu
				type_wanted_containers.append(container)
	
	## On va ajouter un panel pour chaque conteneur de la liste
	for container in type_wanted_containers:
		
		## On instancie tout les elements qu'on modifie par panel du container
		var new_panel_container = Global.prefab_container_buy_scene.instantiate()
		var txtr_container_image = new_panel_container.get_node("txtr_container_image")
		var txtr_collection_image = new_panel_container.get_node("clr_rect_background/txtr_collection_image")
		var lbl_container_name = new_panel_container.get_node("lbl_name_container")
		var lbl_container_infos = new_panel_container.get_node("lbl_infos_container")
		
		var btn_buy_panel_container = new_panel_container.get_node("btn_buy_container")
		var btn_minus_panel_container = new_panel_container.get_node("pnl_quantity_container/btn_minus")
		var btn_plus_panel_container = new_panel_container.get_node("pnl_quantity_container/btn_plusus")
		
		## On instancie tout les elements qu'on modifie par panel de la clé
		var lbl_name_key = new_panel_container.get_node("pnl_key_container/lbl_name_key")
		var lbl_infos_key = new_panel_container.get_node("pnl_key_container/lbl_infos_key")
		var lbl_infos_no_key = new_panel_container.get_node("pnl_key_container/lbl_infos_no_key")
		var pnl_quantity_key = new_panel_container.get_node("pnl_key_container/pnl_quantity_key")
		var txtr_key_image = new_panel_container.get_node("pnl_key_container/txtr_key_image")
		
		var btn_buy_key = new_panel_container.get_node("pnl_key_container/btn_buy_key")
		var btn_plus_key = new_panel_container.get_node("pnl_key_container/pnl_quantity_key/btn_plusus_key")
		var btn_minus_key = new_panel_container.get_node("pnl_key_container/pnl_quantity_key/btn_minus_key")
		
		
		## On modifie les elements - Ici on charge les infos de la caisse - panel de gauche
		## Qui est similaire pour toutes les caisses
		txtr_container_image.texture = load(container.image_path)
		txtr_collection_image.texture = load(container.image_collection_path)
		lbl_container_name.text = container.nom
		btn_buy_panel_container.text = "$" + str(container.prix)
		
		## On regarde si on a besoin d'afficher la clé du container ou pas
		if container.need_key == true:
			var key_container = Global.keys_conteneurs[container.id + "_key"]
			new_panel_container.set_meta("key",key_container)
			new_panel_container.set_meta("nbr_key",1)
			lbl_name_key.text = key_container.nom
			txtr_key_image.texture = load(key_container.image_path)
			btn_buy_key.text = "$" + str(key_container.prix)
		else:
			lbl_name_key.visible = false
			lbl_infos_key.visible = false
			pnl_quantity_key.visible = false
			btn_buy_key.visible = false
			txtr_key_image.visible = false
			lbl_infos_no_key.visible = true
			pass
		
		## On transmet l'item caisse et le nbr de containers a acheter au panel
		new_panel_container.set_meta("container",container)
		new_panel_container.set_meta("nbr_container",1)
		
		# Connecter le signal "pressed" du bouton à une fonction de gestion
		btn_buy_panel_container.pressed.connect(self._on_buy_container_scroll_button_pressed.bind(new_panel_container))
		btn_minus_panel_container.pressed.connect(self._on_minus_container_scroll_button_pressed.bind(new_panel_container))
		btn_plus_panel_container.pressed.connect(self._on_plus_container_scroll_button_pressed.bind(new_panel_container))
		
		btn_buy_key.pressed.connect(self._on_buy_key_container_scroll_button_pressed.bind(new_panel_container))
		btn_minus_key.pressed.connect(self._on_minus_key_container_scroll_button_pressed.bind(new_panel_container))
		btn_plus_key.pressed.connect(self._on_plus_key_container_scroll_button_pressed.bind(new_panel_container))
		
		$%pnl_principal/pnl_shop/pnl_principal/pnl_containers_scroll/scroll/marg/vbox_containers.add_child(new_panel_container)






func _on_buy_container_scroll_button_pressed(panel):
	
	var container = panel.get_meta("container")
	var nbr_container = panel.get_meta("nbr_container")
	var value  = 0
	
	for i in range(nbr_container):
		value += container.prix
	
	if value <=  Global.leJoueur.money:
		Global.leJoueur.money -= value
		
		for i in range(nbr_container):
			Global.leJoueur.inventaire.insert(0,container)
		
		var style_box = get_node("%pnl_notification_buy").get_theme_stylebox("panel")
		style_box.bg_color = Color("#bcbcbc52")
		get_node("%pnl_notification_buy/AnimationPlayer").stop()
		get_node("%pnl_notification_buy/txtr_dollar").texture = load("res://resources/images/Cash-134.png")
		get_node("%pnl_notification_buy/lbl_infos").text = "$" + str(value) + " was withdrawn from your wallet."
		get_node("%pnl_notification_buy/AnimationPlayer").play("notification_anim")
	else:
		var style_box = get_node("%pnl_notification_buy").get_theme_stylebox("panel")
		style_box.bg_color = Color("#bcbcbc52")
		get_node("%pnl_notification_buy/txtr_dollar").texture = load("res://resources/images/Cash-134.png")
		get_node("%pnl_notification_buy/AnimationPlayer").stop()
		get_node("%pnl_notification_buy/lbl_infos").text = "You don't have enough to buy this!"
		get_node("%pnl_notification_buy/AnimationPlayer").play("notification_anim")


func _on_minus_container_scroll_button_pressed(panel):
	var container = panel.get_meta("container")
	var nbr_caisse = panel.get_meta("nbr_container")
	
	if nbr_caisse > 1:
		nbr_caisse -= 1
		panel.get_node("pnl_quantity_container/lbl_quantity").text = "QTY " + str(nbr_caisse)
		panel.get_node("btn_buy_container").text = "$" + str(container.prix * nbr_caisse)
		panel.set_meta("nbr_container",nbr_caisse)

func _on_plus_container_scroll_button_pressed(panel):
	
	var container = panel.get_meta("container")
	var nbr_caisse = panel.get_meta("nbr_container")
	
	nbr_caisse += 1
	panel.get_node("pnl_quantity_container/lbl_quantity").text = "QTY " + str(nbr_caisse)
	panel.get_node("btn_buy_container").text = "$" + str(container.prix * nbr_caisse)
	panel.set_meta("nbr_container",nbr_caisse)
 


func _on_buy_key_container_scroll_button_pressed(panel):
	
	var key = panel.get_meta("key")
	var nbr_key = panel.get_meta("nbr_key")
	var value  = 0
	
	for i in range(nbr_key):
		value += key.prix
	
	if value <=  Global.leJoueur.money:
		Global.leJoueur.money -= value
		
		for i in range(nbr_key):
			Global.leJoueur.inventaire.insert(0,key)
		
		var style_box = get_node("%pnl_notification_buy").get_theme_stylebox("panel")
		style_box.bg_color = Color("#bcbcbc52")
		get_node("%pnl_notification_buy/txtr_dollar").texture = load("res://resources/images/Cash-134.png")
		get_node("%pnl_notification_buy/AnimationPlayer").stop()
		get_node("%pnl_notification_buy/lbl_infos").text = "$" + str(value) + " was withdrawn from your wallet."
		get_node("%pnl_notification_buy/AnimationPlayer").play("notification_anim")
	else:
		var style_box = get_node("%pnl_notification_buy").get_theme_stylebox("panel")
		style_box.bg_color = Color("#bcbcbc52")
		get_node("%pnl_notification_buy/txtr_dollar").texture = load("res://resources/images/Cash-134.png")
		get_node("%pnl_notification_buy/AnimationPlayer").stop()
		get_node("%pnl_notification_buy/lbl_infos").text = "You don't have enough to buy this!"
		get_node("%pnl_notification_buy/AnimationPlayer").play("notification_anim")


func _on_minus_key_container_scroll_button_pressed(panel):
	var key = panel.get_meta("key")
	var nbr_key = panel.get_meta("nbr_key")
	
	if nbr_key > 1:
		nbr_key -= 1
		panel.get_node("pnl_key_container/pnl_quantity_key/lbl_quantity").text = "QTY " + str(nbr_key)
		panel.get_node("pnl_key_container/btn_buy_key").text = "$" + str(key.prix * nbr_key)
		panel.set_meta("nbr_key",nbr_key)

func _on_plus_key_container_scroll_button_pressed(panel):
	var key = panel.get_meta("key")
	var nbr_key = panel.get_meta("nbr_key")
	
	
	nbr_key += 1
	panel.get_node("pnl_key_container/pnl_quantity_key/lbl_quantity").text = "QTY " + str(nbr_key)
	panel.get_node("pnl_key_container/btn_buy_key").text = "$" + str(key.prix * nbr_key)
	panel.set_meta("nbr_key",nbr_key)


func _on_btn_shop_collection_container_pressed():
	load_scroll_panel_container("collection")
	get_node("%pnl_principal/pnl_shop/pnl_principal/pnl_containers_scroll/hbox_filters/ledit_filtre").text = ""


func _on_btn_shop_normal_container_pressed():
	load_scroll_panel_container("normal")
	get_node("%pnl_principal/pnl_shop/pnl_principal/pnl_containers_scroll/hbox_filters/ledit_filtre").text = ""

func _on_btn_shop_souvenir_container_2_pressed():
	load_scroll_panel_container("souvenir")
	get_node("%pnl_principal/pnl_shop/pnl_principal/pnl_containers_scroll/hbox_filters/ledit_filtre").text = ""



func _on_btn_filter_pressed():

	var string_filtre = $%pnl_principal/pnl_shop/pnl_principal/pnl_containers_scroll/hbox_filters/ledit_filtre.get_text()
	load_scroll_panel_container(type_container_show,string_filtre)
	
	pass # Replace with function body.


func _on_btn_capsule_container_pressed():
	load_scroll_panel_container("capsule")
	get_node("%pnl_principal/pnl_shop/pnl_principal/pnl_containers_scroll/hbox_filters/ledit_filtre").text = ""
