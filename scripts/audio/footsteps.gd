class_name Footsteps
extends AudioStreamPlayer3D
## A footstep each time the walking body plants a foot, taken from a few takes
## of the floor it walks on (assets/audio/step_<surface>_<n>.wav). The place
## sets the surface; slower steps land softer.

const TAKES := 6

@export var animator: PlayerAnimation

var _base_db := 0.0


func _ready() -> void:
	_base_db = volume_db
	max_polyphony = 2
	animator.stepped.connect(_on_stepped)
	set_surface(&"wood")


## Switches the step sounds to another floor (wood, carpet).
func set_surface(surface: StringName) -> void:
	var takes := AudioStreamRandomizer.new()
	takes.random_pitch = 1.06
	takes.random_volume_offset_db = 1.5
	for i in TAKES:
		var path := "res://assets/audio/step_%s_%d.wav" % [surface, i]
		if ResourceLoader.exists(path):
			takes.add_stream(-1, load(path))
	stream = takes


func _on_stepped() -> void:
	var pace := clampf(animator.speed / animator.max_speed, 0.25, 1.0)
	volume_db = _base_db + linear_to_db(pace)
	play()
