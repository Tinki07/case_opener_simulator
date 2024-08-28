extends Node

class_name SkinArmeObtenu

var skin: SkinArme
var etat: EtatSkin
var stat_track: bool
var souvenir: bool
var prix: float
var stickers5: Array

func _init(skin,etat,stat_track,souvenir):
	self.skin = skin
	self.etat = etat
	self.stat_track = stat_track
	self.souvenir = souvenir

func _to_string():
	var string_stattrack_souvenir
	var string_final
	
	if stat_track == true:
		string_stattrack_souvenir = " (StatTrak™) "
	elif souvenir == true:
		string_stattrack_souvenir = " (Souvenir) "
	else:
		string_stattrack_souvenir = " "
	
	string_final = skin.arme.nom + string_stattrack_souvenir + "| " + skin.nom + " - " + etat.nom + " - " + str(self.prix) + "$"  
	return string_final

func _to_string_arme():
	var string_stattrack_souvenir
	var string_final
	
	if stat_track == true:
		string_stattrack_souvenir = "StatTrak™ "
	elif souvenir == true:
		string_stattrack_souvenir = "Souvenir "
	else:
		string_stattrack_souvenir = ""
	
	string_final = string_stattrack_souvenir + skin.arme.nom
	return string_final
	
func _add_one_sticker(sticker: Sticker):
	if stickers5.size() <= 5:
		stickers5.append(sticker)
	else:
		print("trop de stickers ! déja ",stickers5.size(), " stickers")

func _add_array_sticker(lesStickers: Array,liste_tout_les_stickers: Dictionary):
	if stickers5.size() <= 5:
		lesStickers.shuffle()
		for sticker in lesStickers:
			stickers5.append(liste_tout_les_stickers[sticker])
	else:
		print("trop de stickers ! déja ",stickers5.size(), " stickers")

func _stickers_to_string():
	print("---------------")
	for sticker in stickers5:
		if sticker != null:
			print(sticker.nom, " ", str(stickers5.size()))
	print("---------------")
