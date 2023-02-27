extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var player = null
func setPlayer(k):
	player = k

# Called when the node enters the scene tree for the first time.
func _process(delta):
	get_node("head").max_value = player.getMaxHP()
	get_node("head").value = player.head_hp
	get_node("head/Label").text = str(player.head_hp) + " HP"
	
	get_node("belly").max_value = player.getMaxHP()
	get_node("belly").value = player.belly_hp
	get_node("belly/Label").text = str(player.belly_hp) + " HP"

	get_node("larm").max_value = player.getMaxHP()
	get_node("larm").value = player.larm_hp
	get_node("larm/Label").text = str(player.larm_hp) + " HP"
	
	get_node("rarm").max_value = player.getMaxHP()
	get_node("rarm").value = player.rarm_hp
	get_node("rarm/Label").text = str(player.rarm_hp) + " HP"
	
	get_node("lleg").max_value = player.getMaxHP()
	get_node("lleg").value = player.lleg_hp
	get_node("lleg/Label").text = str(player.lleg_hp) + " HP"
	
	get_node("rleg").max_value = player.getMaxHP()
	get_node("rleg").value = player.rleg_hp
	get_node("rleg/Label").text = str(player.rleg_hp) + " HP"
	
	get_node("hanger").max_value = 100
	get_node("hanger").value = player.hanger
	
	get_node("action").text = player.getAction()
	
	
	get_node("arm1").visible = false
	get_node("arm2").visible = false
	get_node("leg1").visible = false
	get_node("leg2").visible = false
		
	if(player.larm_hp == 0 and player.rarm_hp == 0):
		get_node("arm2").visible = true
		
	elif(player.larm_hp == 0 or player.rarm_hp == 0):
		get_node("arm1").visible = true
	
	if(player.lleg_hp == 0 and player.rleg_hp == 0):
		get_node("leg2").visible = true
	
	elif(player.lleg_hp == 0 or player.rleg_hp == 0):
		get_node("leg1").visible = true
