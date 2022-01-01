extends Spatial

class_name ItemNode

# Of type Item, but we can't use static typing for 
# See this issue: https://www.reddit.com/r/godot/comments/hu213d/class_was_found_in_global_scope_but_its_script/
var item 
export var sprite = "placeholder"

# Called when the node enters the scene tree for the first time.
func _ready():
	print("res://items/"+item.icon+".png")
	$sprite.texture = load("res://items/"+item.icon+".png")
	scale.x = scale.x * item.resize
	scale.y = scale.y * item.resize
	scale.z = scale.z * item.resize

	
func click_handler(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
			if $"/root/main".in_hand != null: return
			$"/root/main".in_hand = item
			$"/root/main/cursor".texture = load("res://items/" + item.icon + ".png")
			#Input.set_custom_mouse_cursor(load("res://items/" + item.icon + ".png"))
			queue_free()
