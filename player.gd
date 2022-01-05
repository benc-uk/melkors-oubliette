extends Spatial
class_name Player

# Tunable params, but probably don't ever change them!
export var CAM_HEIGHT = 6.5
export var CAM_BACK = 3
export var TURN_SPEED = 0.3
export var MOVE_SPEED = 0.4
export var NEAR_LIGHT_ENERGY = 10

# Core stuff
var facing: int = global.COMPASS.NORTH
var in_map = false
var map: Map
var cell: Cell

# Only need to keep these as well as the cell, to support noclip
var x = 0
var y = 0

# Lighting
export var light_level = 0.0
var light_level_noise: OpenSimplexNoise
var light_pos_noise: OpenSimplexNoise
var elapsed: float

# Inventory and pickup item hand
var in_hand: Item = null
var inventory = {
	LEFT_HAND: Item,
	RIGHT_HAND: Item
}

const CURSOR_HAND = preload("res://hud/cursor-hand.png")
const LEFT_HAND = "left_hand"
const RIGHT_HAND = "right_hand"
const FOOT_SFX = [
	"player_footstep01.wav",
	"player_footstep02.wav",
	"player_footstep03.wav",
	"player_footstep04.wav"
]
const GRUNT_SFX = "player_grunt.wav"
const TORCH_ITEM_ID = "torch"

func _init():
	inventory[LEFT_HAND] = null
	inventory[RIGHT_HAND] = null
	
func _ready():
	$camera.translate(Vector3(0, CAM_HEIGHT, CAM_BACK))
	$torch_far.translate(Vector3(0, CAM_HEIGHT, 0))
	$torch_near.translate(Vector3(0, CAM_HEIGHT, 0))
	
	light_level_noise = OpenSimplexNoise.new()
	light_level_noise.seed = randi()
	light_level_noise.octaves = 1
	light_level_noise.period = 1.2
	light_pos_noise = OpenSimplexNoise.new()
	light_pos_noise.seed = randi()
	light_pos_noise.octaves = 1
	light_pos_noise.period = 0.5
	# This is a increasing value used to "walk" the light_level_noise
	elapsed = 0

func _process(delta):
	# sub-function for input scanning
	_process_input()
	
	# Handle torch in hand
	if inventory[LEFT_HAND] != null and inventory[LEFT_HAND].item_id == TORCH_ITEM_ID:
		inventory[LEFT_HAND].update_charge(delta)
		light_level = inventory[LEFT_HAND].charge
		if inventory[LEFT_HAND].charge <= 0: place_in_inventory(inventory[LEFT_HAND], LEFT_HAND)		
	elif inventory[RIGHT_HAND] != null and inventory[RIGHT_HAND].item_id == TORCH_ITEM_ID:
		inventory[RIGHT_HAND].update_charge(delta)
		light_level = inventory[RIGHT_HAND].charge
		if inventory[RIGHT_HAND].charge <= 0: place_in_inventory(inventory[RIGHT_HAND], RIGHT_HAND)
	else:
		light_level = 0.0
		
	if global.CHEAT_LIGHT:
		light_level = 1.0
	
	# Fake flame/flicker, move light randomly and alter light brightness
	elapsed = elapsed + delta
	var light_modifier = (light_level_noise.get_noise_1d(elapsed) + 1) / 2
	$torch_far.light_energy = (light_modifier * 8 * light_level)
	$torch_near.light_energy = NEAR_LIGHT_ENERGY * light_level
	var new_height = CAM_HEIGHT + light_pos_noise.get_noise_1d(elapsed) * 1.5
	var new_x = 0 + light_pos_noise.get_noise_1d(elapsed + 1000) * 0.5
	$torch_near.translation.y = new_height
	$torch_near.translation.x = new_x
	$torch_far.translation.y = new_height
	$torch_far.translation.x = new_x
	
func _process_input():
	# Can't interupt movement or move before in the map
	if($mover.is_active()) || !in_map:
		return
	
	# Resnap roation is just a precaution in case of float drift
	rotation.y = global.DIRECTIONS[facing]

	if Input.is_action_pressed("ui_cancel"):
		$"..".show_pause()

	# Slight hack to restore cell after noclip, which means cell will be null
	if !cell && map.get_cell(x, y):
		cell = map.get_cell(x, y)
		
	if(Input.is_action_pressed("ui_up") || Input.is_action_pressed("ui_down")):
		# To handle stepping forward and backward
		var dir = 1
		if(Input.is_action_pressed("ui_down")):
			dir = -1

		var dest_cell = null
		if facing == global.COMPASS.NORTH:
			if cell: dest_cell = map.get_cell(cell.x, cell.y - dir)
			if(!dest_cell || !dest_cell.player_can_pass) && !global.CHEAT_NOCLIP:
				play_sfx(GRUNT_SFX, true)
				return
			y = y - dir
			$mover.interpolate_property(self, "translation:z", translation.z, translation.z - global.CELL_SIZE * dir, MOVE_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
			
		if facing == global.COMPASS.EAST:
			if cell: dest_cell = map.get_cell(cell.x + dir, cell.y)
			if(!dest_cell || !dest_cell.player_can_pass) && !global.CHEAT_NOCLIP:
				play_sfx(GRUNT_SFX, true)
				return
			x = x + dir
			$mover.interpolate_property(self, "translation:x", translation.x, translation.x + global.CELL_SIZE * dir, MOVE_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
			
		if facing == global.COMPASS.SOUTH:
			if cell: dest_cell = map.get_cell(cell.x, cell.y + dir)
			if(!dest_cell || !dest_cell.player_can_pass) && !global.CHEAT_NOCLIP:
				play_sfx(GRUNT_SFX, true)
				return
			y = y + dir
			$mover.interpolate_property(self, "translation:z", translation.z, translation.z + global.CELL_SIZE * dir, MOVE_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
			
		if facing == global.COMPASS.WEST:
			if cell: dest_cell = map.get_cell(cell.x - dir, cell.y)
			if(!dest_cell || !dest_cell.player_can_pass) && !global.CHEAT_NOCLIP:
				play_sfx(GRUNT_SFX, true)
				return
			x = x - dir
			$mover.interpolate_property(self, "translation:x", translation.x, translation.x - global.CELL_SIZE * dir, MOVE_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
		
		# Special stuff to handle level exits
		if dest_cell && dest_cell.is_exit:
			$mover.remove_all()
			# Need to reset this, it might not be a valid cell on the next level
			global.CHEAT_START_POS = []
			$"..".start_level(dest_cell.exit_level)
			return
			
		$mover.start()
		play_sfx(FOOT_SFX[randi() % 4], true)
		cell = dest_cell

	if(Input.is_action_pressed("ui_left")):
		turn_left()
		$mover.interpolate_property(self, "rotation:y", rotation.y, rotation.y+PI/2, TURN_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$mover.start()

	if(Input.is_action_pressed("ui_right")):
		turn_right()
		$mover.interpolate_property(self, "rotation:y", rotation.y, rotation.y-PI/2, TURN_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$mover.start()

func move_to(new_cell: Cell):
	if !new_cell:
		print("### Warning: Tried to move to a null cell")
		return
	cell = new_cell
	x = cell.x
	y = cell.y
	translation.x = cell.x * global.CELL_SIZE
	translation.y = 0
	translation.z = cell.y * global.CELL_SIZE

func set_facing(new_facing: int):
	if !new_facing in global.COMPASS.values():
		print("### Warning: Tried to set facing to an invalid compass dir %s", new_facing)
		return
	facing = new_facing
	rotation.y = global.DIRECTIONS[facing]

func turn_left():
	facing = facing - 1
	if(facing < global.COMPASS.NORTH): 
		facing = global.COMPASS.WEST

func turn_right():
	facing = facing + 1
	if(facing > global.COMPASS.WEST): 
		facing = global.COMPASS.NORTH

func play_sfx(file: String, random_pitch = false):
	$sfx.pitch_scale = 0.7 + randf() * 0.2 if random_pitch else 1.0 
	$sfx.stream = load("res://sound/"+file)
	$sfx.play()
	
func is_holding(id: String) -> bool:
	if in_hand != null and in_hand.item_id == id:
		return true
	return false

func remove_held_item():
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
	if item.item_id == TORCH_ITEM_ID && item.charge > 0:
		icon += "_charged"
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
