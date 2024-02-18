extends NinePatchRect

var slot
var player

func _ready():
	player = $"/root/main/player"
	$ctrl_left_hand/sprite.texture = null
	
func _click_handler(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
			if player.in_hand != null:
				var icon = player.in_hand.icon
				if player.in_hand.item_id == Item.TORCH_ID && player.in_hand.charge > 0:
					icon += "_charged"
				$ctrl_left_hand/sprite.texture = load("res://items/" + icon + ".png")
				if player.inventory[slot] == null:
					player.place_in_inventory(player.in_hand, slot)
					player.remove_held_item()
				else:
					var temp = player.inventory[slot]
					player.place_in_inventory(player.in_hand, slot)
					player.put_item_in_hand(temp)
			else:
				if player.inventory[slot] != null: player.put_item_in_hand(player.inventory[slot])
				player.clear_inventory_slot(slot)
				$ctrl_left_hand/sprite.texture = null
