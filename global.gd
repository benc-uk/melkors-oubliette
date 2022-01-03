extends Node

# The size in world units of each map cell
const CELL_SIZE = 10
const HALF_CELL_SIZE = CELL_SIZE / 2

# The four cardinal directions
enum COMPASS {NORTH, EAST, SOUTH, WEST}

# These are rotations in radians around Y axis 
# which corrispond to the COMPASS enum 
const DIRECTIONS = [0, -(PI/2), PI, +(PI/2)]

var item_db: Dictionary
const ITEM_DB_PATH = "items/db.json"

const GOD = false

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
