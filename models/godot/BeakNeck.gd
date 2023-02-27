extends "res://scripts/KenshitUnit.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	faction = "beakneck"

func _process(delta):
	# ALWAYS put on ground
	putOnGround()
	
