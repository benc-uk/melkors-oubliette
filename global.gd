extends Node

const VERSION = "0.0.1-06-01-2021"

# The size in world units of each map cell
# YOU MUST NEVER CHANGE THIS
const CELL_SIZE = 10
const HALF_CELL_SIZE = CELL_SIZE / 2

# The four cardinal directions
enum COMPASS {NORTH, EAST, SOUTH, WEST}

# These are rotations in radians around Y axis 
# which correspond to the COMPASS enum 
const DIRECTIONS = [0, -(PI/2), PI, +(PI/2)]

# Holds all item templates
var item_db: Dictionary
var monster_db: Dictionary
const ITEM_DB_PATH = "res://items/db.json"
const MONSTER_DB_PATH = "res://monsters/db.json"
const CHEATS_FILE_PATH = "user://cheats.json"

# Debug cheats...
# Set to level filename to jump start to it
var CHEAT_JUMP_LEVEL = null
# Set to a tuple array, x,y cell to start in
var CHEAT_START_POS = []
# Enable walk through walls & doors
var CHEAT_NOCLIP = false
# Permanent light source
var CHEAT_LIGHT = false

# Helper to convert compass direction from string
# You can use single letters or words
static func str_to_compass(compass_str) -> int:
	match compass_str[0].to_upper():
		"N": return COMPASS.NORTH
		"E": return COMPASS.EAST
		"S": return COMPASS.SOUTH
		"W": return COMPASS.WEST
		_: return COMPASS.NORTH 

static func compass_to_char(compasss_int: int):
	match compasss_int:
		COMPASS.NORTH: return "n"
		COMPASS.EAST: return "e"
		COMPASS.SOUTH: return "s"
		COMPASS.WEST: return "w"
		_: return "n"

func _init():
	randomize()
	
	# Load the global item DB json, used by item.gd
	var file = File.new()
	if not file.file_exists(ITEM_DB_PATH):
		print("SEVERE! Unable to locate item db file: ", ITEM_DB_PATH)
	file.open(ITEM_DB_PATH, File.READ)
	var json_result = JSON.parse(file.get_as_text())
	if json_result.error != OK:
		print("SEVERE! Unable to parse item db file. Line:", json_result.error_line, ": ", json_result.error_string)
	item_db = json_result.result
	
	# Load the global monster DB json, used by monster.gd
	if not file.file_exists(ITEM_DB_PATH):
		print("SEVERE! Unable to locate monster db file: ", MONSTER_DB_PATH)
	file.open(MONSTER_DB_PATH, File.READ)
	json_result = JSON.parse(file.get_as_text())
	if json_result.error != OK:
		print("SEVERE! Unable to parse monster db file. Line:", json_result.error_line, ": ", json_result.error_string)
	monster_db = json_result.result
	
	# Parse cheats file
	if not file.file_exists(CHEATS_FILE_PATH): return
	file.open(CHEATS_FILE_PATH, File.READ)
	json_result = JSON.parse(file.get_as_text())
	if json_result.error != OK:
		print("WARNING! Unable to parse cheat JSON file. Line:", json_result.error_line, ": ", json_result.error_string)
		
	if json_result.result.has("jump_level"): CHEAT_JUMP_LEVEL = json_result.result.jump_level
	if json_result.result.has("start_pos"): CHEAT_START_POS = json_result.result.start_pos
	if json_result.result.has("noclip"): CHEAT_NOCLIP = json_result.result.noclip
	if json_result.result.has("light"): CHEAT_LIGHT = json_result.result.light
