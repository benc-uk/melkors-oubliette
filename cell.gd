extends Spatial

class_name Cell

var player_can_pass: bool
var x: int
var y: int

var center_detail = null
var wall_details = [null, null, null, null]
var door = null
var is_pit = false



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
	var d = global.compass_to_char(wall_facing)
	get_node("wall-" + d).queue_free()

func add_item(item: Item, stack: String):
	var item_node = item.make_node()
	item_node.translation.x += (randf() * 4) - 2
	item_node.translation.z += (randf() * 4) - 2
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
		
func add_wall_detail(name: String, direction: int = global.COMPASS.NORTH):
	if wall_details[direction] != null or door != null: 
		print("### Cell warning: Illegal placement of ", name, " at ", x, ", ", y)
		return
	var detail: Spatial = WALL_DETAILS[name].instance()
	add_child(detail)
	detail.rotate_y(global.DIRECTIONS[direction])
	wall_details[direction] = detail
	return detail

func add_center_detail(name: String, direction: int = global.COMPASS.NORTH):
	if center_detail != null or door != null: 
		print("### Cell warning: Illegal placement of ", name, " at ", x, ", ", y)
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
		print("### Cell warning: Illegal placement of door at ", x, ", ", y)
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
	pass
	
func to_string():
	return "x: "+str(x)+", y:"+str(y)
	
func _floor_click_handler(camera, event, position, normal, shape_idx, floor_stack):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
			print("shape_idx ", shape_idx)
			if $"/root/main".in_hand != null:
				#var node = $"/root/main".in_hand.make_node()
				add_item($"/root/main".in_hand, floor_stack)
				$"/root/main".in_hand = null
				#floor_stack.add_child(node)
				
				#Input.set_custom_mouse_cursor(load("res://hud/cursor-hand.png"))
				$"/root/main/cursor".texture = load("res://hud/cursor-hand.png")
