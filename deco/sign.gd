extends Switch

var message =  "I'm Jimmy Placeholder"

func _on_Area_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed == true:
			$"/root/Main".show_message(message, 8)
			
