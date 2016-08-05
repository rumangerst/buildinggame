extends Camera

var rotation_enabled = false
var rotation_mouse_start = Vector2(0, 0)

var pick_distance = 100
var current_pick = { }
var current_below_pick = { }

var limits = Rect2(0,0,0,0)
var height_limits = Vector2(2, 20)

#onready var test_cube = get_node("../TestCube")

func _ready():
	
	set_process(true)
	set_process_input(true)
	set_fixed_process(true)
	
	print("Camera initialized")
	
func limit_translation(pos):
	
	pos.x = max(limits.pos.x, min(limits.pos.x + limits.size.x, pos.x))
	pos.z = max(limits.pos.y, min(limits.pos.y + limits.size.y, pos.z))
		
	# Use tile height as min height
	var min_y = height_limits.x
		
	if not current_below_pick.empty():
		min_y = current_below_pick["position"].y + min_y
		
	pos.y = max(min_y, min(height_limits.y, pos.y))
		
	return pos
	
func update_movement(delta):
	
	var mouse_position = get_viewport().get_mouse_pos()
	var screen_size = get_viewport().get_visible_rect().size
	
	var distance_to_border = mouse_position -  screen_size / 2.0
	var move_x = sign(distance_to_border.x) * max(0, (abs(distance_to_border.x) - screen_size.width / 2.0 + 10)) / 10.0
	var move_y = sign(distance_to_border.y) * max(0, (abs(distance_to_border.y) - screen_size.height / 2.0 + 10)) / 10.0
	
	move_x *= 0.5
	move_y *= 0.5
	
	var pos = get_translation()
	var new_pos = get_transform().translated(Vector3(move_x, 0, move_y)).origin
	var final_pos = Vector3(new_pos.x, pos.y, new_pos.z)
	var limited_final_pos = limit_translation(final_pos)
	
	set_translation(limited_final_pos)
	
func get_look_at_position_at(height):
	
	var cam_pos = get_translation()
	var direction = get_transform().basis.z
		
	var w = (height - cam_pos.y) / direction.y
	var x_hat = cam_pos.x + w * direction.x
	var z_hat = cam_pos.z + w * direction.z
	
	return Vector3(x_hat, height, z_hat)
	
func rotate_camera(delta):
	
	delta *= 0.01
	
	var look_at = get_look_at_position_at(0)
	var s = sin(delta)
	var c = cos(delta)
	
	var t = get_transform()
	t.origin -= look_at
	t.origin = Vector3(t.origin.x * c - t.origin.z * s, t.origin.y, t.origin.x * s + t.origin.z *c)
	t.origin += look_at
	
	t = t.looking_at(look_at, Vector3(0,1,0))
	t.origin = limit_translation(t.origin)
	
	set_transform(t)
	
func update_rotation(delta):
	
	if rotation_enabled:
		
		var mouse_position = get_viewport().get_mouse_pos()
		var distance_h = rotation_mouse_start.x - mouse_position.x
		var distance_v = mouse_position.y - rotation_mouse_start.y		
		
		if abs(distance_h) > 5:
			get_viewport().warp_mouse(rotation_mouse_start)
			rotate_camera(distance_h * delta * 10)
			
		if abs(distance_v) > 5:
			
			get_viewport().warp_mouse(rotation_mouse_start)
			
			var t = get_transform().translated(distance_v * delta * 4 * Vector3(0,1,0)) #down direction
	
			if t.origin == limit_translation(t.origin):
				var look_at = get_look_at_position_at(0)
				t = t.looking_at(look_at, Vector3(0,1,0))
				
				set_transform(t)

func _process(delta):
	
	update_movement(delta)
	update_rotation(delta)
	
func zoom(delta):
	
	var t = get_transform().translated(delta * Vector3(0,0,-1)) #forward direction
	
	if t.origin == limit_translation(t.origin):
		set_transform(t) 
	
func _input(event):
	
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.button_index == BUTTON_WHEEL_UP:
			zoom(1)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			zoom(-1)
		elif event.button_index == BUTTON_MIDDLE:
			
			if event.pressed:
				rotation_mouse_start = get_viewport().get_mouse_pos()
			
			rotation_enabled = event.pressed
		#elif event.button_index == BUTTON_LEFT:
		#	
		#	if not event.pressed:
		#		print(current_pick)
	
func pick_object(origin, normal, far):
	
	var space_state = get_world().get_direct_space_state()
	var destination = origin + normal * far
	
	# use global coordinates, not local to node
	var result = space_state.intersect_ray( origin, destination )
	
	return result
	
func _fixed_process(delta):
	
	var mouse_position = get_viewport().get_mouse_pos()
	current_pick = pick_object(project_ray_origin(mouse_position), project_ray_normal(mouse_position), pick_distance)
	current_below_pick = pick_object(get_global_transform().origin, Vector3(0,-1,0), pick_distance)

func _on_BuildingGameClient_nodes_loaded():
	
	limits = get_tree().get_root().get_node("world/BuildingGameClient").get_world_rect()
	limits.size *= 2	
	
	limits.pos -= Vector2(5, 5)
	limits.size += Vector2(10, 10)
	
	print("Camera limits set to " + str(limits))
