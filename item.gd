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
var charge = null
var held_time = 0
var charge_decay_expr = null

const ITEM_NODE_SCENE = preload("res://item-node.tscn")
const TORCH_ID = "torch"

func _init(id: String):
	if !global.item_db.has(id):
		id = "_"
		
	var template = global.item_db[id]
	
	item_id = id
	name = template.name
	icon = template.icon
	description = template.description
	resize = template.resize if template.has("resize") else 1.0
	charge = template.charge if template.has("charge") else null
	if template.has("charge_decay_fn"):
		charge_decay_expr = Expression.new()
		charge_decay_expr.parse(template.charge_decay_fn, ["t"])

func make_node():
	var node = ITEM_NODE_SCENE.instance()
	node.item = self
	return node
	
func update_charge(t_held_delta: float):
	held_time += t_held_delta
	if charge:
		var r = charge_decay_expr.execute([held_time])
		charge = max(0, r) 
