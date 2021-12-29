extends Activator

func set_message(msg: String):
	actions[Activator.ACTIVE].append(Action.new($"/root/main", "show_message", [msg, 8]))
