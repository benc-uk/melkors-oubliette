extends Spatial
class_name Map

export var width = 10
export var height = 10

var cells
var cell_scene

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
