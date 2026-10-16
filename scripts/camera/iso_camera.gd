class_name IsoCamera
extends Node3D
## Isometric follow camera. The rig eases toward a point a little ahead of the
## player and a little toward the room centre, so the player gets breathing
## room and the room stays composed instead of the player being pinned to the
## middle of the screen. Mouse wheel zooms.
##
## Layout: this node holds the yaw, its "Pitch" child the downward tilt, and
## the Camera3D sits on the pitch node's +Z axis looking back at the rig.

@export var target: Node3D
## Higher follows tighter (1/s).
@export var follow_sharpness := 3.5
## Seconds of player velocity to lead the frame by.
@export var look_ahead := 0.35
## 0 = centre on the player, 1 = stay on room_center.
@export_range(0.0, 1.0) var center_pull := 0.3
@export var room_center := Vector3(0.0, 0.0, -0.2)
## The focus point is kept inside this box (XZ).
@export var bounds := AABB(Vector3(-1.8, 0.0, -1.5), Vector3(3.6, 2.0, 3.0))
## Height of the focus point; frames the room's mass rather than the floor.
@export var focus_height := 0.9
@export var zoom_min := 5.5
@export var zoom_max := 10.0
@export var zoom_step := 0.5

var _lead := Vector3.ZERO
var _zoom_target := 8.0

@onready var camera: Camera3D = $Pitch/Camera3D


func _ready() -> void:
	_zoom_target = camera.size
	if target:
		global_position = _focus_point()


func _unhandled_input(event: InputEvent) -> void:
	var button := event as InputEventMouseButton
	if button == null or not button.pressed:
		return
	if button.button_index == MOUSE_BUTTON_WHEEL_UP:
		_zoom_target = clampf(_zoom_target - zoom_step, zoom_min, zoom_max)
	elif button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_zoom_target = clampf(_zoom_target + zoom_step, zoom_min, zoom_max)


func _physics_process(delta: float) -> void:
	if target == null:
		return
	var body := target as CharacterBody3D
	var velocity := body.get_real_velocity() if body else Vector3.ZERO
	velocity.y = 0.0
	_lead = _lead.lerp(velocity * look_ahead, 1.0 - exp(-2.5 * delta))
	global_position = global_position.lerp(_focus_point(), 1.0 - exp(-follow_sharpness * delta))
	camera.size = lerpf(camera.size, _zoom_target, 1.0 - exp(-8.0 * delta))


func _focus_point() -> Vector3:
	var p := (target.global_position + _lead).lerp(room_center, center_pull)
	p.x = clampf(p.x, bounds.position.x, bounds.end.x)
	p.z = clampf(p.z, bounds.position.z, bounds.end.z)
	p.y = focus_height
	return p
