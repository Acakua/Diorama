extends OmniLight3D
## A tired corridor bulb: mostly steady, with an occasional dip or stutter.

@export var flicker_chance := 0.35
@export var emissive: MeshInstance3D

var _base := 1.0
var _next := 1.0
var _bulb_mat: StandardMaterial3D
var _bulb_energy := 1.0


func _ready() -> void:
	_base = light_energy
	if emissive and emissive.material_override:
		_bulb_mat = emissive.material_override.duplicate()
		emissive.material_override = _bulb_mat
		_bulb_energy = _bulb_mat.emission_energy_multiplier


func _process(delta: float) -> void:
	_next -= delta
	if _next > 0.0:
		return
	_next = randf_range(0.6, 3.0)
	if randf() > flicker_chance:
		return
	var t := create_tween()
	for i in randi_range(1, 4):
		var level := randf_range(0.05, 0.5)
		t.tween_callback(_set_level.bind(level))
		t.tween_interval(randf_range(0.03, 0.09))
		t.tween_callback(_set_level.bind(1.0))
		t.tween_interval(randf_range(0.04, 0.15))


func _set_level(level: float) -> void:
	light_energy = _base * level
	if _bulb_mat:
		_bulb_mat.emission_energy_multiplier = _bulb_energy * level
