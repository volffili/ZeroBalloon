extends Spatial
class_name Item

onready var main = get_node("/root/Main")
onready var sfx_click = get_node("./Click")

var dead = false
var death_progress = 0
var destination = Vector3(0,0,0)
		
func set_destination(dest):
	destination = dest

func click():
	if !dead:
		dead = true
		death_progress = 0;
	
func _process(delta):
	if dead:
		death_progress += delta*4
		translation = translation.linear_interpolate(destination,min(1,death_progress));
		if death_progress > 1:
			dead = false
			main.kill(self)
