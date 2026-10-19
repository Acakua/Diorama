class_name OccludedSound
extends AudioStreamPlayer3D
## A sound heard through walls and doors: while something solid stands
## between it and the listener it plays on the "Muffled" bus (low-passed and
## quieter) instead of its own. An open doorway lets it round the corner:
## if it can reach one side of an open door in the "sound_portals" group and
## the listener the other, it is heard clearly.

## Physics layers that stop sound: the walls and the doors.
@export_flags_3d_physics var blockers := 1

var _open_bus: StringName


func _ready() -> void:
	_open_bus = bus


func _physics_process(_delta: float) -> void:
	if playing:
		bus = &"Muffled" if is_blocked() else _open_bus


func is_blocked() -> bool:
	var ear := get_viewport().get_audio_listener_3d()
	var camera := get_viewport().get_camera_3d()
	if ear == null and camera == null:
		return false
	var from := ear.global_position if ear else camera.global_position
	if _clear(from, global_position):
		return false
	for portal in get_tree().get_nodes_in_group(&"sound_portals"):
		if not portal.is_open_for_sound():
			continue
		var sides: PackedVector3Array = portal.get_sound_points()
		for i in 2:
			if _clear(from, sides[i], portal) and _clear(sides[1 - i], global_position, portal):
				return false
	return true


## Nothing solid on the line from `a` to `b` (ignoring `portal`'s own bodies,
## such as an open door leaf standing in the doorway).
func _clear(a: Vector3, b: Vector3, portal: Node = null) -> bool:
	var query := PhysicsRayQueryParameters3D.create(a, b, blockers)
	if portal:
		var bodies: Array[RID] = []
		for body in portal.find_children("*", "CollisionObject3D", true, false):
			bodies.append((body as CollisionObject3D).get_rid())
		query.exclude = bodies
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()
