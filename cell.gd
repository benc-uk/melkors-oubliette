extends Spatial

class_name Cell

var player_can_pass: bool
var x: int
var y: int

var center_detail = null
var wall_details = [null, null, null, null]
var door = null

const WALL_DETAILS = {
	"torch": preload("res://deco/torch.tscn"),
	
	# Cosmetic
	"crates": preload("res://deco/crates.tscn"),
	"pipe-hole": preload("res://deco/pipe-hole.tscn"),
	"rubble": preload("res://deco/rubble.tscn"),
	
	# Activators
	"sign": preload("res://deco/sign.tscn"),
	"push-switch": preload("res://deco/push-switch.tscn"),
	"lever": preload("res://deco/lever.tscn"),
}

const CENTER_DETAILS = {
	"pillar": preload("res://deco/pillar.tscn"),
	"stone-block": preload("res://deco/stone-block.tscn")
}

const DOOR = preload("res://deco/door.tscn")
const SPLAT = preload("res://deco/splat.tscn")

func _ready() -> void:
	player_can_pass = true
	randomize()
	if randf() > 0.4:
		add_splat()
	if randf() > 0.9:
		add_splat()
		
func remove_wall(wall_facing: int) -> void:
	get_node("wall-%d" % wall_facing).queue_free()

func add_wall_detail(name: String, direction: int = global.COMPASS.NORTH):
	if wall_details[direction] != null or door != null: 
		print("Illegal placement of ", name, " at ", x, ", ", y)
		return
	var detail: Spatial = WALL_DETAILS[name].instance()
	add_child(detail)
	detail.rotate_y(global.DIRECTIONS[direction])
	wall_details[direction] = detail
	return detail

func add_center_detail(name: String, direction: int = global.COMPASS.NORTH):
	if center_detail != null or door != null: 
		print("Illegal placement of ", name, " at ", x, ", ", y)
		return
	center_detail = CENTER_DETAILS[name].instance()
	player_can_pass = false
	add_child(center_detail)
	center_detail.rotate_y(global.DIRECTIONS[direction])
	return center_detail

func remove_center_detail():
	if center_detail == null: return
	
	center_detail.queue_free()
	player_can_pass = true
	center_detail = null
	
func add_door(direction: int, type: int = Door.types.WOOD, open: bool = true, buttons: bool = true):
	if center_detail != null or door != null:
		print("Illegal placement of door at ", x, ", ", y)
		return
	door = DOOR.instance()
	door.type = type
	door.opened = open
	door.has_buttons = buttons
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

func play_sound(filename: String):
	var sfx = AudioStreamPlayer3D.new()
	sfx.unit_db = 20
	sfx.stream = load("res://sound/"+filename)
	add_child(sfx)
	sfx.play()
	pass
	
func to_string():
	return "x: "+str(x)+", y:"+str(y)
	
