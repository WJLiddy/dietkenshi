extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func shortcode(r):
	if(r == "r"):
		return "ranged" 
	if(r == "s"):
		return "weeb sword"
	if(r == "l"):
		return "bigass" 
	if(r == "f"):
		return "delicious" 
	if(r == "m"):
		return "medical" 
	if(r == "h"):
		return "headwear" 
	if(r == "a"):
		return "cloths" 

func hide():
	visible = false

func display(i):
	if(i == null):
		return
	visible = true
	var text = ""
	text += "var name = " + i.itemname + "\n"
	text += "var type = " + shortcode(i.type) + "\n"
	if(i.type == "r" or i.type == "s" or i.type == "l"):
		text += "var pain = " + str(i.damage) + "\n"
		text += "var speed = " + str(i.cooldown) + "\n"
		text += "var rangeof = " + str(i.rnge) + "\n"
	if(i.type == "m"):
		text += "var healing = " + str(i.damage) + "\n"
	if(i.type == "f"):
		text += "var flavor = " + str(i.damage) + "\n"
	if(i.type == "a" || i.type == "h"):
		text += "var protections = " + str(i.damage) + "\n"
		
	
	
	text += "var cost = " + str(i.price) + "\n"
	$Label.text = text

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
