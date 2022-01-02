extends Object

class_name Item

var item_id = ""
var name = "Unknown"
var description = "Unknown item"
var weight = 1.0
var edible = false

# Display properties
var icon = "placeholder"
var resize = 1.0

# Light props
var light_level = null
var light_decay_speed = null

const ITEM_NODE_SCENE = preload("res://item-node.tscn")

func _init(id: String):
	if not global.item_db.has(id):
		id = "_"
		
	var template = global.item_db[id]
	
	item_id = id
	name = template.name
	icon = template.icon
	description = template.description
	resize = template.resize if template.has("resize") else 1.0
	light_level = template.light_level if template.has("light_level") else null
	light_decay_speed = template.light_decay_speed if template.has("light_decay_speed") else null

func make_node():
	var node = ITEM_NODE_SCENE.instance()
	node.item = self
	return node
	
