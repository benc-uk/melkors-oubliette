extends Spatial

class_name Cell

var player_can_pass: bool
var x: int
var y: int

const CENTER = 4
#var center_detail = null
var details = {
	global.COMPASS.NORTH: null,
	global.COMPASS.EAST: null,
	global.COMPASS.SOUTH: null,
	global.COMPASS.WEST: null,
	CENTER: null,
}
var door = null
var is_pit = false

# For exits
var is_exit = false
var exit_level = ""

const DOOR = preload("res://details/door.tscn")
const SPLAT = preload("res://details/splat.tscn")

func _ready() -> void:	
	player_can_pass = true
	if randf() > 0.4:
		add_splat()
	if randf() > 0.9:
		add_splat()
		
	# Wire up signals for floor clicks
	$floor/items_ne/click_area.connect("input_event", self, "_floor_click_handler", ["ne"])
	$floor/items_se/click_area.connect("input_event", self, "_floor_click_handler", ["se"])
	$floor/items_sw/click_area.connect("input_event", self, "_floor_click_handler", ["sw"])
	$floor/items_nw/click_area.connect("input_event", self, "_floor_click_handler", ["nw"])
	
func remove_wall(wall_facing: int) -> void:
	var dir = global.compass_to_char(wall_facing)
	get_node("wall-" + dir).queue_free()

func add_item(item: Item, stack: String):
	var item_node = item.make_node()
	item_node.translation.x += (randf() * 2) - 1
	item_node.translation.z += (randf() * 2) - 1
	get_node("floor/items_" + stack.to_lower()).add_child(item_node)

func open_pit():
	is_pit = true
	player_can_pass = false
	$floor.visible = false
	$pit.visible = true
	
func close_pit():
	is_pit = false
	player_can_pass = true
	$floor.visible = true
	$pit.visible = false

func set_as_exit(to_level: String, dir: int = global.COMPASS.NORTH):
	is_exit = true
	exit_level = to_level
	add_detail("exit", dir)
	
func add_detail(type: String, slot: int = global.COMPASS.NORTH):
	if door || details[slot]:
		print("### Cell warning: Illegal placement of %s at %s,%s" % [name, x, y])
		return
		
	var scene = load("res://details/%s.tscn" % type)
	if !scene: 
		print("### Cell warning: Detail with type '%s' doesn't exist. Skipping" % type)
		return null
	var detail = scene.instance()
	details[slot] = detail
	
	if slot == CENTER:
		player_can_pass = false
	else:
		detail.rotate_y(global.DIRECTIONS[slot])
		
	add_child(detail)
		
	return detail

func remove_center_detail():
	if !details[CENTER]: return
	
	details[CENTER].queue_free()
	player_can_pass = true
	details[CENTER] = null
	
func is_cell_adjacent(another_cell: Cell) -> bool:
	if abs(another_cell.x - x) <= 1 && abs(another_cell.y - y) <= 1: return true
	return false
	
func add_door(direction: int, type: int = Door.types.WOOD, open: bool = true, buttons: bool = true):
	if details[CENTER] || door:
		print("### Cell warning: Illegal placement of door at %s,%s" % [x, y])
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
	$floor.add_child(splat)

func play_sound(filename: String):
	var sfx = AudioStreamPlayer3D.new()
	sfx.unit_db = 20
	sfx.stream = load("res://sound/"+filename)
	add_child(sfx)
	sfx.play()
	yield(sfx, "finished")
	sfx.queue_free()
	
func to_string():
	return "x: " + str(x) + ", y:" + str(y)
	
func _floor_click_handler(camera, event, position, normal, shape_idx, floor_stack):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
			# can't place floor items if a center detail is present
			if details[CENTER]: return
			
			if $"/root/main/player".in_hand != null:
				add_item($"/root/main/player".in_hand, floor_stack)
				$"/root/main/player".remove_held_item()
