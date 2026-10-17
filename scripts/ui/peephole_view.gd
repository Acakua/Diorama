class_name PeepholeView
extends CanvasLayer
## Full-screen fisheye view through the door's peephole: a second camera in a
## SubViewport that shares the room's world and only renders while open.
## The lens shader (assets/shaders/peephole.gdshader) bends and vignettes it.

signal opened
signal closed

var is_open := false
var _door: InteractiveDoor
var _lens_xform := Transform3D.IDENTITY
var _shake := 0.0
var _tween: Tween

@onready var _root: Control = $Root
@onready var _lens: Control = $Root/Lens
@onready var _viewport: SubViewport = $Root/Lens/SubViewport
@onready var _camera: Camera3D = $Root/Lens/SubViewport/Camera3D


func _ready() -> void:
	add_to_group(&"peephole_view")
	visible = false
	_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED


## `lens` is the peephole's transform; the camera looks down its -Z.
func open(lens: Transform3D, door: InteractiveDoor) -> void:
	if is_open:
		return
	is_open = true
	_door = door
	_lens_xform = lens
	_camera.global_transform = lens
	door.hit.connect(_on_hit)
	door.broken.connect(close)
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	visible = true
	_lens.pivot_offset = _lens.size * 0.5
	_fade(1.0, 0.25)
	opened.emit()


func close() -> void:
	if not is_open:
		return
	is_open = false
	if _door:
		_door.hit.disconnect(_on_hit)
		_door.broken.disconnect(close)
		_door = null
	_fade(0.0, 0.18)
	_tween.chain().tween_callback(_hide)
	closed.emit()


## The peephole camera, for tests.
func get_camera() -> Camera3D:
	return _camera


func _process(delta: float) -> void:
	if not is_open:
		return
	_shake = move_toward(_shake, 0.0, delta * 0.6)
	var jitter := Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), 0.0) * _shake * 0.03
	_camera.global_transform = _lens_xform.translated_local(jitter)


func _on_hit(damage: float) -> void:
	_shake = clampf(_shake + 0.3 + damage * 0.1, 0.0, 1.0)


func _fade(to: float, time: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_parallel()
	_tween.tween_property(_root, "modulate:a", to, time)
	_tween.tween_property(_lens, "scale", Vector2.ONE * (1.0 if to > 0.5 else 0.92), time) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _hide() -> void:
	visible = false
	_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
