extends Activator

var light_noise: OpenSimplexNoise
var elapsed: float

func _ready():
	light_noise = OpenSimplexNoise.new()
	light_noise.seed = randi()
	light_noise.octaves = 1
	light_noise.period = 1.2

func _process(delta):
	elapsed += delta
	var modifier = (light_noise.get_noise_1d(elapsed) + 1 ) / 2
	$light.light_energy = 0.2 + modifier
