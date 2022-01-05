extends Spatial

const MAP_SCENE = preload("res://map.tscn")
const PLAYER_SCENE = preload("res://player.tscn")
const CURSOR_HAND = preload("res://hud/cursor-hand.png")

var yaml_parser
var player: Player
var map: Map

func _init():
	yaml_parser = preload("res://addons/godot-yaml/gdyaml.gdns").new()
	
func start_level(file_name: String):
	print("### Starting level: ", file_name)

	# Different paths if first time called, or switching levels
	if map != null:
		player.in_map = false
		map.free()
		map = MAP_SCENE.instance()
	else:
		map = MAP_SCENE.instance()
		player = PLAYER_SCENE.instance()
		add_child(player)

		# On custom levels, start with a torch
		if file_name.begins_with("user://"):
			player.place_in_inventory(Item.new("torch"), Player.LEFT_HAND)
		
	add_child(map)
	player.map = map
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$cursor.texture = CURSOR_HAND

	var file = File.new()
	if !file.file_exists(file_name): 
		print("### FATAL! Could not load ", file_name, ", sorry!")
		_quit()
		return
	file.open(file_name, File.READ)
	var level = yaml_parser.parse(file.get_as_text())
	file.close() 
	map.parse_level(level)
	
	if not level.has("player_start"):
		print("### Parse error: Level is missing player_start !")
		_quit()
		return

	player.move_to(map.get_cell(level.player_start.pos[0], level.player_start.pos[1]))
	player.set_facing(global.str_to_compass(level.player_start.pos[2]))
	$music.play()
	
	if global.CHEAT_START_POS.size() == 2:
		player.move_to(map.get_cell(global.CHEAT_START_POS[0], global.CHEAT_START_POS[1]))
		
	yield(get_tree().create_timer(0.3), "timeout")
	show_message(level.name, 2)
	player.in_map = true
	
func _process(_delta):
	$debug.text = " Player at: %s, %s  facing: %s" % [player.x, player.y, global.compass_to_char(player.facing)]
	$cursor.position.x = get_viewport().get_mouse_position().x
	$cursor.position.y = get_viewport().get_mouse_position().y

func _quit():
	# Reinstantiate the main menu and nuke yourself
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().get_root().add_child(load("res://title-screen.tscn").instance())	
	queue_free()
	
func show_message(msg, time = 5.0):
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = time
	timer.connect("timeout", self, "_remove_message")
	$popup.text = msg
	$popup.visible = true
	$popup.add_child(timer)
	timer.start()

func _remove_message():
	$popup.visible = false
	
func hide_pause():
	$pause_popup.hide()

func show_pause():
	$pause_popup.show()

func _on_inv_left_hand_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
			if player.in_hand != null:
				if player.inventory[Player.LEFT_HAND] == null:
					player.place_in_inventory(player.in_hand, Player.LEFT_HAND)
					player.remove_held_item()
				else:
					var temp = player.inventory[Player.LEFT_HAND]
					player.place_in_inventory(player.in_hand, Player.LEFT_HAND)
					player.put_item_in_hand(temp)
			else:
				if player.inventory[Player.LEFT_HAND] != null: player.put_item_in_hand(player.inventory[Player.LEFT_HAND])
				player.clear_inventory_slot(Player.LEFT_HAND)

func _on_inv_right_hand_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
			if player.in_hand != null:
				if player.inventory[Player.RIGHT_HAND] == null:
					player.place_in_inventory(player.in_hand, Player.RIGHT_HAND)
					player.remove_held_item()
				else:
					var temp = player.inventory[Player.RIGHT_HAND]
					player.place_in_inventory(player.in_hand, Player.RIGHT_HAND)
					player.put_item_in_hand(temp)
			else:
				if player.inventory[Player.RIGHT_HAND] != null: player.put_item_in_hand(player.inventory[Player.RIGHT_HAND])
				player.clear_inventory_slot(Player.RIGHT_HAND)

func _on_man_icon_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
			show_pause()
