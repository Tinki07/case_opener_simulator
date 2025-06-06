extends Node

var json_inventoy_data = {}
var json_file_path = "user://inventaire.json"

var inventory_data = {
		"inventaire": {
			"items": []
		}
	}

func load_player_inventory(file_path: String):
	if FileAccess.file_exists(file_path):
		var data_file = FileAccess.open(file_path,FileAccess.READ)
		
		if data_file:
			var parsed_result = JSON.parse_string(data_file.get_as_text())
			if parsed_result is Dictionary:
				
				var data = parsed_result["inventaire"]["items"]
				for skin_data in data:
					
					if skin_data['type_item'] == "skin":
						var new_skin = SkinArmeObtenu.new(
							Global.skins[skin_data['skin_arme_id']],
							Global.etats_skins_normaux[skin_data['etat_id']],
							skin_data['stat_track'],
							skin_data['souvenir'],
						)
						new_skin.prix = skin_data['prix']
						new_skin.favori = skin_data['favori']
						
						for sticker_id in skin_data['stickers']:
							new_skin.stickers5.append(Global.stickers[sticker_id])
						Global.leJoueur.inventaire.append(new_skin)
						
					elif skin_data['type_item'] == "sticker":
						var le_sticker = Global.stickers[skin_data['sticker_id']]
						var new_sticker = Sticker.new(
								le_sticker.nom,
								le_sticker.id,
								le_sticker.equipe,
								le_sticker.categorie,
								le_sticker.type,
								le_sticker.image_path,
								le_sticker.prix
						)
						new_sticker.favori = skin_data['favori']
						Global.leJoueur.inventaire.append(new_sticker)
						
					elif skin_data['type_item'] == "container":
						var container = Global.conteneurs[skin_data['container_id']]
						var new_container
						if container.type_caisse == "normal":
							new_container = Conteneur.new(
								container.nom,
								container.id,
								container.image_path,
								container.image_collection_path,
								container.type_caisse,
								container.prix,
								container.need_key,
								container.objets_dropable
							)
							
						elif container.type_caisse == "collection":
							new_container = Conteneur.new(
								container.nom,
								container.id,
								container.image_path,
								container.image_collection_path,
								container.type_caisse,
								container.prix,
								container.need_key,
								container.objets_dropable,
								container.drop_rates
							)
							
						elif container.type_caisse == "souvenir":
							new_container = Conteneur.new(
								container.nom,
								container.id,
								container.image_path,
								container.image_collection_path,
								container.type_caisse,
								container.prix,
								container.need_key,
								container.objets_dropable,
								container.drop_rates
							)
							new_container.souvenir_stickers = container.souvenir_stickers
							
						elif container.type_caisse == "capsule":
							new_container = Conteneur.new(
								container.nom,
								container.id,
								container.image_path,
								container.image_collection_path,
								container.type_caisse,
								container.prix,
								container.need_key,
								container.objets_dropable,
								container.drop_rates
							)
						Global.leJoueur.inventaire.append(new_container)
					
					elif skin_data['type_item'] == "key":
						
						var key = Global.keys_conteneurs[skin_data['key_id']]
						var new_key = KeyConteneur.new(
							key.nom,
							key.id,
							key.image_path,
							key.conteneur_unlocker,
							key.prix
						)
						Global.leJoueur.inventaire.append(new_key)
					
			else:
				print("Error: Missing data fields in JSON.")
		else:
			print("Error: Could not open file for reading.")
	else:
		print("Error: File does not exist.")

func save_player_inventory(file_path: String):
	var write_file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if write_file:
		var json_string_player_inventory = JSON.stringify(set_player_inventory_string())
		if json_string_player_inventory:
			write_file.store_string(json_string_player_inventory)
			write_file.close()
		else:
			print("Error: Failed to stringify player inventory.")
	else:
		print("Error: Could not open file for writing.")


func set_player_inventory_string():
	
	for item in Global.leJoueur.inventaire:
		
		if item is SkinArmeObtenu:
			var item_string = {
				"type_item": "skin",
				"skin_arme_id": item.skin.id,
				"etat_id": item.etat.id,
				"stat_track": item.stat_track,
				"souvenir": item.souvenir,
				"prix": item.prix,
				"stickers" : [],
				"favori" : item.favori
			}
			for sticker in item.stickers5:
				item_string["stickers"].append(sticker.id)
			inventory_data["inventaire"]["items"].append(item_string)
		elif item is Sticker:
			var item_string = {
				"type_item": "sticker",
				"sticker_id": item.id,
				"favori" : item.favori
			}
			inventory_data["inventaire"]["items"].append(item_string)
		elif item is Conteneur:
			var item_string = {
				"type_item": "container",
				"container_id": item.id
			}
			inventory_data["inventaire"]["items"].append(item_string)
		elif item is KeyConteneur:
			var item_string = {
				"type_item": "key",
				"key_id": item.id
			}
			inventory_data["inventaire"]["items"].append(item_string)
		else:
			print("Error: Item in inventory is not of type SkinArmeObtenu.")
			
	return inventory_data



func save_all():
	save_player_inventory(json_file_path)

func load_all():
	load_player_inventory(json_file_path)
