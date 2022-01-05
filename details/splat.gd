extends Spatial

class_name Splat

export var color_r = 0.5
export var color_g = 0.5
export var color_b = 0.5
export var min_size = 0.2
export var max_size = 2.5
export var min_alpha = 0.2
export var max_alpha = 0.9

func _ready():
	randomize()
	rotate_y(randf() * 180)
	var size = min_size + randf() * (max_size - min_size)
	scale.x = size
	scale.z = size
	var mat = $mesh.get_surface_material(0).duplicate()
	mat.albedo_color = Color(color_r, color_g, color_b)
	mat.albedo_color.a = min_alpha + randf() * (max_alpha - min_alpha)
	$mesh.set_surface_material(0, mat)

func blood():
	color_r = 0.76
	color_g = 0.14
	color_b = 0.10
	
func water():
	color_r = 0.192
	color_g = 0.576
	color_b = 0.749
	
func mud():
	color_r = 0.521
	color_g = 0.313
	color_b = 0.105
	
func grey():
	color_r = 0.4
	color_g = 0.4
	color_b = 0.4
