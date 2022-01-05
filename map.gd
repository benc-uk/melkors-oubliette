extends Spatial

class_name Map
signal map_parsed

export var width = 100
export var height = 100
export var is_flooded = false

# Big old global array of all the cells in the map
var cells

const CELL_SCENE = preload("res://cell.tscn")

func _init():
	cells = []
	for y in range(height):
		cells.append([])
		for _x in range(width):
			cells[y].append(null)
			
func add_cell(x: int, y: int) -> Cell:
	if x > width - 1 or y > height - 1:
		return null

	if get_cell(x, y) != null:
		print("### add_cell warning, cell already exists at: ", x, ",", y)
		return null
		
	var cell = CELL_SCENE.instance()
	if is_flooded: cell.get_node("water").visible = true

	var check_cell := get_cell(x + 1, y)
	if check_cell != null:
		cell.remove_wall(global.COMPASS.EAST)
		check_cell.remove_wall(global.COMPASS.WEST)
		
	check_cell = get_cell(x - 1, y)
	if check_cell != null:
		cell.remove_wall(global.COMPASS.WEST)
		check_cell.remove_wall(global.COMPASS.EAST)
		
	check_cell = get_cell(x, y + 1)
	if check_cell != null:
		cell.remove_wall(global.COMPASS.SOUTH)
		check_cell.remove_wall(global.COMPASS.NORTH)
		
	check_cell = get_cell(x, y - 1)
	if check_cell != null:
		cell.remove_wall(global.COMPASS.NORTH)
		check_cell.remove_wall(global.COMPASS.SOUTH)

	# Incredibly important steps
	cell.translate(Vector3(x * global.CELL_SIZE, 0, y * global.CELL_SIZE))
	cells[x][y] = cell
	cell.x = x
	cell.y = y
	add_child(cell)
	return cell

func get_cell(x: int, y: int) -> Cell:
	if x < 0 or y < 0:
		return null
	if x > width - 1 or y > height - 1: 
		return null

	return cells[x][y]

func at(x: int, y: int) -> Cell:
	return get_cell(x, y)
	
func door(x: int, y: int) -> Door:
	var cell = at(x, y)
	if cell:
		return cell.door
	print("### Warning! No door at %s, %s" % [x, y])
	return null
	
func parse_level(level: Dictionary):
	if level.has("flags"):
		if level.flags.has("flooded"): is_flooded = level.flags.flooded
			
	var map_array = level.map.split("\n", true, 0)
	var x = 0
	var y = 0
	for map_line in map_array:
		x = 0
		# Comment lines can start with '
		if map_line.substr(0,1) == "'": continue
		for map_cell in map_line:
			match map_cell:
				"#", "O", "*", "0", "@": var _n = add_cell(x, y)
				"x", "X": 
					var _n = add_cell(x, y)
					get_cell(x, y).open_pit()
			x = x + 1
		y = y + 1
	
	if level.has("doors"):
		for door in level.doors:
			var dir = global.str_to_compass(door.pos[2])
			var type = Door.types.WOOD if !door.has("type") else door.type
			var open = false if !door.has("open") else door.open
			var buttons = false if !door.has("buttons") else door.buttons
			var target_cell = get_cell(door.pos[0], door.pos[1])
			if target_cell != null: target_cell.add_door(dir, type, open, buttons)
			else:
				print("### Parse error: Tried to add a door in a null cell: ",door.pos[0], ",", door.pos[1])

	if level.has("details"):
		for detail in level.details:
			var cell = get_cell(detail.pos[0], detail.pos[1])
			var dir
			var node
			if cell:
				# Handle center details, where dir is used differently
				if detail.type.begins_with("center/"):
					dir = Cell.CENTER
				else:
					dir = global.str_to_compass(detail.pos[2])

				node = cell.add_detail(detail.type, dir)		
				if !node: continue
				
				if node.get_script() and node.is_container and detail.has("holds"):
					for item in detail.holds:
						node.add_new_item(item.id)
						
				if detail.has("states"):
					if detail.states.has("activated"):
						for action_cmd in detail.states.activated:
							node._add_action(action_cmd, Activator.ACTIVE)
					if detail.states.has("deactivated"):
						for action_cmd in detail.states.deactivated:
							node._add_action(action_cmd, Activator.INACTIVE)
							
				if detail.has("message"): 
					node.message = detail.message
					node._add_action("main.show_message(message, 6)", Activator.ACTIVE)
			else:
				print("### Parse error: Tried to place detail in null cell: ", detail.pos[0], ",", detail.pos[1])
				continue

	if level.has("items"):
		for item in level.items:
			var item_object: Item = Item.new(item.id)
			var cell = get_cell(item.pos[0], item.pos[1])
			cell.add_item(item_object, item.pos[2])
			
	if level.has("exit"):
		var exit_cell = get_cell(level.exit.pos[0], level.exit.pos[1])
		exit_cell.set_as_exit(level.exit.to, global.str_to_compass(level.exit.pos[2]))
		
	emit_signal("map_parsed")
