extends Object

class_name Monster

const MON_NODE_SCENE = preload("res://monster-node.tscn")
var sprite: String
var sprite_scale: float
var sprite_opacity: float
var monster_id: String
var name: String

func _init(id: String):
	if !global.monster_db.has(id):
		return
		
	var template = global.monster_db[id]
	
	monster_id = id
	name = template.name
	sprite = template.sprite
	sprite_scale = template.sprite_scale if template.has("sprite_scale") else 1.0
	sprite_opacity = template.sprite_opacity if template.has("sprite_opacity") else 1.0
	
func make_node():
	var node = MON_NODE_SCENE.instance()
	node.monster = self
	return node
