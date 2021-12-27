extends Spatial

class_name Switch

signal activated

export var is_toggle = false
export var active = false

func activate():
	if is_toggle:
		active = !active
	emit_signal("activated")
