extends Spatial

class_name Map

export var width = 100
export var height = 100

# Big old global array of all the cells in the map
var cells

const CELL_SCENE = preload("res://cell.tscn")

func _ready():
	cells = []
	for y in range(height):
		cells.append([])
		for _x in range(width):
			cells[y].append(null)

func add_cell(x: int, y: int) -> void:
	if x > width - 1 or y > height - 1:
		return

	var cell = CELL_SCENE.instance()

	var check_cell := get_cell(x + 1, y)
	if check_cell != null:
		cell.remove_wall(global.COMPASS.WEST)
		check_cell.remove_wall(global.COMPASS.EAST)
		
	check_cell = get_cell(x - 1, y)
	if check_cell != null:
		cell.remove_wall(global.COMPASS.EAST)
		check_cell.remove_wall(global.COMPASS.WEST)
		
	check_cell = get_cell(x, y + 1)
	if check_cell != null:
		cell.remove_wall(global.COMPASS.NORTH)
		check_cell.remove_wall(global.COMPASS.SOUTH)
		
	check_cell = get_cell(x, y - 1)
	if check_cell != null:
		cell.remove_wall(global.COMPASS.SOUTH)
		check_cell.remove_wall(global.COMPASS.NORTH)

	# Incredibly important steps
	cell.translate(Vector3(x * global.CELL_SIZE, 0, y * global.CELL_SIZE))
	cells[x][y] = cell
	cell.x = x
	cell.y = y
	add_child(cell)

func get_cell(x: int, y: int) -> Cell:
	if x < 0 or y < 0:
		return null
	if x > width - 1 or y > height - 1: 
		return null

	return cells[x][y]

func parse_level(level: Dictionary):
	var map_array = level.map.split("\n", true, 0)
	var x = 0
	var y = 0
	for map_line in map_array:
		x = 0
		# Comment lines can start with "'"
		if map_line.substr(0,1) == "'": continue
		for map_cell in map_line:
			match map_cell:
				"#": add_cell(x, y)
				"O": add_cell(x, y)
			x = x + 1
		y = y + 1
	
	if level.has("doors"):
		for door in level.doors:
			var dir = global.stringToCompass(door.pos[2])
			var type = Door.types.WOOD if !door.has("type") else door.type
			var open = false if !door.has("open") else door.open
			var buttons = false if !door.has("buttons") else door.buttons
			get_cell(door.pos[0], door.pos[1]).add_door(dir, type, open, buttons)

	if level.has("push_switches"):
		for switch in level.push_switches:
			var dir = global.stringToCompass(switch.pos[2])
			var cell = get_cell(switch.pos[0], switch.pos[1])
			var switch_node
			if cell != null:
				switch_node = cell.add_wall_furnishing("push-switch", dir)
			else:
				print("Error in parse_level! Tried to place push_switch in null cell: ", switch.pos[0], ",", switch.pos[1])
				return

			if switch.has("pressed"):
				if switch.pressed.target.to_lower() == "door":
					switch_node.action = Action.new(get_cell(switch.pressed.pos[0], switch.pressed.pos[1]).door, switch.pressed.action)
				if switch.pressed.target.to_lower() == "map":
					switch_node.action = Action.new($"/root/Main/Map", switch.pressed.action, switch.pressed.params)
				
	if level.has("wall_furnishings"):
		for furn in level.wall_furnishings:
			var dir = global.stringToCompass(furn.pos[2])
			var cell = get_cell(furn.pos[0], furn.pos[1])
			if cell != null:
				var furn_node = cell.add_wall_furnishing(furn.type, dir)
				if furn.type == "sign" && furn.has("message"): furn_node.message = furn.message
			else:
				print("Error in parse_level! Tried to place wall_furnishing in null cell: ", furn.pos[0], ",", furn.pos[1])

	if level.has("center_furnishings"):
		for furn in level.center_furnishings:
			var dir = global.stringToCompass(furn.pos[2])
			var cell = get_cell(furn.pos[0], furn.pos[1])
			if cell != null:
				cell.add_center_furnishing(furn.type, dir)
			else:
				print("Error in parse_level! Tried to place center_furnishing in null cell: ", furn.pos[0], ",", furn.pos[1])

