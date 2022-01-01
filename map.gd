extends Spatial

class_name Map

export var width = 100
export var height = 100

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

func parse_level(level: Dictionary):
	var map_array = level.map.split("\n", true, 0)
	var x = 0
	var y = 0
	for map_line in map_array:
		x = 0
		# Comment lines can start with '
		if map_line.substr(0,1) == "'": continue
		for map_cell in map_line:
			match map_cell:
				"#", "O", "*", "0", "@": add_cell(x, y)
				"x", "X": 
					add_cell(x, y)
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

	if level.has("activators"):
		for act in level.activators:
			var dir = global.str_to_compass(act.pos[2])
			var cell = get_cell(act.pos[0], act.pos[1])
			var node
			if cell != null:
				match act.type:
					"push": node = cell.add_wall_detail("push-switch", dir)
					"lever": node = cell.add_wall_detail("lever", dir)
					_: 
						print("### Parse error: Invalid activator type")
						continue
				if act.has("states"):
					if act.states.has("activated"):
						for activated_action in act.states.activated:
							var action = Action.new()
							action.parse(activated_action, self)
							node.actions[Activator.ACTIVE].append(action)
					if act.states.has("deactivated"):
						for deactivated_action in act.states.deactivated:
							var action = Action.new()
							action.parse(deactivated_action, self)
							node.actions[Activator.INACTIVE].append(action)
			else:
				print("### Parse error: Tried to place activators in null cell: ", act.pos[0], ",", act.pos[1])
				continue

	if level.has("wall_details"):
		for detail in level.wall_details:
			var dir = global.str_to_compass(detail.pos[2])
			var cell = get_cell(detail.pos[0], detail.pos[1])
			if cell != null:
				var detail_node = cell.add_wall_detail(detail.type, dir)

				if detail.type == "sign" && detail.has("message"): 
					detail_node.set_message(detail.message)
			else:
				print("### Parse error: Tried to place wall_detail in null cell: ", detail.pos[0], ",", detail.pos[1])

	if level.has("center_details"):
		for detail in level.center_details:
			var dir = global.str_to_compass(detail.pos[2])
			var cell = get_cell(detail.pos[0], detail.pos[1])
			if cell != null:
				cell.add_center_detail(detail.type, dir)
			else:
				print("### Parse error: Tried to place center_detail in null cell: ", detail.pos[0], ",", detail.pos[1])

	if level.has("items"):
		for item in level.items:
			var item_object: Item = Item.new(item.id)
			var cell = get_cell(item.pos[0], item.pos[1])
			cell.add_item(item_object, item.pos[2])
