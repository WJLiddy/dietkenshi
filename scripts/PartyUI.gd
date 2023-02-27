extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var shownactors = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var t = 0
	for i in get_node("Buttons").get_children():
		i.connect("pressed", self, "changeBev", [t])
		t += 1
	t = 0
	for i in get_node("ButtonsChar").get_children():
		i.connect("pressed", self, "changeChar", [t])
		t += 1

func changeChar(t):
	get_node("../../Actors").selectSingleActor(t)

func hideButtons():
	for i in get_node("Buttons").get_children():
		i.visible = false
		
	for i in get_node("ButtonsChar").get_children():
		i.visible = false

func changeBev(t):
	shownactors[t].incrBehavior()
	updateL(shownactors)

func updateL(actors):
	shownactors = actors
	hideButtons()
	var cnt = 0
	var text1 = ""
	var text2 = ""
	
	for i in actors:
		get_node("Buttons").get_node("Button"+str(cnt+1)).visible = true
		get_node("Buttons").get_node("Button"+str(cnt+1)).text = i.behavior
		
		get_node("ButtonsChar").get_node("Button"+str(cnt+1)).visible = true
		get_node("ButtonsChar").get_node("Button"+str(cnt+1)).text = str(cnt+1) + ". " + i.charname 

		cnt += 1
