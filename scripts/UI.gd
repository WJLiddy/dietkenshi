extends Control


# Declare member variables here. Examples:
onready var charAttr = get_node("CharAttr")
onready var charDesc = get_node("CharDesc")
onready var party = get_node("Party")
onready var inv = get_node("Inv")
onready var money = get_node("Money")
onready var money2 = get_node("Money2")

var shopitems = []

var factiondescs = ["HATE :( :(","SUS @ U","DONTCARE LOL","CHILL","BFFS!!!"]

var time_travel_next_frame = -1

func pause():
	Engine.time_scale = 0

func one():
	Engine.time_scale = 1

func two():
	Engine.time_scale = 3

func four():
	Engine.time_scale = 6
	


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Speeds/pause").connect("pressed",self,"pause")
	get_node("Speeds/one").connect("pressed",self,"one")
	get_node("Speeds/two").connect("pressed",self,"two")
	get_node("Speeds/four").connect("pressed",self,"four")


func updateFaction():
	var t = ""
	t += factiondescs[AppState.relation("hive","player")] + "\n\n"
	t += factiondescs[AppState.relation("shrek","player")] + "\n\n"
	t += factiondescs[AppState.relation("vaper","player")] + "\n\n"
	t += factiondescs[AppState.relation("uc","player")] + "\n\n"
	t += factiondescs[AppState.relation("skeleton","player")] + "\n\n"
	
	get_node("Faction/Label").text = t

func setFocus(k):
	inv.setPlayer(k)
	charAttr.setPlayer(k)
	charDesc.setPlayer(k)
	party.updateL(get_node("../Actors").get_player_chars())
	updateFaction()

func generateShop(s):
	shopitems = []
	
	var weap = str(s).hash() % 10
	shopitems.append(get_node("../DroppedItems").randweap(weap,weap))
	var food = str(s).hash() % 6
	shopitems.append(get_node("../DroppedItems").randfood(food,food))
	var medic = str(s).hash() % 3
	shopitems.append(get_node("../DroppedItems").randhealing(medic,medic))
	
	# offer bonus items:
	var opt = str(s).hash() % 5
	
	# weapon specialist
	if(opt == 0):
		var weap2 = (str(s)+"1").hash() % 15
		shopitems.append(get_node("../DroppedItems").randweap(weap2,weap2))
		var weap3 =  (str(s)+"2").hash() % 15
		shopitems.append(get_node("../DroppedItems").randweap(weap3,weap3))
		
	# helmets and food.
	if(opt == 1):
		var food2 =  (str(s)+"3").hash() % 6
		shopitems.append(get_node("../DroppedItems").randfood(food2,food2))
		var armor2 =  (str(s)+"4").hash() % 3
		shopitems.append(get_node("../DroppedItems").randhelm(armor2,armor2))
		
	# armor and helmets.
	if(opt == 2):
		var helm2 =  (str(s)+"5").hash() % 3
		shopitems.append(get_node("../DroppedItems").randhelm(helm2,helm2))
		var armor2 =  (str(s)+"6").hash() % 3
		shopitems.append(get_node("../DroppedItems").randarmor(armor2,armor2))
		
	# medicine and food.
	if(opt == 3):
		var food2 =  (str(s)+"7").hash() % 6
		shopitems.append(get_node("../DroppedItems").randfood(food2,food2))
		var medic2 =  (str(s)+"8").hash() % 3
		shopitems.append(get_node("../DroppedItems").randhealing(medic2,medic2))
		
	# armor and medicine.
	if(opt == 4):
		var food2 = (str(s)+"9").hash() % 3
		shopitems.append(get_node("../DroppedItems").randhealing(food2,food2))
		var armor2 = (str(s)+"10").hash() % 3
		shopitems.append(get_node("../DroppedItems").randarmor(armor2,armor2))
		
	get_node("shop/Item1/Label").text = shopitems[0].itemname + "\ncost" + str(shopitems[0].price)
	get_node("shop/Item2/Label").text = shopitems[1].itemname + "\ncost" + str(shopitems[1].price)
	get_node("shop/Item3/Label").text = shopitems[2].itemname + "\ncost" + str(shopitems[2].price)
	get_node("shop/Item4/Label").text = shopitems[3].itemname + "\ncost" + str(shopitems[3].price)
	get_node("shop/Item5/Label").text = shopitems[4].itemname + "\ncost" + str(shopitems[4].price)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	money.text = str(AppState.money) + "dollrs"
	money2.text = str(AppState.money) + "dollrs"
	time_travel_next_frame -= 1
	if(time_travel_next_frame == 0):
		AppState.timeTravel()

func startShopping():
	generateShop(AppState.shopping.charname)
	get_node("shop").visible = true
	
func startRecruting():
	get_node("hire/cost").text = "hire me for\n$" + str(AppState.recruting.recruitCost())
	get_node("hire").visible = true

#tiemtravel button
func _on_TextureButton_pressed():
	get_node("timetravel").visible = true
	time_travel_next_frame = 2


func _on_b1_pressed():
	if(shopitems[0] != null and shopitems[0].price <= AppState.money):
		AppState.money -= shopitems[0].price
		get_node("../DroppedItems").put(shopitems[0],AppState.shopping.global_transform.origin)
		shopitems[0] = null
		get_node("buy").play()
		get_node("shop/Item1/Label").text = "null"


func _on_b2_pressed():
	if(shopitems[1] != null and shopitems[1].price <= AppState.money):
		AppState.money -= shopitems[1].price
		get_node("../DroppedItems").put(shopitems[1],AppState.shopping.global_transform.origin)
		shopitems[1] = null
		get_node("buy").play()
		get_node("shop/Item2/Label").text = "nil"


func _on_b3_pressed():
	if(shopitems[2] != null and shopitems[2].price <= AppState.money):
		AppState.money -= shopitems[2].price
		get_node("../DroppedItems").put(shopitems[2],AppState.shopping.global_transform.origin)
		shopitems[2] = null
		get_node("buy").play()
		get_node("shop/Item3/Label").text = "nullptr"


func _on_b4_pressed():
	if(shopitems[3] != null and shopitems[3].price <= AppState.money):
		get_node("../DroppedItems").put(shopitems[3],AppState.shopping.global_transform.origin)
		AppState.money -= shopitems[3].price
		shopitems[3] = null
		get_node("buy").play()
		get_node("shop/Item4/Label").text = "NoneType"


func _on_b5_pressed():
	if(shopitems[4] != null and shopitems[4].price <= AppState.money):
		get_node("../DroppedItems").put(shopitems[4],AppState.shopping.global_transform.origin)
		AppState.money -= shopitems[4].price
		shopitems[4] = null
		get_node("buy").play()
		get_node("shop/Item5/Label").text = "-1"

# shop quit.
func _on_quit_pressed():
	get_node("shop").visible = false
	AppState.shopping = false
	pass # Replace with function body.

func _on_hired_pressed():
	if(AppState.recruting.recruitCost() <= AppState.money):
		AppState.recruting.recruit()
		AppState.money -= AppState.recruting.recruitCost()
		get_node("recruit").play()
		get_node("hire").visible = false
		AppState.recruting = false
	pass # Replace with function body.

func _on_fired_pressed():
	get_node("hire").visible = false
	AppState.recruting = false
	pass # Replace with function body.
