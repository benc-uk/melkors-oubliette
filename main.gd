extends Spatial

const MAP_SCENE = preload("res://map.tscn")
const PLAYER_SCENE = preload("res://player.tscn")
const CURSOR_HAND = preload("res://hud/cursor-hand.png")

var yaml_parser
var player: Player
var map: Map

func _init():
	yaml_parser = preload("res://addons/godot-yaml/gdyaml.gdns").new()
	
func start_game(file_name: String):
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$cursor.texture = CURSOR_HAND
	map = MAP_SCENE.instance()
	add_child(map)
	player = PLAYER_SCENE.instance()
	player.map = map
	add_child(player)
	
	var file = File.new()
	if !file.file_exists(file_name): 
		print("### FATAL! Could not load ", file_name, ", sorry!")
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
	player.set_facing(global.str_to_compass(level.player_start.pos[2]))
	$music.play()
	$hud/inv_left_hand/sprite.texture = null
	$hud/inv_right_hand/sprite.texture = null
	
func _process(delta):
	$debug.text = " Player at: " + str(player.cell.x) + ", " + str(player.cell.y) 
	$cursor.position.x = get_viewport().get_mouse_position().x
	$cursor.position.y = get_viewport().get_mouse_position().y

func quit():
	# Reinstantiate the main menu and nuke yourself
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().get_root().add_child(load("res://title-screen.tscn").instance())	
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

func show_pause():
	$pause_popup.show()

func _on_inv_left_hand_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
			if player.in_hand != null:
				if player.inventory[Player.LEFT_HAND] == null:
					player.place_in_inventory(player.in_hand, Player.LEFT_HAND)
					player.remove_item_in_hand()
				else:
					var temp = player.inventory[Player.LEFT_HAND]
					player.place_in_inventory(player.in_hand, Player.LEFT_HAND)
					player.put_item_in_hand(temp)
				$hud/inv_left_hand/sprite.texture = load("res://items/" + player.inventory[Player.LEFT_HAND].icon + ".png")
			else:
				if player.inventory[Player.LEFT_HAND] != null: player.put_item_in_hand(player.inventory[Player.LEFT_HAND])
				player.clear_inventory_slot(Player.LEFT_HAND)
				$hud/inv_left_hand/sprite.texture = null

func _on_inv_right_hand_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
			if player.in_hand != null:
				if player.inventory[Player.RIGHT_HAND] == null:
					player.place_in_inventory(player.in_hand, Player.RIGHT_HAND)
					player.remove_item_in_hand()
				else:
					var temp = player.inventory[Player.RIGHT_HAND]
					player.place_in_inventory(player.in_hand, Player.RIGHT_HAND)
					player.put_item_in_hand(temp)
				$hud/inv_right_hand/sprite.texture = load("res://items/" + player.inventory[Player.RIGHT_HAND].icon + ".png")
			else:
				if player.inventory[Player.RIGHT_HAND] != null: player.put_item_in_hand(player.inventory[Player.RIGHT_HAND])
				player.clear_inventory_slot(Player.RIGHT_HAND)
				$hud/inv_right_hand/sprite.texture = null

func _on_man_icon_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
			show_pause()
