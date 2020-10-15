extends MeshInstance

var sin_mov = 0
	
func _process(delta):
	sin_mov += delta
	translate(Vector3(0,sin(sin_mov)/2000,0))


