extends Spatial

onready var mat = load("waterShader.tres")

func _ready():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLE_FAN )
	st.set_material(mat)
	st.add_vertex(Vector3(0, 0, 0))
	for i in range(11):
		var angle = PI*2/10*i;
		st.add_vertex(Vector3(cos(angle),0,sin(angle)))
		
	st.generate_normals()
	var mesh = Mesh.new()
	st.commit(mesh)
	var mesh_inst = MeshInstance.new()
	mesh_inst.mesh = mesh
	add_child(mesh_inst)
