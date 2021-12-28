extends Node

class_name Door

enum types {WOOD, PORT}

var type = types.WOOD
var has_buttons: bool = true
var opened: bool = false
var cell
	
func _ready() -> void:
	var door_scene = load("res://obj/door-wood.glb")
	if type == types.WOOD: door_scene = load("res://obj/door-wood.glb")
	if type == types.PORT: door_scene = load("res://obj/door-port.glb")
	$"door-body".add_child(door_scene.instance())
	
	if not has_buttons:
		get_node("push-switch-stone1").queue_free()
		get_node("push-switch-stone2").queue_free()
	if not opened:
		get_parent().player_can_pass = false
		opened = false
		$"door-body/Anim".play("Close", -1, 4)

func open() -> void:
	if opened: return
	get_parent().player_can_pass = true
	opened = true
	$"door-body/Anim".play("Open")
	$"Sfx".play()
	$"SfxClick".play()

func close() -> void:
	if not opened: return
	get_parent().player_can_pass = false
	opened = false
	$"door-body/Anim".play("Close")
	$"Sfx".play()
	$"SfxClick".play()

func toggle() -> void:
	if opened: close()
	else: open()
	
func switch_area_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
			toggle()
