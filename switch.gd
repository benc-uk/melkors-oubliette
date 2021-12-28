extends Spatial

class_name Switch

signal activated

export var is_toggle = false
export var active = false
var action: Action

func activate():
	if is_toggle:
		active = !active
	emit_signal("activated")
	if action != null:
		action.execute()
