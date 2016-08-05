extends Control

func _ready():	
	add_user_signal("non_ui_input", [ { "name" : "event", "type" : TYPE_INPUT_EVENT } ])	
	connect("non_ui_input", get_node("BuildingNodePanel"), "input_event")
	
	get_node("BuildingPanel").hide()
	get_node("BuildingNodePanel").hide()

func _input_event(event):
	
	if event.type == InputEvent.MOUSE_BUTTON and not event.is_pressed():
		# close open panels
		get_node("BuildingPanel").hide()
		get_node("BuildingNodePanel").hide()
	
	emit_signal("non_ui_input", event)