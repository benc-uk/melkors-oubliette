extends Node2D

const MAIN_LEVEL_PATH = "res://levels"
const CUSTOM_LEVEL_PATH = "user://levels"
const START_FILE = "start.yaml"
const MAIN_SCENE = preload("res://main.tscn")

# Used when testing
var fast_load = "res://levels/Melkor's Oubliette/sewers.yaml"

func _ready():
	# Create the custom level dir if it doesn't exist
	var dir = Directory.new()
	if not dir.dir_exists(CUSTOM_LEVEL_PATH):
		dir.make_dir(CUSTOM_LEVEL_PATH)
		
	# Skip menus and jump straight in
	if global.CHEAT_JUMP_LEVEL && global.CHEAT_JUMP_LEVEL != "":
		print("### Enabling cheat, jump to level: %s" % global.CHEAT_JUMP_LEVEL)
		# Have to use call_deferred for some reason
		call_deferred("_load_and_start", global.CHEAT_JUMP_LEVEL)
	
	if global.CHEAT_NOCLIP: print("### Enabling cheat, noclip walls")
	if global.CHEAT_LIGHT: print("### Enabling cheat, infinite light")
	if global.CHEAT_START_POS: print("### Enabling cheat, start pos: %s,%s" % global.CHEAT_START_POS)

func _on_new_btn_pressed():
	$start_popup/panel/level_list.clear()
	$start_popup/panel/level_list_custom.clear()
	
	# Read all custom levels
	var dir = Directory.new()
	if dir.open(CUSTOM_LEVEL_PATH) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and file_name != "." and file_name != "..":
				$start_popup/panel/level_list_custom.add_item(file_name)
			file_name = dir.get_next()
	else:
		print("### Fatal! An error occurred when trying to access: ", CUSTOM_LEVEL_PATH)
		
	# Read builtin / main levels
	dir = Directory.new()
	if dir.open(MAIN_LEVEL_PATH) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and file_name != "." and file_name != "..":
				$start_popup/panel/level_list.add_item(file_name)
			file_name = dir.get_next()
	else:
		print("### Fatal! An error occurred when trying to access: ", CUSTOM_LEVEL_PATH)	
	
	$start_popup.show()

func _on_back_btn_pressed():
	$start_popup.hide()

func _on_start_btn_pressed():
	if $start_popup/panel/level_list.is_anything_selected():
		var level_index = $start_popup/panel/level_list.get_selected_items()[0]
		var selected_level = $start_popup/panel/level_list.get_item_text(level_index)
		_load_and_start(MAIN_LEVEL_PATH + "/" + selected_level + "/" + START_FILE)
	elif $start_popup/panel/level_list_custom.is_anything_selected(): 
		var level_index = $start_popup/panel/level_list_custom.get_selected_items()[0]
		var selected_level = $start_popup/panel/level_list_custom.get_item_text(level_index)
		_load_and_start(CUSTOM_LEVEL_PATH + "/" + selected_level + "/" + START_FILE)

func _load_and_start(file: String):
	# Add main game scene to the tree
	var main = MAIN_SCENE.instance()
	get_tree().get_root().add_child(main)
	
	# Start!
	main.start_level(file)
	
	# Kiss goodbye to the main menu
	queue_free()
	
# These ensure only one level from either set can be selected
func _on_level_list_custom_item_selected(_index):
	$start_popup/panel/start_btn.disabled = false
	$start_popup/panel/level_list.unselect_all()

func _on_level_list_item_selected(_index):
	$start_popup/panel/start_btn.disabled = false
	$start_popup/panel/level_list_custom.unselect_all()
