class_name InteractiveCabinet
extends Interactable
## Cabinet with one door on a hinge at its left edge, so the open door ends up
## on the far side from the camera and the shelves stay in view.
##
## The cabinet body's collider also covers the closed door; the door itself has
## no collider, so open or closed it never blocks the player.
## Local space: origin at the floor centre of the footprint, front faces +Z.

@export var open_angle_deg := -100.0
@export var open_time := 0.5
@export var close_time := 0.42
@export var door_width := 0.764

var is_open := false
var _tween: Tween
var _handle_rest := Vector3.ZERO

@onready var _pivot: Node3D = $DoorPivot
@onready var _handle: Node3D = $DoorPivot/Handle
@onready var _stand: Marker3D = $StandPoint


func _ready() -> void:
	super()
	_handle_rest = _handle.position


func get_prompt() -> String:
	return "Close Cabinet" if is_open else "Open Cabinet"


func get_stand_position(player_position: Vector3) -> Variant:
	var local := to_local(player_position)
	var rel := Vector2(local.x - _pivot.position.x, local.z - _pivot.position.z)
	if local.z > 0.1 and swing_contains(rel, 0.0, deg_to_rad(open_angle_deg), door_width, 0.3):
		return _stand.global_position
	return null


func _on_interact(_player: Node3D) -> String:
	is_open = not is_open
	if _tween:
		_tween.kill()
	_tween = create_tween()
	if is_open:
		play_sound(&"SfxOpen")
		# Tug the handle, then the door follows: quick start, soft stop.
		_tween.tween_property(_handle, "position:z", _handle_rest.z + 0.012, 0.07) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		_tween.tween_property(_pivot, "rotation:y", deg_to_rad(open_angle_deg), open_time) \
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_tween.parallel().tween_property(_handle, "position:z", _handle_rest.z, 0.15)
	else:
		_tween.tween_property(_pivot, "rotation:y", 0.0, close_time) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_tween.tween_callback(play_sound.bind(&"SfxClose"))
		_tween.tween_property(_pivot, "rotation:y", deg_to_rad(-2.0), 0.05) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		_tween.tween_property(_pivot, "rotation:y", 0.0, 0.09) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return "Cabinet opened" if is_open else "Cabinet closed"
