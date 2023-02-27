extends Node


var KenshitItem = load("res://scripts/KenshitItem.gd")
# Declare member variables here. Examples:
var vis_to_it = {}

var all_weapons = null
var all_armors = null
var all_helms = null
var all_foods = null
var all_healing = null

var SHINY_CHANCE = (1.0/20.0)

# Called when the node enters the scene tree for the first time.
func loadFromSave(dropped):
	prepare_weapons()
	for v in dropped:
		var k = KenshitItem.new()
		k.deserialize(v)
		put(k,Vector3(v["x"],40,v["z"]))

func generateFirstTime():
	

	prepare_weapons()
	for i in range(150):
		put(randweap(0,5),Vector3(rand_range(200,1500),40,rand_range(200,1500)))
		
	# only spawn poor armor in real game
	for i in range(8):
		put(randhelm(0,0),Vector3(rand_range(200,1500),40,rand_range(200,1500)))
		
	# only spawn poor armor in real game
	for i in range(8):
		put(randarmor(0,0),Vector3(rand_range(200,1500),40,rand_range(200,1500)))
		
	for i in range(100):
		put(randfood(0,5),Vector3(rand_range(200,1500),40,rand_range(200,1500)))

	for i in range(70):
		put(randhealing(0,2),Vector3(rand_range(200,1500),40,rand_range(200,1500)))

func collectForSave():
	var r = []
	for v in vis_to_it.keys():
		var i = vis_to_it[v].serialize()
		i["x"] = v.global_transform.origin.x
		i["z"] = v.global_transform.origin.z
		r.append(i)
	return r

func destroy(item):
	vis_to_it.erase(item)
	item.queue_free()

func geti(item):
	if(vis_to_it.has(item)):
		return vis_to_it[item]
	else:
		return null

func put(item,pos):
	
	var res = load("res://overworld_items/" + item.itemname + ".tscn").instance()
	add_child(res)
	
	var space_state = res.get_world().direct_space_state
	var hit = space_state.intersect_ray(pos + Vector3(0,50,0), pos + Vector3(0,-1000,0), [])
	if not hit.empty():
		res.transform.origin = hit.values()[0]
		
	vis_to_it[res] = item

# h helmet
# a armor
# r ranged
# m medical
# f food
# l long
# s short

# random melle weapon.
# later ones -> harder

func copy(bitem):
	var item = KenshitItem.new()
	#kek FUCKIN W
	item.deserialize(bitem.serialize())

	# food should be in the range of ~30ish cats?
	if(bitem.type == "f"):
		item.price = int(pow(bitem.damage/4,1.3))
	
	# heals should be in the range of ~50ish cats?
	if(bitem.type == "m"):
		item.price = int(pow(bitem.damage/10,1.5))
		
	# helmets and armor EXPENSIVE.
	if(bitem.type == "h"):
		item.price = int(pow(bitem.damage,1.4))
		
	# helmets and armor EXPENSIVE.
	if(bitem.type == "a"):
		item.price = 3 * int(pow(bitem.damage,1.6))
	return item

func mutate(bweap):
	var weap = KenshitItem.new()
	#kek FUCKIN W
	weap.deserialize(bweap.serialize())
	# mutations
	weap.damage = int(weap.damage * rand_range(1,1.3))
	weap.cooldown = weap.cooldown + ((randi() % 4) / 10.0)
	if(rand_range(0.0,1.0) < SHINY_CHANCE):
		weap.damage = int(weap.damage * rand_range(1.3,1.6))
		weap.shiny = 1 + (randi() % 16)
		
	# DPS times ten?, scale lightly with pow 1.1
	weap.price = int(pow(weap.damage * (1.0 / weap.cooldown),1.1) * 10)
	
	#shiny and ranged are double price.
	if(weap.shiny > 0):
		weap.price = weap.price * 2
		
	if(weap.type == "r"):
		weap.price = weap.price * 2

	return weap
	
# 0 to fourteen.
func randweap(lo,hi):
	if(all_weapons == null):
		prepare_weapons()
	var idx = lo + randi() % ((hi + 1) - lo)
	return mutate(all_weapons[idx])
	
func randarmor(lo,hi):
	if(all_armors == null):
		prepare_armors()
	var idx = lo + randi() % ((hi + 1) - lo)
	return copy(all_armors[idx])
	
func randhelm(lo,hi):
	if(all_helms == null):
		prepare_helmets()
	var idx = lo + randi() % ((hi + 1) - lo)
	return copy(all_helms[idx])
	
func randfood(lo,hi):
	if(all_foods == null):
		prepare_foods()
	var idx = lo + randi() % ((hi + 1) - lo)
	return copy(all_foods[idx])
	
func randhealing(lo,hi):
	if(all_healing == null):
		prepare_healing()
	var idx = lo + randi() % ((hi + 1) - lo)
	return copy(all_healing[idx])

func prepare_foods():
	all_foods = []
	KenshitItem = load("res://scripts/KenshitItem.gd")
	
	var k = KenshitItem.new()
	k.itemname = "monster energy zero ultra"
	k.type = "f"
	k.price = 1
	k.rnge = -1
	k.damage = 10
	k.cooldown = -1
	all_foods.append(k)
	
	k = KenshitItem.new()
	k.itemname = "bonk"
	k.type = "f"
	k.price = 1
	k.rnge = -1
	k.damage = 20
	k.cooldown = -1
	all_foods.append(k)
	
	k = KenshitItem.new()
	k.itemname = "donut"
	k.type = "f"
	k.price = 1
	k.rnge = -1
	k.damage = 30
	k.cooldown = -1
	all_foods.append(k)
	
	k = KenshitItem.new()
	k.itemname = "hotdog"
	k.type = "f"
	k.price = 1
	k.rnge = -1
	k.damage = 35
	all_foods.append(k)
	
	k = KenshitItem.new()
	k.itemname = "burger"
	k.type = "f"
	k.price = 1
	k.rnge = -1
	k.damage = 45
	all_foods.append(k)
	
	k = KenshitItem.new()
	k.itemname = "steak"
	k.type = "f"
	k.price = 1
	k.rnge = -1
	k.damage = 75
	k.cooldown = -1
	all_foods.append(k)
	
func prepare_healing():
	all_healing = []
	KenshitItem = load("res://scripts/KenshitItem.gd")
	
	var k = KenshitItem.new()
	k = KenshitItem.new()
	k.itemname = "medkit"
	k.type = "m"
	k.price = 1
	k.rnge = -1
	k.damage = 100
	k.cooldown = -1
	all_healing.append(k)
	
	k = KenshitItem.new()
	k.itemname = "hyperpotion"
	k.type = "m"
	k.price = 1
	k.rnge = -1
	k.damage = 200
	k.cooldown = -1
	all_healing.append(k)
	
	k = KenshitItem.new()
	k.itemname = "healthpack"
	k.type = "m"
	k.price = 1
	k.rnge = -1
	k.damage = 300
	k.cooldown = -1
	all_healing.append(k)
	

func prepare_helmets():
	all_helms = []
	
	KenshitItem = load("res://scripts/KenshitItem.gd")
	var k = KenshitItem.new()
	k.itemname = "light_helmet"
	k.type = "h"
	k.price = 1
	k.rnge = -1
	k.damage = 20
	k.cooldown = -1
	all_helms.append(k)
	
	k = KenshitItem.new()
	k.itemname = "medium_helmet"
	k.type = "h"
	k.price = 1
	k.rnge = -1
	k.damage = 35
	k.cooldown = -1
	all_helms.append(k)

	k = KenshitItem.new()
	k.itemname = "heavy_helmet"
	k.type = "h"
	k.price = 1
	k.rnge = -1
	k.damage = 50
	k.cooldown = -1
	all_helms.append(k)
	
	
func prepare_armors():
	all_armors = []
	
	var KenshitItem = load("res://scripts/KenshitItem.gd")
	var k = KenshitItem.new()
	k.itemname = "coat"
	k.type = "a"
	k.price = 1
	k.rnge = -1
	k.damage = 10
	k.cooldown = -1
	all_armors.append(k)
	
	k = KenshitItem.new()
	k.itemname = "armor1"
	k.type = "a"
	k.price = 1
	k.rnge = -1
	k.damage = 25
	k.cooldown = 0.3
	all_armors.append(k)
	
	
	k = KenshitItem.new()
	k.itemname = "samurai_armor"
	k.type = "a"
	k.price = 1
	k.rnge = -1
	k.damage = 40
	k.cooldown = -1
	all_armors.append(k)


func prepare_weapons():
	var KenshitItem = load("res://scripts/KenshitItem.gd")
	all_weapons = []
	
	# Unarmed feels good at 10 DPS.
	# Unarmed has shortest range at 1.
	
	#s1, 10 DPS but faster.
	var k = KenshitItem.new()
	k.itemname = "fan"
	k.type = "s"
	k.price = 1
	k.rnge = 1.3
	k.damage = 8
	k.cooldown = 0.5
	all_weapons.append(k)
	
	#l1, 15 DPS but VERY slow.
	k = KenshitItem.new()
	k.itemname = "stop sign"
	k.type = "l"
	k.price = 1
	k.rnge = 2
	k.damage = 25
	k.cooldown = 2.2
	all_weapons.append(k)
	
	#s2 20 DPS at a reliable rate.
	k = KenshitItem.new()
	k.itemname = "frying pan"
	k.type = "s"
	k.price = 1.4
	k.rnge = 1.4
	k.damage = 13
	k.cooldown = 1.2
	all_weapons.append(k)
	
	#r1 5 DPS, at a range.
	k = KenshitItem.new()
	k.itemname = "bow"
	k.type = "r"
	k.price = 1
	k.rnge = 30
	k.damage = 6
	k.cooldown = 3.2
	all_weapons.append(k)

	#l2 very decent 25 DPS
	k = KenshitItem.new()
	k.itemname = "biggoron sword"
	k.type = "l"
	k.price = 1.7
	k.rnge = 2
	k.damage = 17
	k.cooldown = 1.4
	all_weapons.append(k)
	
	#s3 fast 25ish dps
	k = KenshitItem.new()
	k.itemname = "coppershortsword"
	k.type = "s"
	k.price = 1
	k.rnge = 1.3
	k.damage = 12
	k.cooldown = 0.6
	all_weapons.append(k)

	#r2 short range but solid 15 dps
	k = KenshitItem.new()
	k.itemname = "sydney sleeper"
	k.type = "r"
	k.price = 1
	k.rnge = 15
	k.damage = 16
	k.cooldown = 1.7
	all_weapons.append(k)
	
	#l3, pushing 30 dps
	k = KenshitItem.new()
	k.itemname = "jawblade"
	k.type = "l"
	k.price = 1
	k.rnge = 2.2
	k.damage = 42
	k.cooldown = 2.6
	all_weapons.append(k)
	
	#s4 40ish dps
	k = KenshitItem.new()
	k.itemname = "knife"
	k.type = "s"
	k.price = 1
	k.rnge = 1.1
	k.damage = 33
	k.cooldown = 1.1
	all_weapons.append(k)

	#r3 20ish dps, at a distance.
	k = KenshitItem.new()
	k.itemname = "moist nugget"
	k.type = "r"
	k.price = 1
	k.rnge = 28
	k.damage = 63
	k.cooldown = 3.8
	all_weapons.append(k)
	
	#l4 40 dps
	k = KenshitItem.new()
	k.itemname = "zweihander"
	k.type = "l"
	k.price = 1
	k.rnge = 1.7
	k.damage = 52
	k.cooldown = 1.7
	all_weapons.append(k)
	
	#r4 30 dps
	k = KenshitItem.new()
	k.itemname = "autosniper"
	k.type = "r"
	k.price = 1
	k.rnge = 13
	k.damage = 29
	k.cooldown = 0.9
	all_weapons.append(k)
	
	#l5 60 DPS, 
	k = KenshitItem.new()
	k.itemname = "super sledge"
	k.type = "l"
	k.price = 1
	k.rnge = 1.9
	k.damage = 50
	k.cooldown = 2.7
	all_weapons.append(k)
	
	#r5 50ish dps
	k = KenshitItem.new()
	k.itemname = "minishark"
	k.type = "r"
	k.price = 1
	k.rnge = 15
	k.damage = 15
	k.cooldown = 0.2
	all_weapons.append(k)
	
	#r5
	k = KenshitItem.new()
	k.itemname = "energy sword"
	k.type = "s"
	k.price = 1
	k.rnge = 1.5
	k.damage = 40
	k.cooldown = 0.7
	all_weapons.append(k)
