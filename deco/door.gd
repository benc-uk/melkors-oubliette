extends Node

class_name Door

enum types {WOOD, PORT}

var type = types.WOOD
var has_switch1: bool = true
var has_switch2: bool = true
var open: bool = false
var cell
	
func _ready() -> void:
	var door_scene = load("res://obj/door-wood.glb")
	if type == types.WOOD: door_scene = load("res://obj/door-wood.glb")
	if type == types.PORT: door_scene = load("res://obj/door-port.glb")
	$"door-body".add_child(door_scene.instance())
	
	if not has_switch1:
		get_node("push-switch-stone1").queue_free()
	if not has_switch2:
		get_node("push-switch-stone2").queue_free()
	if not open:
		get_parent().player_can_pass = false
		open = false
		$"door-body/Anim".play("Close", -1, 4)

func set_open() -> void:
	if open: return
	get_parent().player_can_pass = true
	open = true
	$"door-body/Anim".play("Open")
	$"Sfx".play()
	$"SfxClick".play()

func set_closed() -> void:
	if not open: return
	get_parent().player_can_pass = false
	open = false
	$"door-body/Anim".play("Close")
	$"Sfx".play()
	$"SfxClick".play()

func toggle_open() -> void:
	if open: set_closed()
	else: set_open()
	
func switch_area_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
			toggle_open()
