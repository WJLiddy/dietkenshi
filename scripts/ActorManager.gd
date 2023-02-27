extends Node

onready var cam = get_node("../KenshitCamera")
onready var kenshiactor = preload("res://KenshitActor.tscn")
onready var kenshibeackneck = preload("res://KenshitBeakNeck.tscn")

var sf = true
var c_this_frame = []
var selected_actors = []
var actorsortcache = {}
var sort_update_idx = 0

var autosave_timer = 60

var INTERACT_DIST = 10

var VERSUS_FLAG = false

# Called when the node enters the scene tree for the first time.
func _ready():
	loadFromSave()
	
	# temp fix for beak neck, need this code anymore even??
	if(len(get_player_chars()) > 0):
		get_node("../UI").setFocus(get_player_chars()[0])
	else:
		get_node("../UI").setFocus(get_children()[0])
	pass

# first pass at player spawner.
func spawnPlayer(pdata, deserialize):
	var v = null
	if(pdata["faction"] != "animal"):
		v = kenshiactor.instance()
	else:
		v = kenshibeackneck.instance()
	
	if(deserialize):
		v.deserialize(pdata)
	else:
		# deserialize, with default attrs (new game!)
		v.charname = pdata["charname"]
		v.basemodel = pdata["basemodel"]
		v.faction = "player"
		pdata["x"] = 500
		pdata["z"] = 500
	add_child(v)
	
	if(pdata["faction"] != "animal"):
		# set player characteristics
		v.get_node("model").setParams(pdata["tall"],pdata["thick"],pdata["leg"],pdata["scene"],pdata["hair"])
		
	v.global_transform.origin = Vector3(pdata["x"],0,pdata["z"])


func loadVersus():
	print("lv")
	var loadData1 = AppState.forceLoadFaction("a")
	for v in loadData1:
		if(v["faction"] == "player"):
			v["x"] = rand_range(1000,1020)
			v["z"] = rand_range(1010,1020)
			v["faction"] = "player1"
			spawnPlayer(v,true)
		
	var loadData2 = AppState.forceLoadFaction("b")
	for v in loadData2:
		if(v["faction"] == "player"):
			v["x"] = rand_range(1000,1020)
			v["z"] = rand_range(1070,1080)
			v["faction"] = "player2"
			spawnPlayer(v,true)

func loadFromSave():
	if(VERSUS_FLAG):
		loadVersus()
		return
	#load from save.
	if(AppState.new_game_protag_data == null):
		var loadData = AppState.loadgame()
		get_node("../DroppedItems").loadFromSave(loadData[1])
		for v in loadData[0]:
			spawnPlayer(v,true)
	else:
		spawnPlayer(AppState.new_game_protag_data,false)
		get_node("../DroppedItems").generateFirstTime()
		get_node("../NPCGen").generateFirstTime()
		

func get_camera():
	var r = get_node('/root')
	return r.get_viewport().get_camera()

func customComparison(a,b):
	return a[1] <= b[1]

func get_visible_actors(actor):
	if(not actorsortcache.has(actor)):
		actorsortcache[actor] = get_visible_actors_cache(actor.global_transform.origin)
	return actorsortcache[actor]

# the key to fast kenshi is to clean this up
func get_visible_actors_cache(pos):
	var actors = []
	for i in c_this_frame:
		# Use just manhattan cause it's fast
		var dist = pos.distance_to(i.global_transform.origin)
		if(dist < 100):
			actors.append([i,dist])
	actors.sort_custom(self, "customComparison")
	return actors

func set_dest_for_selected(point):
	if(point.y < 20):
		return
	for n in selected_actors:
		if(n.faction == "player"):
			n.moveDestination = point
			n.interactTarget = null

func will_start_combat():
	for v in selected_actors:
		if((v.faction == "player") and v.behavior == "KILL"):
			return true
	return false

func select_region(start, end):
	if(start == null or end == null):
		#happens sometimes if mouse clicks OOB
		return
	
	var new_selected_actors = []
	for i in get_children():
		var pos = get_camera().unproject_position(i.global_transform.origin)
		if(min(start.x,end.x) < pos.x and max(start.x,end.x) > pos.x) and (min(start.y,end.y) < pos.y and max(start.y,end.y) > pos.y):
			new_selected_actors.append(i)
	
	if(len(new_selected_actors) == 0):
		return false
	
	# okay, a bit careful now. if we clicked on a single person, we probably want
	# to fight them.
	
	var combat = false
	# check if any selected players are in "fight" mode. if they are, fight the target.
	for v in selected_actors:
		for k in new_selected_actors:
			if(v.behavior == "KILL" && k.faction != "player"):
				v.instigate(k)
				combat = true
	if(combat):
		return true
	
	# OR, they are recruitable, or shopkeeps. 
	if(new_selected_actors.size() == 1 && new_selected_actors[0]["role"] == "shopkeep"):
		
		if(selected_actors[0].global_transform.origin.distance_to(new_selected_actors[0].global_transform.origin) < INTERACT_DIST):
			if(!selected_actors[0].charIsKOd() and !selected_actors[0].charIsDead()):
				AppState.handleShopping(new_selected_actors[0])
				get_node("../UI").startShopping()
				return true
	
	if(new_selected_actors.size() == 1 && new_selected_actors[0]["role"] == "hireable"):

		if(selected_actors[0].global_transform.origin.distance_to(new_selected_actors[0].global_transform.origin) < INTERACT_DIST):
			if(!selected_actors[0].charIsKOd() and !selected_actors[0].charIsDead()):
				AppState.handleRecruit(new_selected_actors[0])
				get_node("../UI").startRecruting()
				return true
	
	onSelectionUpdated(new_selected_actors)
	return true
	
func setItemGet(it):
	for e in selected_actors:
		if(e.faction != "player"):
			continue
		e.interactTarget = it

func onSelectionUpdated(new_selected_actors):
		# set all to false cause we updatin'
	selected_actors = new_selected_actors
	for i in get_children():
		i.selected = false
	for i in new_selected_actors:
		i.selected = true
	get_node("../UI").setFocus(selected_actors[0])
	setcamfocus(selected_actors[0])


func selectSingleActor(slot):
	if(len(get_player_chars()) <= slot):
		return
	var new_selected_actors = [get_player_chars()[slot]]
	onSelectionUpdated(new_selected_actors)
	get_node("../UI").setFocus(selected_actors[0])
	
func get_player_chars():
	var out = []
	for i in get_children():
		if(i.faction == "player"):
			out.append(i)
	return out
	
func get_all_chars():
	var out = []
	for i in get_children():
		out.append(i)
	return out

func collectForSave():
	var out = []
	for i in get_children():
		#shopkeeper items not real???
		
		out.append(i.serialize(i.global_transform.origin.x,i.global_transform.origin.z))
	return out

func _process(delta):
	#fuck lol
	AppState.aggro_cooldown -= delta
	

	
	# save every minute, don't consider time scale.
	if(Engine.time_scale != 0):
		autosave_timer -= delta * (1.0 / Engine.time_scale)
	
	if(autosave_timer < 0 and !VERSUS_FLAG):
		AppState.savegame(collectForSave(), get_node("../DroppedItems").collectForSave())
		autosave_timer = 60
		print("save triggered.")

	c_this_frame = get_all_chars()
	if(sf):
		if(len(get_player_chars()) > 0):
			setcamfocus(get_player_chars()[0])
		else:
			setcamfocus(c_this_frame[0])
		sf = false
		if(AppState.new_game_protag_data != null):
			AppState.new_game_protag_data = null
			AppState.savegame(collectForSave(), get_node("../DroppedItems").collectForSave())
	
	# Update the distance map for one person
	var next_to_sort = c_this_frame[sort_update_idx]
	if(actorsortcache.has(next_to_sort)):
		actorsortcache[next_to_sort] = get_visible_actors_cache(next_to_sort.global_transform.origin)
	sort_update_idx += 1
	if(sort_update_idx >= len(c_this_frame)):
		sort_update_idx = 0
		
func setcamfocus(actor):
	cam.get_parent().remove_child(cam)
	actor.add_child(cam)
