extends Node

onready var main = get_node("../../Main")
onready var water = get_node("../Water/MeshInstance")

const VU_COUNT = 16
const FREQ_MAX = 11050.0

const MIN_DB = 60

var spectrum
var mat
var visual_total1 = 0
var visual_total2 = 0

func _process(delta):
	#warning-ignore:integer_division
	var prev_hz = 0
	
	var total1 = 0;
	for i in range(0,6):	
		var hz = i * FREQ_MAX / VU_COUNT;
		var magnitude: float = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy = clamp((MIN_DB + linear2db(magnitude)) / MIN_DB, 0, 1)
		total1 += energy;
		prev_hz = hz
		
	water.scale = Vector3(1,1,1)*(1+total1/30)
		
	var total2 = 0;
	for i in range(6, VU_COUNT+1):	
		var hz = i * FREQ_MAX / VU_COUNT;
		var magnitude: float = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy = clamp((MIN_DB + linear2db(magnitude)) / MIN_DB, 0, 1)
		total2 += energy;
		prev_hz = hz;
		
	visual_total2 *= pow(0.0001,delta)
	visual_total2 += total2;
	mat.set_shader_param("spectral", 0.7+visual_total2/10)

func _ready():
	mat = water.get_surface_material(0)
	spectrum = AudioServer.get_bus_effect_instance(0,0)
