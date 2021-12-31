extends Spatial

export var CAM_HEIGHT = 6.5
export var CAM_BACK = 3
export var TURN_SPEED = 0.3
export var MOVE_SPEED = 0.4
export var NEAR_LIGHT_ENERGY = 10

# Light scaling
export var LIGHT_SCALE = 1.0
const LIGHT_DECAY_SPEED = 30
# Set to 1.0 to disable
const LIGHT_DECAY_AMOUNT = 1.0

var facing
var map: Map
var cell: Cell
var noise: OpenSimplexNoise
var noise2: OpenSimplexNoise
var elapsed: float
var clip_cheat = true
var ticks = 0

const FOOT_SFX = [
	preload("res://sound/player_footstep01.wav"), 
	preload("res://sound/player_footstep02.wav"),
	preload("res://sound/player_footstep03.wav"),
	preload("res://sound/player_footstep04.wav")
]

func _ready():
	map = get_node("/root/main/map")
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
	ticks = ticks + 1
	if ticks > LIGHT_DECAY_SPEED:
		ticks = 0
		LIGHT_SCALE = LIGHT_SCALE / LIGHT_DECAY_AMOUNT
	_process_input()
	elapsed = elapsed + delta
	
	# Fake flame/flicker, move light randomly and alter light brightness
	var light_modifier = (noise.get_noise_1d(elapsed) + 1) / 2
	$torch_far.light_energy = (light_modifier * 8 * LIGHT_SCALE)
	$torch_near.light_energy = NEAR_LIGHT_ENERGY * LIGHT_SCALE
	var new_height = CAM_HEIGHT + noise2.get_noise_1d(elapsed) * 1.5
	var new_x = 0 + noise2.get_noise_1d(elapsed + 1000) * 0.5
	$torch_near.translation.y = new_height
	$torch_near.translation.x = new_x
	$torch_far.translation.y = new_height
	$torch_far.translation.x = new_x
	
func _process_input():
	# Can't interupt movement
	if($mover.is_active()):
		return

	$"sfx-footstep".pitch_scale = 0.6 + randf() * 0.7
	$"sfx-footstep".stream = FOOT_SFX[randi() % 4]
	
	# Resnap roation is just a precaution in case of float drift
	rotation.y = global.DIRECTIONS[facing]

	if(Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down")):
		var dir = 1
		if(Input.is_action_pressed("ui_down")):
			dir = -1

		if(facing == global.COMPASS.NORTH):
			var dest_cell = map.get_cell(cell.x, cell.y - dir)
			if(dest_cell == null || !dest_cell.player_can_pass): 
				grunt()
				return
			$mover.interpolate_property(self, "translation:z", translation.z, translation.z - global.CELL_SIZE * dir, MOVE_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$mover.start()
			$"sfx-footstep".play()
			cell = dest_cell
			
		if(facing == global.COMPASS.EAST):
			var dest_cell = map.get_cell(cell.x + dir, cell.y)
			if(dest_cell == null || !dest_cell.player_can_pass): 
				grunt()
				return
			$mover.interpolate_property(self, "translation:x", translation.x, translation.x + global.CELL_SIZE * dir, MOVE_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$mover.start()
			$"sfx-footstep".play()
			cell = dest_cell
			
		if(facing == global.COMPASS.SOUTH):
			var dest_cell = map.get_cell(cell.x, cell.y + dir)
			if(dest_cell == null || !dest_cell.player_can_pass):
				grunt()
				return
			$mover.interpolate_property(self, "translation:z", translation.z, translation.z + global.CELL_SIZE * dir, MOVE_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$mover.start()
			$"sfx-footstep".play()
			cell = dest_cell
			
		if(facing == global.COMPASS.WEST):
			var dest_cell = map.get_cell(cell.x - dir, cell.y)
			if(dest_cell == null || !dest_cell.player_can_pass):
				grunt()
				return
			$mover.interpolate_property(self, "translation:x", translation.x, translation.x - global.CELL_SIZE * dir, MOVE_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$mover.start()
			$"sfx-footstep".play()
			cell = dest_cell
		#print("MOVED TO %s, %s"% [cell.x, cell.y])

	if(Input.is_action_pressed("ui_left")):
		turn_left()
		$mover.interpolate_property(self, "rotation:y", rotation.y, rotation.y+PI/2, TURN_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$mover.start()

	if(Input.is_action_pressed("ui_right")):
		turn_right()
		$mover.interpolate_property(self, "rotation:y", rotation.y, rotation.y-PI/2, TURN_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$mover.start()

#
# Instantly move (teleport) to given cell
#
func move_to(new_cell: Cell):
	assert(new_cell != null, "move_to cell can't be null!")
	cell = new_cell
	translate(Vector3(cell.x * global.CELL_SIZE, 0, cell.y * global.CELL_SIZE))

#
#
#
func set_facing(new_facing: int):
	assert(new_facing in global.COMPASS.values(), "Expected a COMPASS value")
	facing = new_facing
	rotation.y = global.DIRECTIONS[facing]

#
#
#
func turn_left():
	facing = facing - 1
	if(facing < global.COMPASS.NORTH): 
		facing = global.COMPASS.WEST

#
#
#
func turn_right():
	facing = facing + 1
	if(facing > global.COMPASS.WEST): 
		facing = global.COMPASS.NORTH


func grunt():
	if $"sfx-grunt".playing: return
	$"sfx-grunt".pitch_scale = 0.7 + randf() * 0.2
	$"sfx-grunt".play()
