class_name Ear
extends AudioListener3D
## Where the game listens from: the player's head, turned the way the camera
## looks, so a sound on the left of the screen is heard on the left. The
## camera itself hangs far above the diorama, too far away to hear from.

@export var height := 1.6


func _ready() -> void:
	top_level = true
	make_current()


func _process(_delta: float) -> void:
	var body := get_parent() as Node3D
	var camera := get_viewport().get_camera_3d()
	var yaw := camera.global_rotation.y if camera else 0.0
	global_transform = Transform3D(Basis(Vector3.UP, yaw), body.global_position + Vector3.UP * height)
