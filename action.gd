extends Node

class_name Action

var target
var function: String
var params: Array
var sound: String

const TYPE_DOOR = "door"
const TYPE_REMOVE_WALL = "remove_wall"
const TYPE_CELL_DETAIL = "cell_detail"
const TYPE_PLAY_SOUND = "play_sound"
const TYPE_CHECK_IN_HAND = "check_in_hand"
const TYPE_REMOVE_ITEM_IN_HAND = "remove_held_item"
const TYPE_CHECK_HOLDS_ITEM = "check_holds_item"

func _init(targ = null, fn: String = "noop", param = [], sfx = ""):
	target = targ
	function = fn 
	params = param
	sound = sfx
	
func execute(activator, map, player):
	if target == null:
		print("### Action execution error: no target set")
		return
	if function == null || function == "":
		print("### Action execution error: ", target, " has no function set")
		return
	if typeof(target) == TYPE_STRING and target == "get_player":
		target = player
	if typeof(target) == TYPE_STRING and target == "get_activator":
		target = activator	
		
	print("+++ Executing action ", function, " on ", target)

	if params.size() > 0:
		return target.callv(function, params)
	else:
		return target.call(function)

func parse(input: Dictionary, map):
	if !input.has("type"): 
		print("### Parse error: Failed to parse action, type is missing")
		return
		
	var target_cell = null
	if input.has("pos"):
		target_cell = map.get_cell(input.pos[0], input.pos[1])
		if target_cell == null && input.type != TYPE_REMOVE_WALL:
			print("### Parse error: Action targets a null cell: ",input.pos[0], ",", input.pos[1])
			return
			
	match input.type:
		TYPE_DOOR:
			if target_cell.door == null: 
				print("### Parse error: Door action targets cell without door: ",input.pos[0], ",", input.pos[1])
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
				params = [input.param[1], global.str_to_compass(input.pos[2])]
			if input.param[0] == "remove":
				function = "remove_center_detail"
		TYPE_PLAY_SOUND:
			target = target_cell
			function = "play_sound"
			params = [input.param]
		TYPE_CHECK_IN_HAND:
			target = "get_player"
			function = "is_in_hand"
			params = [input.param]
		TYPE_REMOVE_ITEM_IN_HAND:
			target = "get_player"
			function = "remove_item_in_hand"
		TYPE_CHECK_HOLDS_ITEM:
			target = "get_activator"
			function = "contains_item_id"
			params = [input.param]			
		_: 
			print("### Parse error: Action is not a recognized type")
			return
