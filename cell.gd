extends Spatial

class_name Cell

var player_can_pass: bool
var x: int
var y: int

var center_furnishing = null
var wall_furnishings = [null, null, null, null]
var door = null

const WALL_FURN = {
	"torch": preload("res://deco/torch.tscn"),
	"crates": preload("res://deco/crates.tscn"),
	"push-switch": preload("res://deco/push-switch.tscn"),
}

const CENTER_FURN = {
	"pillar": preload("res://deco/pillar.tscn")
}

const DOOR = preload("res://deco/door.tscn")
const SPLAT = preload("res://deco/splat.tscn")

func _ready() -> void:
	player_can_pass = true
	randomize()
	if randf() > 0.4:
		add_splat()
	if randf() > 0.8:
		add_splat()
		
func remove_wall(wall_facing: int) -> void:
	get_node("wall-%d" % wall_facing).queue_free()

func add_wall_furnishing(name: String, direction: int = global.COMPASS.NORTH):
	if wall_furnishings[direction] != null or door != null: 
		print("Illegal placement of ", name, " at ", x, ", ", y)
		return
	var furn: Spatial = WALL_FURN[name].instance()
	if name == "pillar": player_can_pass = false
	add_child(furn)
	furn.rotate_y(global.DIRECTIONS[direction])
	wall_furnishings[direction] = furn
	return furn

func add_center_furnishing(name: String, direction: int = global.COMPASS.NORTH):
	if center_furnishing != null or door != null: 
		print("Illegal placement of ", name, " at ", x, ", ", y)
		return
	var furn: Spatial = CENTER_FURN[name].instance()
	player_can_pass = false
	add_child(furn)
	furn.rotate_y(global.DIRECTIONS[direction])
	center_furnishing = furn
	return furn
	
func add_door(direction: int, type: int, open: bool = true, switch1: bool = true, switch2: bool = true):
	if center_furnishing != null or door != null:
		print("Illegal placement of door at ", x, ", ", y)
		return
	var door = DOOR.instance()
	door.type = type
	door.open = open
	door.has_switch2 = switch2
	door.has_switch2 = switch2
	add_child(door)
	
	door.rotate_y(global.DIRECTIONS[direction])
	
	return door

func add_splat():
	var splat = SPLAT.instance()
	var type = randi() % 4
	if type == 0: splat.blood()
	if type == 1: splat.mud()
	if type == 2: splat.water()
	if type == 3: splat.grey()
	splat.translation.x += (randf()* global.HALF_CELL_SIZE) - global.HALF_CELL_SIZE
	splat.translation.z += (randf()* global.HALF_CELL_SIZE) - global.HALF_CELL_SIZE
	add_child(splat)