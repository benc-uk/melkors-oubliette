extends Node

class_name Door

enum types {WOOD, PORT}

var type = types.WOOD
var has_buttons: bool = true
var opened: bool = false
var cell
	
func _ready() -> void:
	var WOOD_DOOR = load("res://obj/door-wood.glb")
	var WOOD_PORT = load("res://obj/door-port.glb")

	var door_scene = WOOD_DOOR
	if type == types.WOOD: door_scene = WOOD_DOOR
	if type == types.PORT: door_scene = WOOD_PORT
	$"door-body".add_child(door_scene.instance())
	
	if not has_buttons:
		get_node("push-switch-stone1").queue_free()
		get_node("push-switch-stone2").queue_free()
	if opened:
		get_parent().player_can_pass = true
		$"door-body/anim".play("open", -1, 4)
	else:
		get_parent().player_can_pass = false
		$"door-body/anim".play("close", -1, 4)

func open() -> void:
	if opened: return
	get_parent().player_can_pass = true
	opened = true
	$"door-body/anim".play("open")
	$"sfx-door".play()
	$"sfx-click".play()

func close() -> void:
	if not opened: return
	get_parent().player_can_pass = false
	opened = false
	$"door-body/anim".play("close")
	$"sfx-door".play()
	$"sfx-click".play()

func toggle() -> void:
	if opened: close()
	else: open()
	
func click_handler(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:		
			$"push-switch-stone1/anim".play("activate")
			$"push-switch-stone2/anim".play("activate")
			toggle()
