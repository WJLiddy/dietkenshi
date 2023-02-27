extends Label

var point = Vector3()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var basecol = Color()

var RENDER_DIST = 100

func get_camera():
	var r = get_node('/root')
	return r.get_viewport().get_camera()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	startTween()

func startTween():
	$Tween.interpolate_property(self, "modulate", basecol, Color(1, 1, 1, 0), 4.0,Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	yield($Tween,"tween_completed")
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var camera = get_camera()
	if(abs(camera.global_transform.origin.x - point.x) + abs(camera.global_transform.origin.z - point.z) > RENDER_DIST):
		queue_free()
	point += Vector3(0,delta,0)
	var cam_pos = camera.translation
	var offset = Vector2(get_size().x/2, 0)
	rect_position = camera.unproject_position(point) - offset
