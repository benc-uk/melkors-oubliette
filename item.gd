extends Object

class_name Item

var name = "Unknown"
var description = "Unknown item"
var weight = 1.0
var edible = false

var icon = "placeholder"
var resize = 1.0

const ITEM_NODE_SCENE = preload("res://item-node.tscn")

func _init(id: String):
	if not global.item_db.has(id):
		id = "_"
		
	var template = global.item_db[id]
	
	name = template.name
	icon = template.icon
	description = template.description
	resize = template.resize if template.has("resize") else 1.0

func make_node():
	var node = ITEM_NODE_SCENE.instance()
	node.item = self
	return node
	
