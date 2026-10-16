class_name PlayerController
extends CharacterBody3D
## WASD movement relative to the camera, and the "use an object" sequence:
## step clear of a swinging door if needed -> turn -> reach -> object reacts
## -> recover. Body animation lives in PlayerAnimation; this script only feeds
## it speed and reach values.

signal interaction_started(target: Interactable)
signal interaction_finished(target: Interactable)

enum State { MOVE, APPROACH, INTERACT }

@export var max_speed := 2.3
@export var acceleration := 11.0
@export var deceleration := 14.0
@export var turn_speed := 11.0
## Movement is relative to this camera's view.
@export var camera: Camera3D

@export_group("Interaction timing")
## When the arm starts to rise, after the turn has begun (s).
@export var reach_start := 0.05
## When the hand arrives and the object reacts (s).
@export var reach_time := 0.24
## When the player is free to move again (s).
@export var interact_time := 0.58
## Give up stepping to the stand point after this long (s).
@export var approach_timeout := 0.8
@export var approach_speed := 0.75

var state := State.MOVE
var facing_yaw := 0.0
## Set by tests to drive movement without a keyboard.
var scripted := false
var scripted_direction := Vector3.ZERO

var _target: Interactable
var _state_time := 0.0
var _stand_position := Vector3.ZERO
var _fired := false
var _gravity := float(ProjectSettings.get_setting("physics/3d/default_gravity"))

@onready var animator: PlayerAnimation = $Visual
@onready var detector: InteractionDetector = $InteractionDetector


func _ready() -> void:
	facing_yaw = animator.rotation.y
	animator.max_speed = max_speed


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"interact") and not event.is_echo():
		try_interact()


## Starts using the current target. Returns false when there is nothing to use
## or the player is already busy.
func try_interact() -> bool:
	if state != State.MOVE or detector.current == null:
		return false
	_target = detector.current
	var stand: Variant = _target.get_stand_position(global_position)
	if stand is Vector3:
		_stand_position = stand
		_enter(State.APPROACH)
	else:
		_enter(State.INTERACT)
	interaction_started.emit(_target)
	return true


func is_busy() -> bool:
	return state != State.MOVE


func get_facing_direction() -> Vector3:
	return Vector3(sin(facing_yaw), 0.0, cos(facing_yaw))


func _physics_process(delta: float) -> void:
	_state_time += delta
	var wish := Vector3.ZERO
	var speed_limit := max_speed
	match state:
		State.MOVE:
			wish = _read_move_input()
		State.APPROACH:
			wish = _approach_step()
			speed_limit = max_speed * approach_speed
		State.INTERACT:
			_interact_step(delta)

	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	var rate := acceleration if wish != Vector3.ZERO else deceleration
	horizontal = horizontal.move_toward(wish * speed_limit, rate * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	velocity.y = 0.0 if is_on_floor() else velocity.y - _gravity * delta
	move_and_slide()

	if state == State.MOVE and horizontal.length() > 0.2:
		_turn_toward(atan2(horizontal.x, horizontal.z), turn_speed, delta)
	elif state == State.APPROACH:
		# Keep looking at the object while stepping back or aside.
		var to := _target.get_interaction_position() - global_position
		_turn_toward(atan2(to.x, to.z), turn_speed, delta)

	var real := get_real_velocity()
	animator.speed = Vector2(real.x, real.z).length()
	animator.rotation.y = facing_yaw

	if state == State.MOVE:
		detector.update_target(global_position, get_facing_direction(), [get_rid()])


func _read_move_input() -> Vector3:
	if scripted:
		return scripted_direction.limit_length(1.0)
	var input := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	if input == Vector2.ZERO:
		return Vector3.ZERO
	var view := camera.global_basis if camera else Basis.IDENTITY
	var forward := Vector3(-view.z.x, 0.0, -view.z.z).normalized()
	var right := Vector3(view.x.x, 0.0, view.x.z).normalized()
	return (right * input.x - forward * input.y).limit_length(1.0)


func _approach_step() -> Vector3:
	var to := _stand_position - global_position
	to.y = 0.0
	var dist := to.length()
	if dist < 0.06 or _state_time > approach_timeout:
		_enter(State.INTERACT)
		return Vector3.ZERO
	# Ease in to the spot instead of overshooting it.
	return to / dist * minf(1.0, dist / 0.25)


func _interact_step(delta: float) -> void:
	var point := _target.get_interaction_position()
	var to := point - global_position
	_turn_toward(atan2(to.x, to.z), 16.0, delta)

	var t := _state_time
	var rise := smoothstep(reach_start, reach_time, t)
	var fall := smoothstep(reach_time + 0.1, interact_time, t)
	animator.reach_target = point
	animator.reach_style = _target.reach_style
	animator.reach_weight = rise * (1.0 - fall)
	# A short push or tug right after contact.
	var action_t := (t - reach_time) / 0.16
	animator.action_weight = sin(action_t * PI) if action_t > 0.0 and action_t < 1.0 else 0.0

	if not _fired and t >= reach_time:
		_fired = true
		_target.interact(self)
	if t >= interact_time:
		animator.reach_weight = 0.0
		animator.action_weight = 0.0
		var finished := _target
		_target = null
		_enter(State.MOVE)
		interaction_finished.emit(finished)


func _turn_toward(yaw: float, rate: float, delta: float) -> void:
	facing_yaw = wrapf(lerp_angle(facing_yaw, yaw, 1.0 - exp(-rate * delta)), -PI, PI)


func _enter(next: State) -> void:
	state = next
	_state_time = 0.0
	_fired = false
