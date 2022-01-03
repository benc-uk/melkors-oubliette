extends Activator

class_name ItemContainer

export var max_items = 1
export var item_offsets: Vector3 = Vector3.ZERO

var player

func _init():
	is_container = true
	
func _ready():
	player = $"/root/main/player"
	
	# default action placed in front of all other actions
	actions[ACTIVE].push_front(Action.new(self, "add_item", [true, null]))

func add_item(from_player = true, item = null):
	if $item_container.get_child_count() >= max_items: return
	if from_player: 
		if player.in_hand != null:
			var node = player.in_hand.make_node()
			node.connect("picked_up", self, "remove_item")
			node.translation += (item_offsets * $item_container.get_child_count())
			$item_container.add_child(node)
			player.remove_item_in_hand()
	else:
		$item_container.add_child(item.make_node())
		
func add_new_item(item_id: String):
	var item = Item.new(item_id)
	$item_container.add_child(item.make_node())
	
func contains_item_id(id):
	for child in $item_container.get_children():
		if child.item.item_id == id: return true
	return false

func remove_item():
	deactivated()

# Needed to push all items into the right place when they are removed
func _process(delta):
	var item_num = 0
	for item_node in $item_container.get_children():
		item_node.translation = (item_offsets * item_num)
		item_num += 1
