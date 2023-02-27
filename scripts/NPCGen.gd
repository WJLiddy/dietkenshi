extends Node

# five cities. each have a population.


# Declare member variables here. Examples:
# var a = 2
onready var kenshiactor = preload("res://KenshitActor.tscn")
onready var actors = get_node("../Actors")

var current_quest = null
var current_quest_time = 0

var current_track = ""

func randhair():
	return ["bassdrop","buzzsaw","five_dollar_milkshake","hair_cubes","pompadorable","slim_jim","spikey","the_apex","the_duelist","fantano"][randi() % 10]

func get_quest():
	if(current_quest_time < 0):
		current_quest_time = rand_range(5,15)
		current_quest = Vector3(rand_range(200,1500),0,rand_range(200,1500))
		if(rand_range(0.0,1.0) > 0.3):
			# raid a city
			current_quest = self.get_children()[randi() % 5].global_transform.origin
	return current_quest

func _process(delta):
	current_quest_time -= delta

func beakneckgenerate(x,z):
	var pdata = {}
	pdata["x"] = x + rand_range(-50,50)
	pdata["z"] = z + rand_range(-50,50)
	pdata["faction"] = "animal"
	get_node("../Actors").spawnPlayer(pdata,true)

# tier 1 to 5
func npcgenerate(team, tier,x, z, recruitable, shopkeep):
	var pdata = {}
	var bmod = team
	if(team == "uc" or team == "shrek" or team == "vaper"):
		if(int(rand_range(0,2)) == 0):
			bmod += "_gf"
		else:
			bmod += "_gm"
	
	pdata["basemodel"] = bmod
	
	pdata["faction"] = team
	
	pdata["tall"] = rand_range(0,1)
	pdata["thick"] = rand_range(0,1)
	pdata["leg"] = rand_range(0,1)
	pdata["scene"] = rand_range(0,1) * rand_range(0,1)
	
	pdata["hair"] = randhair()
	
	pdata["role"] = ""
	if(recruitable):
		pdata["role"] = "hireable"
	if(shopkeep):
		pdata["role"] = "shopkeep"
	
	pdata["x"] = x + rand_range(-50,50)
	pdata["z"] = z + rand_range(-50,50)
	
	pdata["running"] = int(rand_range(0,tier*10))
	pdata["medic"] = int(rand_range(0,tier*10))
	pdata["toughness"] = int(rand_range(0,tier*10))

	pdata["swordskill"] = int(rand_range(0,tier*10))
	pdata["axeskill"] = int(rand_range(0,tier*10))
	pdata["rangedskill"] = int(rand_range(0,tier*10))
	pdata["unarmedskill"] = int(rand_range(0,tier*10))

	pdata["heldItem"] = get_node("../DroppedItems").randweap(0,(tier*3)-1)
	pdata["armorItem"] = null
	pdata["headItem"] = null
	 
	if(tier > 2 and rand_range(0.0,1.0) > 0.5):
		pdata["armorItem"] = get_node("../DroppedItems").randarmor(0,tier-3)
	if(tier > 2 and rand_range(0.0,1.0) > 0.5):
		pdata["headItem"] = get_node("../DroppedItems").randhelm(0,tier-3)

	pdata["invItems"] = []

	#dont matter.
	pdata["charname"] = ""
	
	get_node("../Actors").spawnPlayer(pdata,true)

# Called when the node enters the scene tree for the first time.
func generateFirstTime():
	for i in self.get_children():
		if("beakneck" in i.name):
			beakneckgenerate(i.global_transform.origin.x,i.global_transform.origin.z)
		else:
			# max party size is fourteen.
			# so thirty-ish recruitables. 
			# Thats one in five.
			# we should have two shopkeepers too, per race.
			for z in range(20):
				if(rand_range(0.0,1.0) < 0.7):
					# 1, 2.
					npcgenerate(i.name.replace("2",""),1 + (randi() % 2),i.global_transform.origin.x,i.global_transform.origin.z, (z % 5 == 0), ((z+2) % 9 == 0))
				else:
					# 3, 4, 5.
					npcgenerate(i.name.replace("2",""),3 + (randi() % 3),i.global_transform.origin.x,i.global_transform.origin.z, (z % 5 == 0), ((z+2) % 9 == 0))



