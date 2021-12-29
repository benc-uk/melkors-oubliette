extends Node

class_name Action

var target: Node
var function: String
var params: Array
var sound: String

const TYPE_DOOR = "door"
const TYPE_REMOVE_WALL = "remove_wall"
const TYPE_CELL_DETAIL = "cell_detail"
const TYPE_PLAY_SOUND = "play_sound"

func _init(targ: Node = null, fn: String = "noop", param = [], sfx = ""):
	target = targ
	function = fn 
	params = param
	sound = sfx
	
func execute():
	if target == null:
		print("Action has no target set")
		return
	if function == null || function == "":
		print("Action on ",target, "has no function set")
		return
		
	print("executing action ", function, " on ", target)
		
	if params.size() > 0:
		target.callv(function, params)
	else:
		target.call(function)

func parse(input: Dictionary, map):
	if !input.has("type"): 
		print("Failed to parse action, type is missing")
		return
		
	var target_cell = null
	if input.has("pos"):
		target_cell = map.get_cell(input.pos[0], input.pos[1])
		if target_cell == null && input.type != TYPE_REMOVE_WALL:
			print("Action targets a null cell: ",input.pos[0], ",", input.pos[1])
			return
			
	match input.type:
		TYPE_DOOR:
			if target_cell.door == null: 
				print("Door action targets cell without door: ",input.pos[0], ",", input.pos[1])
				return
			if ["open", "close", "toggle"].has(input.param):
				target = target_cell.door
				function = input.param
		TYPE_REMOVE_WALL:
			target = map
			function = "add_cell"
			params = [input.pos[0], input.pos[1]]
		TYPE_CELL_DETAIL:
			target = target_cell
			if input.param[0] == "add":
				function = "add_center_detail"
				params = [input.param[1], global.stringToCompass(input.pos[2])]
			if input.param[0] == "remove":
				function = "remove_center_detail"
		TYPE_PLAY_SOUND:
			target = target_cell
			function = "play_sound"
			params = [input.param]
		_: 
			print("Action is not a recognized type")
			return
