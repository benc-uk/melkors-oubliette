extends Spatial

var yaml_parser

func _init():
	yaml_parser = preload("res://addons/godot-yaml/gdyaml.gdns").new()
	
func _ready():
	var file = File.new()
	if !file.file_exists("user://level-1.yaml"): 
		get_tree().paused = true
		print("Could not load level-1.yaml, sorry!")
		return
	file.open("user://level-1.yaml", File.READ)
	var level = yaml_parser.parse(file.get_as_text())
	file.close() 
	$Map.parse_level(level)
	show_message(level.name, 2)
		
	$Player.move_to($Map.get_cell(level.player_start.pos[0], level.player_start.pos[1]))
	$Player.set_facing(global.stringToCompass(level.player_start.pos[2]))
	$Music.play()

func show_message(msg, time):
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = time
	timer.connect("timeout", self, "remove_message")
	$Popup.text = msg
	$Popup.visible = true
	$Popup.add_child(timer)
	timer.start()

func remove_message():
	$Popup.visible = false
