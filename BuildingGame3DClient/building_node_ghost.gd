extends Spatial

var instance = null
var definition = null
var orientation = 0

func _ready():
	
	set_fixed_process(true)
	set_process_input(true)
	
func position_against(object):
	set_translation(object.get_translation() + Vector3(0, 0.25, 0))

func build():
	
	if get_parent() == null:
		return
	
	if definition != null:
		var game_node = get_parent()
		var pos = get_translation() / 2.0
		pos = Vector2(pos.x, pos.z)
				
		print("Building now at " + str(pos) + " of " + definition.get_id() )
		game_node.build(pos, orientation, definition.get_id(), "player")
		
	self.queue_free()
	
func _fixed_process(delta):
	
	# update the rotation
	set_rotation_deg(Vector3(0, orientation * 90, 0))
	
	# the position must be updated
	var camera = get_tree().get_root().get_node("world/Camera")
	
	if camera != null:
		var current_pick = camera.current_pick
		
		if not current_pick.empty():
			var obj = current_pick["collider"]
			
			if obj != null:
				obj = obj.get_parent()
			
			if obj != null and obj != instance: 
				position_against(obj)
	

func input_event(event):
	
	if event.type == InputEvent.MOUSE_BUTTON and not event.is_pressed():
		
		if event.button_index == BUTTON_LEFT:
			build()
		elif event.button_index == BUTTON_RIGHT and get_parent() != null:
			get_parent().remove_child(self)
	
			
func _input(event):
	
	if event.type == InputEvent.KEY and not event.is_pressed():
		
		if event.scancode == KEY_SPACE:
			orientation = (orientation + 1) % 4

#Sets the building type that should be represented by this ghost
func set_definition(definition):
	
	self.definition = definition	
	instance = definition.get_first_scene().instance()
	
	#instance.set_ghost()
	
	add_child(instance)
	