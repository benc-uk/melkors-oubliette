extends Node

class_name Activator

signal activated
signal deactivated

var active: bool = false
var message = ""
var enabled = true
var is_container = false

# Toggle true means this will flip between states, like a lever
# False means it only fires activated() events, like a push button
var toggle: bool = false

const ACTIVE = "active"
const INACTIVE = "inactive"
var actions = {
	ACTIVE: [],
	INACTIVE: []
}

var click_node
var sfx_activate_node
var sfx_deactivate_node
var anim_node

func _init():
	actions[ACTIVE] = []
	actions[INACTIVE] = []

func _ready():
	click_node = find_node("click-area")
	sfx_activate_node = get_node("sfx-activate") if has_node("sfx-activate") else null
	sfx_deactivate_node = get_node("sfx-deactivate") if has_node("sfx-deactivate") else null
	anim_node = get_node("anim") if has_node("anim") else null

	if click_node != null:
		click_node.connect("input_event", self, "_click_handler")
	
	if active: 
		if anim_node != null: anim_node.play("activate")
	
func get_cell() -> Cell:
	var par = get_parent()
	while par:
		if par.name.begins_with("@cell") || par.name.begins_with("cell"): return par
		par = par.get_parent()
	return null
	
func _click_handler(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
			# Check adjacency
			if !get_cell().is_cell_adjacent($"/root/main/player".cell):
				return
			
			if not toggle:
				_activated()
				if anim_node != null: anim_node.queue("deactivate")
			else:
				if active: _deactivated()
				else: _activated()

func _activated():
	if not enabled: return
	
	for action in actions[ACTIVE]:
		var res = action.execute([$"/root/main/map", $"/root/main/player", $"/root/main"], self)
		if action.has_execute_failed():
			print("### Error! Action failed!")
		else:
			if typeof(res) == TYPE_BOOL && res == false:
				# abort action chain
				return		

	if sfx_activate_node != null: sfx_activate_node.play()
	if anim_node != null: anim_node.play("activate")
	active = true
	emit_signal("activated")

func _deactivated():
	if not enabled: return
  
	for action in actions[INACTIVE]:
		var res = action.execute([$"/root/main/map", $"/root/main/player", $"/root/main"], self)
		if action.has_execute_failed():
			print("### Error! Action failed!")
		else:
			if typeof(res) == TYPE_BOOL && res == false:
				# abort action chain
				return		
			
		if sfx_deactivate_node != null: sfx_deactivate_node.play()	
		if anim_node != null: anim_node.play("deactivate")		
		active = false
		emit_signal("deactivated")

func _add_action(expression_str: String, state: String, at_front = false):
	var expr = Expression.new()
	var res = expr.parse(expression_str, ["map", "player", "main"])
	if res != OK:
		print(res)
	else:
		if at_front: 
			actions[state].push_front(expr)
		else:
			actions[state].append(expr)

#
# Helper functions to be used by actions
#
func create_item(id: String) -> Item:
	return Item.new(id)
