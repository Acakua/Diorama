class_name Zombie
extends Node3D
## The thing outside. No navigation: it walks the paths the night script gives
## it, stands at the door, and chooses between a light knock, hard knocks and
## banging from how much light and noise it has noticed in the room. Left in
## the dark and the quiet long enough, it gives up and walks away.

signal arrived_at_door
signal left
signal broke_in

enum State { OFFSTAGE, WALK, IDLE, AT_DOOR, BREAK_IN }

@export var door: InteractiveDoor
@export var lamp: CeilingLamp
@export var radio: InteractiveRadio
@export var player: PlayerController
@export var walk_speed := 0.5
@export var groans: Array[AudioStream] = []

@export_group("Attention")
## Gained per second while the room light is on.
@export var light_gain := 0.1
## Gained per second while the radio is on.
@export var radio_gain := 0.15
## Gained per second while the player walks within `step_range` of the door.
@export var step_gain := 0.08
@export var step_range := 2.2
## Lost per second while nothing gives the room away.
@export var decay := 0.05
## Gains count this much while it is not at the door (passing the window).
@export var outside_factor := 0.4
## Seconds of near-silence at the door before it gives up.
@export var give_up_time := 20.0

@export_group("Hits")
@export var knock_damage := 0.5
@export var bang_damage := 1.5

var state := State.OFFSTAGE
## 0..1, how sure it is that someone is inside.
var attention := 0.0
## 0..1 floor on its fury, set by the night script (the climax ignores how
## quiet the room is).
var aggression := 0.0

var _path: Array[Vector3] = []
var _path_end: StringName = &"door"
var _face_point := Vector3.INF
var _exit_path: Array[Vector3] = []
var _break_in_path: Array[Vector3] = []
var _hit_timer := 0.0
var _quiet_time := 0.0
var _groan_timer := 3.0
var _step_timer := 0.0
var _swing_time := 10.0
var _swing_strength := 0.0
var _time := 0.0

@onready var _anim: PlayerAnimation = $Visual
@onready var _voice: AudioStreamPlayer3D = $Voice
@onready var _steps: AudioStreamPlayer3D = $Steps


func _ready() -> void:
	visible = false
	add_to_group(&"listeners")
	door.opened_by_player.connect(_on_door_opened)


## A noise somewhere (see GameState.noise()). Hammering right at the door it
## stands at gets its full attention; from the corridor it hears less.
func hear(_position: Vector3, loudness: float) -> void:
	if state == State.AT_DOOR:
		attention = clampf(attention + loudness, 0.0, 1.0)
	elif state == State.WALK and visible:
		attention = clampf(attention + loudness * 0.5, 0.0, 1.0)


## Paths used when it gives up on the door and when it gets in.
func set_routes(exit_path: Array[Vector3], break_in_path: Array[Vector3]) -> void:
	_exit_path = exit_path
	_break_in_path = break_in_path


## Appears at the first point and walks the rest. `end` is &"door" (stand at
## the door), &"stop" (stand still facing `face_point`) or &"gone" (disappear).
func walk(points: Array[Vector3], end: StringName, face_point := Vector3.INF) -> void:
	_path = points.duplicate()
	_path_end = end
	_face_point = face_point
	global_position = _path.pop_front()
	visible = true
	state = State.WALK


func leave() -> void:
	if state != State.AT_DOOR:
		return
	var points: Array[Vector3] = [global_position]
	points.append_array(_exit_path)
	walk(points, &"gone")


func is_at_door() -> bool:
	return state == State.AT_DOOR


## How dangerous it is right now (0 when not at the door), for the heartbeat.
func danger() -> float:
	return maxf(attention, aggression) if state == State.AT_DOOR else 0.0


func _physics_process(delta: float) -> void:
	_time += delta
	match state:
		State.WALK, State.BREAK_IN:
			_walk_step(delta)
		State.IDLE:
			_anim.speed = 0.0
		State.AT_DOOR:
			_door_step(delta)
	_update_attention(delta)
	_update_sounds(delta)
	_update_swing(delta)


func _walk_step(delta: float) -> void:
	if _path.is_empty():
		_arrive()
		return
	var to := _path[0] - global_position
	var step := walk_speed * (1.8 if state == State.BREAK_IN else 1.0) * delta
	if to.length() <= step:
		global_position = _path.pop_front()
	else:
		global_position += to.normalized() * step
	if Vector2(to.x, to.z).length() > 0.01:
		rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), 1.0 - exp(-6.0 * delta))
	_anim.speed = walk_speed


func _arrive() -> void:
	_anim.speed = 0.0
	match state:
		State.BREAK_IN:
			state = State.OFFSTAGE  # stays visible in the room
		_:
			if _path_end == &"stop":
				state = State.IDLE
				if _face_point != Vector3.INF:
					var to_face := _face_point - global_position
					rotation.y = atan2(to_face.x, to_face.z)
			elif _path_end == &"door":
				state = State.AT_DOOR
				_quiet_time = 0.0
				_hit_timer = 1.2
				var to := door.global_position - global_position
				rotation.y = atan2(to.x, to.z)
				arrived_at_door.emit()
			else:
				state = State.OFFSTAGE
				visible = false
				left.emit()


func _door_step(delta: float) -> void:
	_anim.speed = 0.0
	if door.is_open or door.is_broken:
		_break_in()
		return
	var level := maxf(attention, aggression)
	_quiet_time = _quiet_time + delta if level < 0.15 and aggression <= 0.0 else 0.0
	if _quiet_time > give_up_time:
		leave()
		return
	_hit_timer -= delta
	if _hit_timer > 0.0:
		return
	if level >= 0.7:
		door.take_hit(bang_damage, true)
		_swing(1.0)
		_hit_timer = randf_range(1.0, 1.4)
	elif level >= 0.35:
		door.take_hit(knock_damage, false)
		_swing(0.6)
		_hit_timer = randf_range(2.2, 3.0)
	else:
		door.knock()
		_swing(0.35)
		_hit_timer = randf_range(4.0, 6.0)


func _update_attention(delta: float) -> void:
	if state != State.WALK and state != State.IDLE and state != State.AT_DOOR:
		return
	var gain := 0.0
	if lamp.is_on:
		gain += light_gain
	if radio.is_on:
		gain += radio_gain
	if GameState.flashlight_on and state == State.AT_DOOR:
		gain += light_gain * 0.35
	if state == State.AT_DOOR:
		var near := player.global_position.distance_to(door.global_position) < step_range
		if near and player.get_real_velocity().length() > 0.3:
			gain += step_gain
	else:
		gain *= outside_factor
	attention = clampf(attention + (gain if gain > 0.0 else -decay) * delta, 0.0, 1.0)


func _break_in() -> void:
	if state == State.BREAK_IN:
		return
	state = State.BREAK_IN
	_path = _break_in_path.duplicate()
	_anim.reach_both = true
	_anim.reach_style = &"press"
	broke_in.emit()


func _on_door_opened() -> void:
	if state == State.AT_DOOR:
		_break_in()


## Starts an arm swing at the door: 0.35 tap, 0.6 knock, 1.0 two-handed bang.
func _swing(strength: float) -> void:
	_swing_time = 0.0
	_swing_strength = strength


func _update_swing(delta: float) -> void:
	_swing_time += delta
	if state == State.BREAK_IN:
		# Arms out toward the room as it lurches in.
		_anim.reach_target = global_position + global_basis.z * 2.0 + Vector3.UP * 1.3
		_anim.reach_weight = move_toward(_anim.reach_weight, 1.0, delta * 3.0)
		return
	var t := _swing_time / (0.25 + 0.2 * _swing_strength)
	_anim.reach_both = _swing_strength > 0.8
	_anim.reach_target = door.global_position + Vector3.UP * (1.1 + 0.3 * _swing_strength)
	_anim.reach_weight = sin(clampf(t, 0.0, 1.0) * PI) * (0.6 + 0.4 * _swing_strength)
	_anim.action_weight = _anim.reach_weight * _swing_strength
	# Sway on the spot.
	var standing := state == State.AT_DOOR or state == State.IDLE
	_anim.rotation.z = sin(_time * 0.9) * 0.05 if standing else 0.0


func _update_sounds(delta: float) -> void:
	if not visible:
		return
	_groan_timer -= delta
	if _groan_timer <= 0.0 and not groans.is_empty():
		_groan_timer = randf_range(5.0, 11.0)
		_voice.stream = groans.pick_random()
		_voice.pitch_scale = randf_range(0.85, 1.05)
		_voice.play()
	if state == State.WALK or state == State.BREAK_IN:
		_step_timer -= delta
		if _step_timer <= 0.0:
			_step_timer = 0.9
			_steps.play()
