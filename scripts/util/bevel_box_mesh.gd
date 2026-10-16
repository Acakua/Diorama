@tool
class_name BevelBoxMesh
extends PrimitiveMesh
## Box with chamfered edges. Flat-shaded, so every bevel catches a sliver of
## light and furniture reads as "made" rather than as a grey test cube.

@export var size := Vector3.ONE:
	set(value):
		size = value
		request_update()

@export_range(0.0, 0.5, 0.001, "suffix:m") var bevel := 0.02:
	set(value):
		bevel = value
		request_update()

var _verts := PackedVector3Array()
var _normals := PackedVector3Array()
var _uvs := PackedVector2Array()


func _create_mesh_array() -> Array:
	_verts = PackedVector3Array()
	_normals = PackedVector3Array()
	_uvs = PackedVector2Array()

	var h := size * 0.5
	var b := minf(bevel, minf(h.x, minf(h.y, h.z)) * 0.95)
	var i := h - Vector3(b, b, b)
	var axes := [Vector3.RIGHT, Vector3.UP, Vector3.BACK]

	# Six inset faces.
	for a in 3:
		var u: int = (a + 1) % 3
		var v: int = (a + 2) % 3
		for s in [-1.0, 1.0]:
			var n: Vector3 = axes[a] * s
			var c: Vector3 = n * h[a]
			var eu: Vector3 = axes[u] * i[u]
			var ev: Vector3 = axes[v] * i[v]
			_quad(c - eu - ev, c + eu - ev, c + eu + ev, c - eu + ev, n)

	# Twelve edge chamfers.
	for pair in [[0, 1], [0, 2], [1, 2]]:
		var a: int = pair[0]
		var c: int = pair[1]
		var t: int = 3 - a - c
		var et: Vector3 = axes[t] * i[t]
		for sa in [-1.0, 1.0]:
			for sc in [-1.0, 1.0]:
				var p_a: Vector3 = axes[a] * sa * h[a] + axes[c] * sc * i[c]
				var p_c: Vector3 = axes[a] * sa * i[a] + axes[c] * sc * h[c]
				var n: Vector3 = (axes[a] * sa + axes[c] * sc).normalized()
				_quad(p_a - et, p_c - et, p_c + et, p_a + et, n)

	# Eight corner triangles.
	for sx in [-1.0, 1.0]:
		for sy in [-1.0, 1.0]:
			for sz in [-1.0, 1.0]:
				var n := Vector3(sx, sy, sz).normalized()
				_tri(Vector3(sx * h.x, sy * i.y, sz * i.z),
					Vector3(sx * i.x, sy * h.y, sz * i.z),
					Vector3(sx * i.x, sy * i.y, sz * h.z), n)

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = _verts
	arrays[Mesh.ARRAY_NORMAL] = _normals
	arrays[Mesh.ARRAY_TEX_UV] = _uvs
	return arrays


func _quad(p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, n: Vector3) -> void:
	_tri(p0, p1, p2, n)
	_tri(p0, p2, p3, n)


func _tri(a: Vector3, b: Vector3, c: Vector3, n: Vector3) -> void:
	# Godot treats clockwise triangles as front faces.
	if (b - a).cross(c - a).dot(n) > 0.0:
		var tmp := b
		b = c
		c = tmp
	for p in [a, b, c]:
		_verts.append(p)
		_normals.append(n)
		_uvs.append(_planar_uv(p, n))


func _planar_uv(p: Vector3, n: Vector3) -> Vector2:
	var an := n.abs()
	if an.x >= an.y and an.x >= an.z:
		return Vector2(p.z, -p.y)
	if an.y >= an.z:
		return Vector2(p.x, p.z)
	return Vector2(p.x, -p.y)
