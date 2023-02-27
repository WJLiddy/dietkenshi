extends Camera

var zoom = 20
var mouseSens = 0.3
var mouseLookButton = false
var mouseDelta : Vector2 = Vector2()

var clickStartCoord = null
var clickEndCoord = null

func get_camera():
	var r = get_node('/root')
	return r.get_viewport().get_camera()

func _process(delta):
	getHiLight()
	clickEndCoord = get_viewport().get_mouse_position()
	if(mouseLookButton):
		global_transform.origin -= (global_transform.basis.x * mouseSens * mouseDelta.x)
		global_transform.origin += (global_transform.basis.y * mouseSens * mouseDelta.y)

	if(Input.is_action_just_released("mwheel_up") and zoom > 5):
		zoom -= 1
	if(Input.is_action_just_released("mwheel_down") and zoom < 30):
		zoom += 1
	translation = zoom * translation.normalized()
	
	look_at(get_parent().translation, Vector3(0,1,0))
	mouseDelta = Vector2()

func getHiLight():
	var mpos = get_viewport().get_mouse_position()
	var ray_pos = project_ray_origin(mpos)
	var ray_dir = project_ray_normal(mpos)
	var space_state = get_world().direct_space_state
	# Items
	var hit = space_state.intersect_ray(ray_pos, ray_pos + ray_dir * 1000.0, [], 1 << 1, true, true)
	if(hit.has("collider")):
		var item = get_node("../../../DroppedItems").geti(hit["collider"].get_parent())
		# item can be null if it was JUST grabbed, nbd
		if(not item == null):
			get_node("Descriptor").display(item)
	else:
		get_node("Descriptor").hide()
	get_node("Descriptor").set_position(mpos + Vector2(0,10))

func handleTerrainClick():
	var mpos = get_viewport().get_mouse_position()
	var ray_pos = project_ray_origin(mpos)
	var ray_dir = project_ray_normal(mpos)
	var space_state = get_world().direct_space_state
	
	
	# Items
	var hit = space_state.intersect_ray(ray_pos, ray_pos + ray_dir * 1000.0, [], 1 << 1, true, true)
	if(hit.has("collider")):
		get_parent().get_parent().setItemGet(hit["collider"].get_parent())
		return
		
	# Terrains
	hit = space_state.intersect_ray(ray_pos, ray_pos + ray_dir * 1000.0, [], 1 << 0)
	if not hit.empty():
		get_parent().get_parent().set_dest_for_selected(hit.values()[0])

func _unhandled_input(event):
	# Raycasted Click.
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		clickStartCoord = get_viewport().get_mouse_position()

	if event is InputEventMouseButton and !event.pressed and event.button_index == 1:
		if(!get_parent().get_parent().select_region(clickStartCoord,clickEndCoord)):
			handleTerrainClick()
		clickStartCoord = null

	# Determine if held down
	if event is InputEventMouseButton:
		if event.button_index == 2 and event.is_pressed():
			mouseLookButton = true
		elif event.button_index == 2 and not event.is_pressed():
			mouseLookButton = false

	# Monitor mouse delta for camera controls
	if event is InputEventMouseMotion:
		mouseDelta = event.relative
