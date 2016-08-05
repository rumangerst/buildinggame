extends Spatial

func _ready():
		
	var body = StaticBody.new()
	var instance = TestCube.new()
	var collision = CollisionShape.new()
	var shape = BoxShape.new()
	shape.set_extents(Vector3(1,1,1))
	
	add_child(body)
	
	collision.set_shape(shape)
	body.add_child(instance)
	body.add_child(collision)
	body.set_translation(Vector3(-4,0,-4))
	
	print(body.get_rid())
	print(body)
	print(get_node("StaticBody"))