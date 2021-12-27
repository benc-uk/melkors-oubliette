extends Spatial

var door1

func _ready():
	$Map.add_cell(0, 1)
	$Map.add_cell(1, 1)
	$Map.add_cell(2, 1)
#	$Map.add_cell(1, 1)
	$Map.add_cell(1, 2)
	$Map.add_cell(1, 3)
	$Map.add_cell(1, 4)
	$Map.add_cell(1, 5)
	$Map.add_cell(1, 6)
	$Map.add_cell(2, 6)
	$Map.add_cell(1, 7)
	$Map.add_cell(1, 8)
	$Map.add_cell(2, 8)
	$Map.add_cell(2, 4)
	$Map.add_cell(3, 4)
	$Map.add_cell(4, 4)
	$Map.add_cell(5, 4)
	$Map.add_cell(6, 4)
	$Map.add_cell(3, 3)
	$Map.add_cell(1, 0)
	
	$Map.add_cell(7, 3)
	$Map.add_cell(7, 4)
	$Map.add_cell(7, 5)
	$Map.add_cell(8, 3)
	$Map.add_cell(8, 4)
	$Map.add_cell(8, 5)
	
	$Map.get_cell(1, 0).add_wall_furnishing("torch")
	$Map.get_cell(8, 5).add_wall_furnishing("torch", global.COMPASS.EAST)
	$Map.get_cell(1, 5).add_wall_furnishing("torch", global.COMPASS.WEST)
	var sw1 = $Map.get_cell(3, 4).add_wall_furnishing("push-switch", global.COMPASS.SOUTH)
	var sw = $Map.get_cell(1, 3).add_wall_furnishing("push-switch", global.COMPASS.EAST)
	sw.connect("activated", self, "opendoor")
	sw1.connect("activated", self, "opendoor")

	door1 = $Map.get_cell(2, 4).add_door(global.COMPASS.WEST, Door.types.WOOD, false, false, false)
	var door2 = $Map.get_cell(1, 7).add_door(global.COMPASS.NORTH, Door.types.PORT, false)

	$Map.get_cell(8, 3).add_wall_furnishing("crates", global.COMPASS.EAST)
	$Map.get_cell(8, 4).add_wall_furnishing("crates", global.COMPASS.EAST)
	
	$Map.get_cell(7, 5).add_center_furnishing("pillar")
	$Map.get_cell(7, 5).add_center_furnishing("pillar")
	$Map.add_cell(7, 6)
	$Map.add_cell(8, 6)
	$Map.add_cell(9, 6)
	$Map.add_cell(6, 5)
	$Map.add_cell(6, 6)
	$Player.move_to($Map.get_cell(3, 4))
	$Player.set_facing(global.COMPASS.WEST)
	
	$Music.play()

func opendoor():
	door1.toggle_open()
