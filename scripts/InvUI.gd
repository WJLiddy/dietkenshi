extends TextureRect


# Declare member variables here. Examples:
# var a = 2
var player = null
var item_sprites = {}

func setPlayer(k):
	player = k

func preloadItemSprites():
	var directory = Directory.new()
	directory.open("res://items")
	directory.list_dir_begin(true)

	var item = directory.get_next()
	while item != "":
		if(not "import" in item):
			item_sprites[item.split(".")[0]] = load("res://items/" + item)
		item = directory.get_next()
		

func ui_input(event, slot):
	if(player.faction != "player"):
		return

	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_LEFT:
				player.dropItem(slot)
				get_node("../drop").play()
			BUTTON_RIGHT:
				if(player.invItems[slot].type != "f" and player.invItems[slot].type != "m"):
					get_node("../click").play()
				player.use(slot)

# Called when the node enters the scene tree for the first time.
func _ready():
	preloadItemSprites()

	get_node("Head").connect("pressed", self, "dropHeadItem")
	get_node("Armor").connect("pressed", self, "dropArmorItem")
	get_node("Weapon").connect("pressed", self, "dropWeaponItem")
	
	var it = 0
	for i in get_node("GridContainer").get_children():
		i.connect("gui_input", self, "ui_input",[it])
		i.connect("mouse_entered", self, "showDesc",[it])
		i.connect("mouse_exited", self, "hideDesc",[it])
		it += 1
	
	get_node("Head").connect("mouse_entered", self, "showHelm")
	get_node("Head").connect("mouse_exited", self, "hideHelm")
	
	get_node("Armor").connect("mouse_entered", self, "showArmor")
	get_node("Armor").connect("mouse_exited", self, "hideArmor")
	
	get_node("Weapon").connect("mouse_entered", self, "showHeld")
	get_node("Weapon").connect("mouse_exited", self, "hideHeld")

func showHeld():
	get_node("../DescriptorInv").display(player.heldItem)
	
func hideHeld():
	get_node("../DescriptorInv").visible = false

func showArmor():
	get_node("../DescriptorInv").display(player.armorItem)
	
func hideArmor():
	get_node("../DescriptorInv").visible = false

func showHelm():
	get_node("../DescriptorInv").display(player.headItem)
	
func hideHelm():
	get_node("../DescriptorInv").visible = false
	
func showDesc(i):
	if(i < len(player.invItems)):
		get_node("../DescriptorInv").display(player.invItems[i])
	
func hideDesc(i):
	get_node("../DescriptorInv").visible = false

func dropHeadItem():
	if(player.faction != "player"):
		return
	player.dropHeadItem()
	get_node("../drop").play()

func dropArmorItem():
	if(player.faction != "player"):
		return
	player.dropArmorItem()
	get_node("../drop").play()

func dropWeaponItem():
	if(player.faction != "player"):
		return
	player.dropWeaponItem()
	get_node("../drop").play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var cnt = 0
	for i in get_node("GridContainer").get_children():
		if(cnt < len(player.invItems)):
			# this happens unexplainably.
			if(player.invItems[cnt] == null):
				return
			i.texture_normal = item_sprites[player.invItems[cnt].itemname]
		else:
			i.texture_normal = null
		cnt += 1

	if(player.headItem != null):
		get_node("Head").texture_normal = item_sprites[player.headItem.itemname]
	else:
		get_node("Head").texture_normal = null

	if(player.heldItem != null):
		var tex = item_sprites[player.heldItem.itemname]
		get_node("Weapon").texture_normal = item_sprites[player.heldItem.itemname]
	else:
		get_node("Weapon").texture_normal = null
		
	if(player.armorItem != null):
		get_node("Armor").texture_normal = item_sprites[player.armorItem.itemname]
	else:
		get_node("Armor").texture_normal = null




