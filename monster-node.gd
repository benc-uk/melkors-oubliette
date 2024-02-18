extends Spatial

class_name MonsterNode

# Of type Monster, but we can't use static typing for 
# See this issue: https://www.reddit.com/r/godot/comments/hu213d/class_was_found_in_global_scope_but_its_script/
var monster
var idle_x_noise: OpenSimplexNoise
var idle_z_noise: OpenSimplexNoise
var elapsed: float

func _ready():
	$sprite.texture = load("res://monsters/"+monster.sprite+".png")
	scale.x = scale.x * monster.sprite_scale
	scale.y = scale.y * monster.sprite_scale
	scale.z = scale.z * monster.sprite_scale
	$sprite.opacity = monster.sprite_opacity
	idle_x_noise = OpenSimplexNoise.new()
	idle_x_noise.seed = randi()
	idle_x_noise.octaves = 1
	idle_x_noise.period = 0.5
	idle_z_noise = OpenSimplexNoise.new()
	idle_z_noise.seed = randi()
	idle_z_noise.octaves = 1
	idle_z_noise.period = 0.5
	
func _process(delta):
	elapsed += delta
	$sprite.translation.x = idle_x_noise.get_noise_1d(elapsed) * 0.08
	$sprite.translation.z = idle_z_noise.get_noise_1d(elapsed) * 0.08
	#$sprite.translation.y = 1 + idle_z_noise.get_noise_1d(elapsed) * 0.05
