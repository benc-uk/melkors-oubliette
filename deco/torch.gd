extends Spatial

var noise: OpenSimplexNoise
var elapsed: float

func _ready():
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 1
	noise.period = 1.2

func _process(delta):
	elapsed += delta
	var modifier = (noise.get_noise_1d(elapsed) + 1 ) / 2
	get_node("Container/Light").light_energy = 0.2 + modifier
