class_name InteractiveDoor
extends Interactable
## Room door on a real hinge, opening into the room.
##
## Closed, the panel's collider blocks the doorway. It switches off as soon as
## the door starts to open, and comes back after closing only once nobody is
## standing in the doorway, so the door never traps or shoves the player.
## Local space: origin at the bottom centre of the opening on the room-side
## wall face, +Z into the room, hinge on the +X side.

@export var open_angle_deg := 92.0
@export var open_time := 0.55
@export var close_time := 0.5
@export var panel_width := 0.84
## Where the player steps to (local space) when standing in the swing.
@export var stand_closed := Vector3(-0.75, 0.0, 0.7)
@export var stand_open := Vector3(-0.55, 0.0, 1.05)

const BODY_RADIUS := 0.32
const HANDLE_DOWN := -0.55

var is_open := false
var _tween: Tween
var _collision_pending := false

@onready var _pivot: Node3D = $DoorPivot
@onready var _handle: Node3D = $DoorPivot/Handle
@onready var _panel_shape: CollisionShape3D = $DoorPivot/DoorBody/CollisionShape3D
@onready var _doorway: Area3D = $DoorwayArea


func get_prompt() -> String:
	return "Close Door" if is_open else "Open Door"


func get_stand_position(player_position: Vector3) -> Variant:
	var local := to_local(player_position)
	var rel := Vector2(local.x - _pivot.position.x, local.z - _pivot.position.z)
	var in_swing := local.z > -0.05 and swing_contains(
			rel, PI, deg_to_rad(open_angle_deg), panel_width, BODY_RADIUS)
	var in_frame := local.z < 0.3 and absf(local.x) < 0.7
	if not (in_swing or in_frame):
		return null
	return to_global(stand_open if is_open else stand_closed)


func _on_interact(_player: Node3D) -> String:
	is_open = not is_open
	if _tween:
		_tween.kill()
	_tween = create_tween()
	if is_open:
		_collision_pending = false
		_panel_shape.set_deferred(&"disabled", true)
		play_sound(&"SfxOpen")
		# Press the lever, swing the door, let the lever spring back.
		_tween.tween_property(_handle, "rotation:z", HANDLE_DOWN, 0.1) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		_tween.tween_property(_pivot, "rotation:y", deg_to_rad(open_angle_deg), open_time) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_tween.parallel().tween_property(_handle, "rotation:z", 0.0, 0.2).set_delay(0.08)
	else:
		_tween.tween_property(_pivot, "rotation:y", 0.0, close_time) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_tween.tween_callback(_on_shut)
		# A small rebound off the frame.
		_tween.tween_property(_pivot, "rotation:y", deg_to_rad(1.2), 0.06) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		_tween.tween_property(_pivot, "rotation:y", 0.0, 0.1) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return "Door opened" if is_open else "Door closed"


func _physics_process(_delta: float) -> void:
	if _collision_pending and not _doorway.has_overlapping_bodies():
		_collision_pending = false
		_panel_shape.disabled = false


func _on_shut() -> void:
	play_sound(&"SfxClose")
	_collision_pending = true
	var latch := create_tween()
	latch.tween_property(_handle, "rotation:z", HANDLE_DOWN * 0.3, 0.05)
	latch.tween_property(_handle, "rotation:z", 0.0, 0.1)
