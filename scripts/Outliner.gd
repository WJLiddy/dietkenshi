extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func _draw():
	var s = get_parent().clickStartCoord
	var e = get_parent().clickEndCoord
	#clickStartCoord
	if(s != null and e != null):
		if(get_node("../../../").will_start_combat()):
			draw_rect(Rect2(s,e - s),Color(1,0,0,1), false)
		else:
			draw_rect(Rect2(s,e - s),Color(1,1,1,1), false)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()
