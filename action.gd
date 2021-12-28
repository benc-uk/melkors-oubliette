extends Node

class_name Action

var target: Node
var function: String
var params: Array

func _init(t: Node = null, f: String = "noop", p = []):
	target = t
	function = f
	params = p
	
func execute():
	print("executing action ",function, " on ", target)
	if params.size() > 0:
		target.callv(function, params)
	else:
		target.call(function)
