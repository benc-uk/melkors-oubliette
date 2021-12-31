extends Node

class_name Activator

signal activated
signal deactivated

const ACTIVE = "active"
const INACTIVE = "inactive"

var active: bool = false
var message = ""
var enabled = true

# Toggle true means this will flip between states, like a lever
# False means it only fires activated() events, like a push button
var toggle: bool = false

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
		click_node.connect("input_event", self, "click_handler")
	
	if active: 
		if anim_node != null: anim_node.play("activate")
	
	
func click_handler(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
			if $"/root/main/player".cell != get_parent():
				return
			
			if not toggle:
				activated()
				if anim_node != null: anim_node.queue("deactivate")
			else:
				if active: deactivated()
				else: activated()

func activated():
	if not enabled: return
	
	active = true
	emit_signal("activated")
	if sfx_activate_node != null: sfx_activate_node.play()
	if anim_node != null: anim_node.play("activate")
	for action in actions[ACTIVE]:
		action.execute()

func deactivated():
	if not enabled: return
	
	active = false
	emit_signal("deactivated")
	if sfx_deactivate_node != null: sfx_deactivate_node.play()	
	if anim_node != null: anim_node.play("deactivate")
	for action in actions[INACTIVE]:
		action.execute()
