extends Spatial
class_name Player

const CURSOR_HAND = preload("res://hud/cursor-hand.png")

export var CAM_HEIGHT = 6.5
export var CAM_BACK = 3
export var TURN_SPEED = 0.3
export var MOVE_SPEED = 0.4
export var NEAR_LIGHT_ENERGY = 10

# Light scaling
export var light_level = 0.0
#const LIGHT_DECAY_SPEED = 30
## Set to 1.0 to disable
const LIGHT_DECAY_AMOUNT = 1.006

var facing
var map: Map
var cell: Cell
var noise: OpenSimplexNoise
var noise2: OpenSimplexNoise
var elapsed: float
var clip_cheat = true
var in_map = false

const LEFT_HAND = "left_hand"
const RIGHT_HAND = "right_hand"
const TORCH_ITEM_ID = "torch"
var inventory = {
	LEFT_HAND: Item,
	RIGHT_HAND: Item
}

const FOOT_SFX = [
	preload("res://sound/player_footstep01.wav"), 
	preload("res://sound/player_footstep02.wav"),
	preload("res://sound/player_footstep03.wav"),
	preload("res://sound/player_footstep04.wav")
]

var in_hand: Item = null

func _init():
	inventory[LEFT_HAND] = null
	inventory[RIGHT_HAND] = null
	
func _ready():
	$camera.translate(Vector3(0, CAM_HEIGHT, CAM_BACK))
	$torch_far.translate(Vector3(0, CAM_HEIGHT, 0))
	$torch_near.translate(Vector3(0, CAM_HEIGHT, 0))
	
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 1
	noise.period = 1.2
	noise2 = OpenSimplexNoise.new()
	noise2.seed = randi()
	noise2.octaves = 1
	noise2.period = 0.5
	# This is a increasing value used to "walk" the noise
	elapsed = 0

func _process(delta):
	# sub-function for input scanning
	_process_input()
	
	elapsed = elapsed + delta
	if inventory[LEFT_HAND] != null and inventory[LEFT_HAND].item_id == TORCH_ITEM_ID:
		inventory[LEFT_HAND].update_charge(delta)
		light_level = inventory[LEFT_HAND].charge
	elif inventory[RIGHT_HAND] != null and inventory[RIGHT_HAND].item_id == TORCH_ITEM_ID:
		inventory[RIGHT_HAND].update_charge(delta)
		light_level = inventory[RIGHT_HAND].charge
	else:
		light_level = 0.0
	
	# Fake flame/flicker, move light randomly and alter light brightness
	var light_modifier = (noise.get_noise_1d(elapsed) + 1) / 2
	$torch_far.light_energy = (light_modifier * 8 * light_level)
	$torch_near.light_energy = NEAR_LIGHT_ENERGY * light_level
	var new_height = CAM_HEIGHT + noise2.get_noise_1d(elapsed) * 1.5
	var new_x = 0 + noise2.get_noise_1d(elapsed + 1000) * 0.5
	$torch_near.translation.y = new_height
	$torch_near.translation.x = new_x
	$torch_far.translation.y = new_height
	$torch_far.translation.x = new_x
	
func _process_input():
	# Can't interupt movement or move before in the map
	if($mover.is_active()) or not in_map:
		return

	$"sfx-footstep".pitch_scale = 0.6 + randf() * 0.7
	$"sfx-footstep".stream = FOOT_SFX[randi() % 4]
	
	# Resnap roation is just a precaution in case of float drift
	rotation.y = global.DIRECTIONS[facing]

	if Input.is_action_pressed("ui_cancel"):
		$"/root/main/pause_popup".show()

	if(Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down")):
		var dir = 1
		if(Input.is_action_pressed("ui_down")):
			dir = -1

		var dest_cell = null
		if(facing == global.COMPASS.NORTH):
			dest_cell = map.get_cell(cell.x, cell.y - dir)
			if(dest_cell == null || !dest_cell.player_can_pass): 
				grunt()
				if not global.GOD: return
			$mover.interpolate_property(self, "translation:z", translation.z, translation.z - global.CELL_SIZE * dir, MOVE_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
			
		if(facing == global.COMPASS.EAST):
			dest_cell = map.get_cell(cell.x + dir, cell.y)
			if(dest_cell == null || !dest_cell.player_can_pass): 
				grunt()
				if not global.GOD: return
			$mover.interpolate_property(self, "translation:x", translation.x, translation.x + global.CELL_SIZE * dir, MOVE_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
			
		if(facing == global.COMPASS.SOUTH):
			dest_cell = map.get_cell(cell.x, cell.y + dir)
			if(dest_cell == null || !dest_cell.player_can_pass):
				grunt()
				if not global.GOD: return	
			$mover.interpolate_property(self, "translation:z", translation.z, translation.z + global.CELL_SIZE * dir, MOVE_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
			
		if(facing == global.COMPASS.WEST):
			dest_cell = map.get_cell(cell.x - dir, cell.y)
			if(dest_cell == null || !dest_cell.player_can_pass):
				grunt()
				if not global.GOD: return
			$mover.interpolate_property(self, "translation:x", translation.x, translation.x - global.CELL_SIZE * dir, MOVE_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
		
		# Special bullshit to handle level exits
		if dest_cell.center_detail != null and dest_cell.center_detail.name == "exit":
			$mover.remove_all()
			$"..".start_level(dest_cell.center_detail.next_level, null)
			return
			
		$mover.start()
		$"sfx-footstep".play()
		cell = dest_cell
		print("+++ Player moved to: %s, %s"% [cell.x, cell.y])

	if(Input.is_action_pressed("ui_left")):
		turn_left()
		$mover.interpolate_property(self, "rotation:y", rotation.y, rotation.y+PI/2, TURN_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$mover.start()

	if(Input.is_action_pressed("ui_right")):
		turn_right()
		$mover.interpolate_property(self, "rotation:y", rotation.y, rotation.y-PI/2, TURN_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$mover.start()

func move_to(new_cell: Cell):
	assert(new_cell != null, "move_to cell can't be null!")
	print("player move to ",new_cell.x,",",new_cell.y)
	cell = new_cell
	translation.x = cell.x * global.CELL_SIZE
	translation.y = 0
	translation.z = cell.y * global.CELL_SIZE
	##translate(Vector3(cell.x * global.CELL_SIZE, 0, cell.y * global.CELL_SIZE))

func set_facing(new_facing: int):
	assert(new_facing in global.COMPASS.values(), "Expected a COMPASS value")
	facing = new_facing
	print("player face to ", facing)
	rotation.y = global.DIRECTIONS[facing]

func turn_left():
	facing = facing - 1
	if(facing < global.COMPASS.NORTH): 
		facing = global.COMPASS.WEST

func turn_right():
	facing = facing + 1
	if(facing > global.COMPASS.WEST): 
		facing = global.COMPASS.NORTH

func grunt():
	if $"sfx-grunt".playing: return
	$"sfx-grunt".pitch_scale = 0.7 + randf() * 0.2
	$"sfx-grunt".play()

func is_in_hand(id: String) -> bool:
	if in_hand != null and in_hand.item_id == id:
		return true
	return false

func remove_item_in_hand():
	in_hand = null
	$"/root/main/cursor".texture = CURSOR_HAND
	$"/root/main/cursor".offset.x = 0
	$"/root/main/cursor".offset.y = 0
	
func put_item_in_hand(item):
	if item == null: return
	
	in_hand = item
	$"/root/main/cursor".texture = load("res://items/" + item.icon + ".png")
	$"/root/main/cursor".offset.x = -16
	$"/root/main/cursor".offset.y = -16

func place_in_inventory(item: Item, slot: String):
	inventory[slot] = item
	var icon = item.icon
	if item.item_id == TORCH_ITEM_ID:
		icon += "_held"
	if slot == LEFT_HAND:
		$"/root/main/hud/inv_left_hand/sprite".texture = load("res://items/" + icon + ".png")
	if slot == RIGHT_HAND:
		$"/root/main/hud/inv_right_hand/sprite".texture = load("res://items/" + icon + ".png")
		
func clear_inventory_slot(slot: String):
	inventory[slot] = null
	if slot == LEFT_HAND:
		$"/root/main/hud/inv_left_hand/sprite".texture = null
	if slot == RIGHT_HAND:
		$"/root/main/hud/inv_right_hand/sprite".texture = null
