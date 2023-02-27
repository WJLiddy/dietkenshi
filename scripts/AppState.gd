extends Node2D

var f_names = []
var m_names = []
var new_game_protag_data = null
var money = 0
onready var player_relation = default_relation()

var shopping = null
var recruting = null

var last_saved = -1

var aggro_cooldown = 0

func default_relation():
	return {
		"vaper":3,
		"shrek":3,
		"skeleton":3,
		"hive":3,
		"uc":3,
		"player":4,
		"hell":2 
		# WHAT? HELL PLAYERS SHOULD BE DEAD.
	}

#factiondescs = ["HATE :( :(","SUS @ U","DONTCARE LOL","CHILL","BFFS!!!"]
func relation(from,to):
	# VS mode hack
	if(from == "player2" or to == "player1"):
		if(from == to):
			return 4
		return 0

	if(from == "player"):
		return player_relation[to]

	if(from == "hive"):
		if(to == "hive"):
			return 4
		if(to == "player"):
			return player_relation["hive"]
		# dont care about everyone else
		return 2

	if(from == "uc"):
		if(to == "skeleton"):
			return 0
		if(to == "shrek"):
			return 1
		if(to == "hive"):
			return 2
		if(to == "vaper"):
			return 3
		if(to == "uc"):
			return 4
		return player_relation["uc"]
		
	if(from == "vaper"):
		if(to == "player"):
			return player_relation["vaper"]
		return 3
		
	if(from == "skeleton"):
		if(to == "skeleton"):
			return 3
		if(to == "shrek"):
			return 2
		if(to == "hive"):
			return 2
		if(to == "vaper"):
			return 3
		if(to == "uc"):
			return 0
		return player_relation["skeleton"]
		
	if(from == "shrek"):
		if(to == "shrek"):
			return 2
		if(to != "player"):
			return 1
		return player_relation["shrek"]

	# hell characters get this sometimes?????
	# how?? who is looking this up?
	#print("failed relation lookup!")
	#print(from + " - " + to)
	return 2

func get_f_name():
	if(f_names.size() == 0):
		loadnames()
	return f_names[randi() % f_names.size()]

func get_m_name():
	if(m_names.size() == 0):
		loadnames()
	return m_names[randi() % m_names.size()]

func loadnames():
	var f = File.new()
	f.open("res://names1880.txt", File.READ)
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var line = f.get_line().split(",")
		if(line[1] == "\"M\""):
			m_names.append(line[0].replace("\"",""))
		else:
			f_names.append(line[0].replace("\"",""))
	f.close()
	return
	
func handleShopping(selected_actor):
	shopping = selected_actor
	
func handleRecruit(selected_actor):
	recruting = selected_actor

func getMostRecentSave():
	var ret = 0
	var directory = Directory.new();
	while(true):
		if(!directory.file_exists("user://" + str(ret+1) + ".kenshit")):
			return ret
		ret += 1

# this should be called every minute.
func savegame(players,items):
	last_saved += 1
	var file = File.new()
	file.open("user://" + str(last_saved) + ".kenshit", File.WRITE)
	file.store_var(players)
	file.store_var(items)
	file.store_var(AppState.money)
	file.store_var(AppState.player_relation)
	file.close()

# only called at startup.
func loadgame():
	last_saved = getMostRecentSave()
	var file = File.new()
	file.open("user://" + str(last_saved) + ".kenshit", File.READ)
	var players = file.get_var()
	var items = file.get_var()
	AppState.money = file.get_var()
	AppState.player_relation = file.get_var()
	file.close()
	return [players,items]

func forceLoadFaction(id):
	var file = File.new()
	file.open("user://"+ id +".kenshit", File.READ)
	var players = file.get_var()
	file.close()
	return players


func timeTravel():
	# delete last saved game and reload. easy.
	if(last_saved != 0):
		var directory = Directory.new();
		directory.remove("user://" + str(last_saved) + ".kenshit")
	get_tree().reload_current_scene()

