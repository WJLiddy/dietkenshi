extends Control


# Declare member variables here. Examples:
var charcreate = false

var fem = true

var race = "hiver"

var hair = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	showonly("-")

func showonly(name):
	for v in get_node("../char_sel").get_children():
		v.visible = name in v.name
		if(name == "uc" or name == "shrek" or name == "vaper"):
			if(!fem and "gf" in v.name):
				v.visible = false
			if(fem and "gm" in v.name):
				v.visible = false
	race = name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_node("Title").visible = !charcreate
	get_node("New").visible = charcreate
	get_node("../char_sel").global_rotate(Vector3(0,1,0),delta)

	for v in get_node("../char_sel").get_children():
		v.setParams(get_node("New/tall").value,get_node("New/thick").value,get_node("New/leg").value,get_node("New/scene").value,hair)

func _on_NEW_pressed():
	charcreate = true
	showonly("hive")
	pass # Replace with function body.

func _on_CONT_pressed():
	get_tree().change_scene("res://InGame.tscn")
	pass # Replace with function body.

func _on_VAPER_pressed():
	showonly("vaper")
	pass # Replace with function body.

func _on_SHREK_pressed():
	showonly("shrek")
	pass # Replace with function body.

func _on_HEAD_HUNTER_pressed():
	showonly("skeleton")
	pass # Replace with function body.

func _on_SHEEPLE_pressed():
	showonly("hive")
	pass # Replace with function body.

func _on_UC_pressed():
	showonly("uc")
	pass # Replace with function body.

func _on_startnewgame_pressed():
	if(race == "vaper" or race == "uc" or race == "shrek"):
		if(fem):
			race += "_gf"
		else:
			race += "_gm"

	var chrdata = {
		"tall": get_node("New/tall").value,
		"thick": get_node("New/thick").value,
		"leg": get_node("New/leg").value,
		"scene": get_node("New/scene").value,
		"hair": hair,
		"basemodel": race,
		"faction": "player",
		"charname": get_node("New/charname").text.substr(0,min(8,len(get_node("New/charname").text)))
	}
	AppState.new_game_protag_data = chrdata
	get_tree().change_scene("res://InGame.tscn")


func _on_CHGEN_pressed():
	fem = !fem
	showonly(race)

func _on_HBASSDROP_pressed():
	hair = "bassdrop"
	pass # Replace with function body.


func _on_HBUZZSAW_pressed():
	hair = "buzzsaw"
	pass # Replace with function body.


func _on_HPOMP_pressed():
	hair = "pompadorable"
	pass # Replace with function body.


func _on_HSLIMJIM_pressed():
	hair = "slim_jim"
	pass # Replace with function body.


func _on_HAPEX_pressed():
	hair = "the_apex"
	pass # Replace with function body.


func _on_HCUBES_pressed():
	hair = "hair_cubes"
	pass # Replace with function body.


func _on_H5DOLLAR_pressed():
	hair = "five_dollar_milkshake"
	pass # Replace with function body.


func _on_HFANTANO_pressed():
	hair = ""
	pass # Replace with function body.


func _on_HDUELIST_pressed():
	hair = "the_duelist"
	pass # Replace with function body.


func _on_HSPIKEY_pressed():
	hair = "spikey"
