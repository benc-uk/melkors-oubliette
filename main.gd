extends Spatial

const MAP_SCENE = preload("res://map.tscn")
const PLAYER_SCENE = preload("res://player.tscn")

var yaml_parser
var player
var map

func _init():
	yaml_parser = preload("res://addons/godot-yaml/gdyaml.gdns").new()
	
func start_game(file_name: String):
	map = MAP_SCENE.instance()
	add_child(map)
	player = PLAYER_SCENE.instance()
	player.map = map
	add_child(player)
	
	var file = File.new()
	if !file.file_exists(file_name): 
		print("Could not load ", file_name, ", sorry!")
		quit()
		return
	file.open(file_name, File.READ)
	var level = yaml_parser.parse(file.get_as_text())
	file.close() 
	map.parse_level(level)
	
	show_message(level.name, 2)
	
	if not level.has("player_start"):
		print("### Parse error: Level is missing player_start !")
		quit()
		return

	player.move_to(map.get_cell(level.player_start.pos[0], level.player_start.pos[1]))
	player.set_facing(global.stringToCompass(level.player_start.pos[2]))
	$music.play()

func _process(delta):
	$debug.text = "Player at: " + str(player.cell.x) + ", " + str(player.cell.y) 
	
func quit():
	# Reinstantiate the main menu and nuke yourself
	get_tree().get_root().add_child(load("res://main-menu.tscn").instance())	
	queue_free()
	
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
	
func hide_pause():
	$pause_popup.hide()
