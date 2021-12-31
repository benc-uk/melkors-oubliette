extends Spatial

var yaml_parser
var player
var level_file = "level-1.yaml"

func _init():
	yaml_parser = preload("res://addons/godot-yaml/gdyaml.gdns").new()
	
func _ready():
	player = find_node("player")
	var file = File.new()
	if !file.file_exists(global.level_file_name): 
		print("Could not load ", global.level_file_name, ", sorry!")
		get_tree().change_scene("res://main-menu.tscn")
		return
	file.open(global.level_file_name, File.READ)
	var level = yaml_parser.parse(file.get_as_text())
	file.close() 
	$map.parse_level(level)
	show_message(level.name, 2)
		
	player.move_to($map.get_cell(level.player_start.pos[0], level.player_start.pos[1]))
	player.set_facing(global.stringToCompass(level.player_start.pos[2]))
	$music.play()

func show_message(msg, time):
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = time
	timer.connect("timeout", self, "remove_message")
	$popup.text = msg
	$popup.visible = true
	$popup.add_child(timer)
	timer.start()

func remove_message():
	$popup.visible = false
	
