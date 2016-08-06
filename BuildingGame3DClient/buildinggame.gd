extends BuildingGameClient

func read_file_contents(filename):
	
	var f = File.new()
	f.open(filename, f.READ)
	var content = f.get_as_text()
	f.close()
	
	return content

func _ready():
	
	load_mod("res://Game")
	#load_nodes(read_file_contents("user://minimal.json"))
	
	randomize()
	generate_nodes(read_file_contents("res://TerrainGenerator/default.json"), 40, 40, randi())
	
func build_mode(building_type):
	
	# delete existing building ghost
	
	if has_node("BuildingGhost"):
		print("Removing existing building ghost")
		remove_child(get_node("BuildingGhost"))
		
	# create a new one
	if building_type != null:
		
		print("Creating new building ghost of " + building_type.get_id())
		
		var instance = load("building_node_ghost.tscn").instance()
		instance.set_name("BuildingGhost")
		instance.set_definition(building_type)
		
		# connect necessary events
		get_tree().get_root().get_node("world/GUI").connect("non_ui_input", instance, "input_event")
		
		add_child(instance)

func _on_SimulationSpeed_value_changed( value ):
	
	value = int(value)	
	simulation_set_speed(value)
