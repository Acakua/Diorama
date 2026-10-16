class_name CeilingLamp
extends Node3D
## Pendant lamp, the warm key light of the room. set_on() fades the light, the
## bulb's glow and the shade's glow together rather than snapping.

@export var light_energy := 2.4
@export var bulb_energy := 7.0
@export var shade_energy := 0.45
@export var fade_time := 0.3

var is_on := true
var _tween: Tween
var _bulb_mat: StandardMaterial3D
var _shade_mat: StandardMaterial3D

@onready var _light: OmniLight3D = $Light
@onready var _bulb: MeshInstance3D = $Bulb
@onready var _shade: MeshInstance3D = $Shade


func set_on(on: bool, time := -1.0) -> void:
	_ensure_materials()
	is_on = on
	if time < 0.0:
		time = fade_time
	if _tween:
		_tween.kill()
	var light_to := light_energy if on else 0.0
	var bulb_to := bulb_energy if on else 0.0
	var shade_to := shade_energy if on else 0.0
	_light.visible = true
	if time == 0.0:
		_light.light_energy = light_to
		_bulb_mat.emission_energy_multiplier = bulb_to
		_shade_mat.emission_energy_multiplier = shade_to
		_light.visible = on
		return
	_tween = create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(_light, "light_energy", light_to, time)
	_tween.tween_property(_bulb_mat, "emission_energy_multiplier", bulb_to, time)
	_tween.tween_property(_shade_mat, "emission_energy_multiplier", shade_to, time)
	if not on:
		# A dark light still renders its shadow map; skip that once faded out.
		_tween.chain().tween_callback(_light.hide)


func get_light_energy() -> float:
	return _light.light_energy if _light.visible else 0.0


func _ensure_materials() -> void:
	if _bulb_mat:
		return
	# Own copies, so fading this lamp never touches the shared .tres files.
	_bulb_mat = _bulb.material_override.duplicate()
	_bulb.material_override = _bulb_mat
	_shade_mat = _shade.material_override.duplicate()
	_shade.material_override = _shade_mat
