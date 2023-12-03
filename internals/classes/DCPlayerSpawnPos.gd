@tool
class_name DCPlayerSpawnPos
extends MeshInstance3D


func _ready() -> void:
	if not Engine.is_editor_hint():
		visible = false
	else:
		_setup_for_editor()


func _setup_for_editor() -> void:
	if not mesh:
		var verts : PackedVector3Array = [
			Vector3(0, 0.001, -0.75),
			Vector3(0.5, 0.001, -0.25),
			Vector3(-0.5, 0.001, -0.25),
			Vector3(0.125, 0.001, -0.25),
			Vector3(-0.125, 0.001, -0.25),
			Vector3(-0.125, 0.001, 0.5),
			Vector3(-0.125, 0.001, 0.5),
			Vector3(0.125, 0.001, -0.25),
			Vector3(0.125, 0.001, 0.5),
		]

		# Material
		var mesh_mat : StandardMaterial3D = StandardMaterial3D.new()
		mesh_mat.albedo_color = Color.ROYAL_BLUE
		mesh_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mesh_mat.render_priority = 1
		
		# Initialize the ArrayMesh.
		var arr_mesh : ArrayMesh = ArrayMesh.new()
		var arrays = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = verts

		# Create the Mesh.
		arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
		arr_mesh.surface_set_material(0, mesh_mat)
		mesh = arr_mesh
