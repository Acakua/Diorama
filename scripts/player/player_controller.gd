class_name PlayerController
extends CharacterBody3D
## WASD movement relative to the camera, and the "use an object" sequence:
## step clear of a swinging door if needed -> turn -> reach -> object reacts
## -> recover. The same sequence covers every action key:
##   E  use the target (some need E held, like searching), hand it the carried
##      item, or put the item down;
##   F  the target's second action, which may hold the player in place, like
##      looking through the peephole;
##   R  use something from the bag on the target (some held, like nailing).
## Q toggles the flashlight. With the mouse, walk_to() follows a path over the
## place's navigation mesh and command() walks up to an object and then runs
## the same sequence, holding held actions by itself. Body animation lives in
## PlayerAnimation; this script only feeds it speed, reach and carry values.

signal interaction_started(target: Interactable)
signal interaction_finished(target: Interactable)
## A short message for the player, e.g. why something didn't work.
signal notice(text: String)

enum State { MOVE, APPROACH, INTERACT, HOLD, FOCUS }

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
## Off while an end screen is up.
var controls_enabled := true
## The item in the player's hands, if any.
var carried: Carryable = null
## Set by tests to drive the player without a keyboard.
var scripted := false
var scripted_direction := Vector3.ZERO
var scripted_hold := false
## Set when an action was started by a click: a held action keeps going alone.
var auto_hold := false

var _target: Interactable
## &"use" (E), &"give" (E while carrying), &"alt" (F) or &"item" (R).
var _mode: StringName = &"use"
var _state_time := 0.0
var _stand_position := Vector3.ZERO
var _fired := false
var _hold := 0.0
var _hold_time := 0.0
var _focus_point := Vector3.ZERO
var _focus_end := Callable()
var _focus_prompts := PackedStringArray(["", "Stop Looking", ""])
var _gravity := float(ProjectSettings.get_setting("physics/3d/default_gravity"))
var _path := PackedVector3Array()
var _path_i := 0
var _pending: Interactable = null
var _pending_mode: StringName = &"use"
var _stuck := 0.0

@onready var animator: PlayerAnimation = $Visual
@onready var detector: InteractionDetector = $InteractionDetector
@onready var hold_point: Node3D = $Visual/HoldPoint
@onready var flashlight: SpotLight3D = $Visual/Flashlight
@onready var _flashlight_energy := flashlight.light_energy


func _ready() -> void:
	facing_yaw = animator.rotation.y
	animator.max_speed = max_speed


func _unhandled_input(event: InputEvent) -> void:
	if not controls_enabled or event.is_echo():
		return
	if state == State.FOCUS:
		if event.is_action_pressed(&"interact") or event.is_action_pressed(&"use_alt") \
				or event.is_action_pressed(&"ui_cancel"):
			end_focus()
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"interact"):
		try_interact()
	elif event.is_action_pressed(&"use_alt"):
		try_secondary()
	elif event.is_action_pressed(&"use_item"):
		try_use_item()
	elif event.is_action_pressed(&"flashlight"):
		toggle_flashlight()


## Walks to the walkable spot closest to `point` (a click on the floor).
func walk_to(point: Vector3) -> void:
	if state == State.FOCUS:
		end_focus()
		return
	if state == State.HOLD:
		_cancel()
	if state != State.MOVE or not controls_enabled:
		return
	_pending = null
	_set_path(point)


## Walks up to `target` (if needed) and runs `mode` on it: &"use", &"give",
## &"alt" or &"item". Held actions keep going by themselves.
func command(target: Interactable, mode: StringName) -> void:
	if state == State.FOCUS:
		end_focus()
	if state == State.HOLD:
		_cancel()
	if state != State.MOVE or not controls_enabled:
		return
	_pending = target
	_pending_mode = mode
	if _can_reach(target):
		_start_pending()
	else:
		_set_path(target.get_interaction_position())


## Stops walking or a held action (a click elsewhere).
func cancel_action() -> void:
	if state == State.HOLD:
		_cancel()
	_clear_path()


func is_walking() -> bool:
	return not _path.is_empty()


## [label, mode] pairs `target` offers right now, primary first.
func get_actions(target: Interactable) -> Array:
	var actions := []
	if target == null or not target.is_available():
		return actions
	if carried:
		if target.accepts(carried):
			actions.append([target.get_accept_prompt(carried), &"give"])
		return actions
	var use := target.get_prompt()
	if use != "":
		actions.append([use, &"use"])
	var alt := target.get_secondary_prompt()
	if alt != "":
		actions.append([alt, &"alt"])
	var item := target.get_item_prompt()
	if item != "":
		actions.append([item, &"item"])
	return actions


## E: use the current target, hand it the carried item, or put the item down.
## Returns false when nothing happened.
func try_interact() -> bool:
	auto_hold = false
	if state != State.MOVE:
		return false
	var target := detector.current
	if carried:
		if target and target.accepts(carried):
			return _start(target, &"give")
		return put_down()
	if target == null:
		return false
	return _start(target, &"use")


## F: the current target's second action (or stop looking, while focused).
func try_secondary() -> bool:
	if state == State.FOCUS:
		end_focus()
		return true
	var target := detector.current
	if state != State.MOVE or carried or target == null or target.get_secondary_prompt() == "":
		return false
	return _start(target, &"alt")


## R: use something from the bag on the current target.
func try_use_item() -> bool:
	auto_hold = false
	var target := detector.current
	if state != State.MOVE or carried or target == null or target.get_item_prompt() == "":
		return false
	return _start(target, &"item")


func toggle_flashlight() -> void:
	if not GameState.has_tool(&"flashlight"):
		notice.emit("I don't have a flashlight.")
		return
	GameState.set_flashlight(not GameState.flashlight_on)


## Holds the player still, leaning toward `point`, until end_focus().
## `on_end` runs when the focus ends; `prompts` replace the HUD prompts.
func begin_focus(point: Vector3, on_end: Callable,
		prompts := PackedStringArray(["", "Stop Looking", ""])) -> void:
	_focus_point = point
	_focus_end = on_end
	_focus_prompts = prompts
	_enter(State.FOCUS)


func end_focus() -> void:
	if state != State.FOCUS:
		return
	var on_end := _focus_end
	_focus_end = Callable()
	_target = null
	_enter(State.MOVE)
	if on_end.is_valid():
		on_end.call()


func pick_up(item: Carryable) -> void:
	carried = item
	item.attach_to(hold_point, self)
	animator.carrying = true


## Puts the carried item down in front of the player if there is room.
func put_down() -> bool:
	if carried == null:
		return false
	var spot := global_position + get_facing_direction() * 0.75
	var xform := Transform3D(Basis(Vector3.UP, facing_yaw), spot)
	if not _has_room(xform, carried.footprint):
		notice.emit("No room to put it down here")
		return false
	var item := carried
	_release_carried()
	item.place_at(xform)
	item.play_sound(&"SfxPickup")
	return true


func is_busy() -> bool:
	return state != State.MOVE


## 0..1 while a held action (searching, nailing) is in progress.
func get_hold_progress() -> float:
	return clampf(_hold / _hold_time, 0.0, 1.0) if state == State.HOLD and _hold_time > 0.0 else 0.0


## [E, F, R] prompt texts for the HUD; "" for none.
func get_prompts() -> PackedStringArray:
	if not controls_enabled:
		return ["", "", ""]
	if state == State.FOCUS:
		return _focus_prompts
	if state != State.MOVE:
		return ["", "", ""]
	var target := detector.current
	if carried:
		if target and target.accepts(carried):
			return [target.get_accept_prompt(carried), "", ""]
		return ["Put Down %s" % carried.interaction_name, "", ""]
	if target == null:
		return ["", "", ""]
	var use := target.get_prompt()
	if target.get_hold_time() > 0.0:
		use += " (hold)"
	var item := target.get_item_prompt()
	if item != "" and target.get_item_hold_time() > 0.0:
		item += " (hold)"
	return [use, target.get_secondary_prompt(), item]


## The object the current prompt refers to, if any.
func get_prompt_target() -> Interactable:
	if not controls_enabled:
		return null
	if state == State.HOLD:
		return _target
	if state != State.MOVE:
		return null
	if carried and not (detector.current and detector.current.accepts(carried)):
		return null
	return detector.current


func get_facing_direction() -> Vector3:
	return Vector3(sin(facing_yaw), 0.0, cos(facing_yaw))


func _process(_delta: float) -> void:
	flashlight.visible = GameState.flashlight_on
	if flashlight.visible:
		# A dying battery stutters.
		var low := GameState.flashlight_charge < 0.15 and randf() < 0.08
		flashlight.light_energy = _flashlight_energy * (randf_range(0.1, 0.5) if low else 1.0)


func _physics_process(delta: float) -> void:
	if not controls_enabled and (state == State.FOCUS or state == State.HOLD):
		_cancel()
	_state_time += delta
	var wish := Vector3.ZERO
	var speed_limit := max_speed * (carried.carry_speed if carried else 1.0)
	match state:
		State.MOVE:
			wish = _read_move_input()
			if wish != Vector3.ZERO:
				_clear_path()
				_pending = null
			elif _pending and _can_reach(_pending):
				_clear_path()
				_start_pending()
			elif not _path.is_empty():
				wish = _follow_path(delta)
		State.APPROACH:
			wish = _approach_step()
			speed_limit *= approach_speed
		State.INTERACT:
			_interact_step(delta)
		State.HOLD:
			_hold_step(delta)
		State.FOCUS:
			_focus_step(delta)

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

	if state == State.MOVE:
		animator.reach_weight = move_toward(animator.reach_weight, 0.0, delta * 4.0)
	var real := get_real_velocity()
	animator.speed = Vector2(real.x, real.z).length()
	animator.rotation.y = facing_yaw

	if state == State.MOVE:
		detector.update_target(global_position, get_facing_direction(), [get_rid()], carried)


func _read_move_input() -> Vector3:
	if scripted:
		return scripted_direction.limit_length(1.0)
	if not controls_enabled:
		return Vector3.ZERO
	var input := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	if input == Vector2.ZERO:
		return Vector3.ZERO
	var view := camera.global_basis if camera else Basis.IDENTITY
	var forward := Vector3(-view.z.x, 0.0, -view.z.z).normalized()
	var right := Vector3(view.x.x, 0.0, view.x.z).normalized()
	return (right * input.x - forward * input.y).limit_length(1.0)


func _start(target: Interactable, mode: StringName) -> bool:
	var reason := target.get_block_reason(mode)
	if reason != "":
		notice.emit(reason)
		return false
	_target = target
	_mode = mode
	match mode:
		&"use":
			_hold_time = target.get_hold_time()
		&"item":
			_hold_time = target.get_item_hold_time()
		_:
			_hold_time = 0.0
	var stand: Variant = target.get_secondary_stand_position(global_position) if mode == &"alt" \
			else target.get_stand_position(global_position)
	if stand is Vector3:
		_stand_position = stand
		_enter(State.APPROACH)
	else:
		_enter(State.INTERACT)
	interaction_started.emit(target)
	return true


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
		if _hold_time > 0.0:
			_hold = 0.0
			_enter(State.HOLD)
			return
		_fire()
		if state != State.INTERACT:
			return  # the object put us into another state (e.g. focus)
	if t >= interact_time:
		_finish()


func _hold_step(delta: float) -> void:
	var point := _target.get_interaction_position()
	var to := point - global_position
	_turn_toward(atan2(to.x, to.z), 16.0, delta)
	animator.reach_target = point
	animator.reach_style = _target.reach_style
	animator.reach_weight = 0.9
	# Rummaging / hammering.
	animator.action_weight = 0.5 + 0.5 * sin(_state_time * 14.0)
	var key := &"use_item" if _mode == &"item" else &"interact"
	if not (scripted_hold or auto_hold or (controls_enabled and Input.is_action_pressed(key))):
		_cancel()
		return
	_hold += delta
	_target.on_hold_tick(self, _mode, delta)
	if _hold >= _hold_time:
		_fire()
		# Let the arm come back down as after a normal action.
		_enter(State.INTERACT)
		_state_time = reach_time + 0.1
		_fired = true


func _fire() -> void:
	_fired = true
	match _mode:
		&"use":
			_target.interact(self)
		&"give":
			var item := carried
			_release_carried()
			_target.receive(item, self)
		&"alt":
			_target.secondary_interact(self)
		&"item":
			_target.use_item(self)


func _finish() -> void:
	auto_hold = false
	animator.reach_weight = 0.0
	animator.action_weight = 0.0
	var finished := _target
	_target = null
	_enter(State.MOVE)
	interaction_finished.emit(finished)


func _cancel() -> void:
	auto_hold = false
	if state == State.FOCUS:
		end_focus()
		return
	animator.action_weight = 0.0
	_target = null
	_enter(State.MOVE)


func _focus_step(delta: float) -> void:
	var to := _focus_point - global_position
	_turn_toward(atan2(to.x, to.z), 16.0, delta)
	animator.reach_target = _focus_point
	animator.reach_style = &"press"
	animator.reach_weight = move_toward(animator.reach_weight, 0.55, delta * 4.0)
	animator.action_weight = 0.0
	if _read_move_input() != Vector3.ZERO:
		end_focus()


func _start_pending() -> void:
	var target := _pending
	_pending = null
	if target == null or not target.is_available():
		return
	auto_hold = true
	if not _start(target, _pending_mode):
		auto_hold = false


func _can_reach(target: Interactable) -> bool:
	var to := target.get_interaction_position() - global_position
	to.y = 0.0
	return to.length() <= target.interaction_range * 0.85 			and detector.has_line_of_sight(global_position, target, [get_rid()])


func _set_path(point: Vector3) -> void:
	var map := get_world_3d().navigation_map
	var goal := NavigationServer3D.map_get_closest_point(map, Vector3(point.x, global_position.y, point.z))
	_path = NavigationServer3D.map_get_path(map, global_position, goal, true)
	_path_i = 0
	_stuck = 0.0


func _clear_path() -> void:
	_path = PackedVector3Array()
	_path_i = 0


## Steering toward the next waypoint; slows down for the last one.
func _follow_path(delta: float) -> Vector3:
	while _path_i < _path.size():
		var to := _path[_path_i] - global_position
		to.y = 0.0
		if to.length() > (0.08 if _path_i == _path.size() - 1 else 0.2):
			break
		_path_i += 1
	if _path_i >= _path.size():
		_clear_path()
		if _pending:
			notice.emit("I can't reach that from here.")
			_pending = null
		return Vector3.ZERO
	var next := _path[_path_i] - global_position
	next.y = 0.0
	var last := _path[_path.size() - 1] - global_position
	last.y = 0.0
	# Give up if a wall or the furniture holds us in place.
	_stuck = _stuck + delta if get_real_velocity().length() < 0.15 else 0.0
	if _stuck > 0.8:
		_clear_path()
		_pending = null
		return Vector3.ZERO
	return next.normalized() * minf(1.0, last.length() / 0.35 + 0.25)


func _release_carried() -> void:
	carried = null
	animator.carrying = false


func _has_room(xform: Transform3D, size: Vector3) -> bool:
	var box := BoxShape3D.new()
	box.size = size
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = box
	query.transform = xform.translated_local(Vector3(0.0, size.y * 0.5 + 0.03, 0.0))
	query.collision_mask = 1 | 2
	query.exclude = [get_rid()]
	return get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()


func _turn_toward(yaw: float, rate: float, delta: float) -> void:
	facing_yaw = wrapf(lerp_angle(facing_yaw, yaw, 1.0 - exp(-rate * delta)), -PI, PI)


func _enter(next: State) -> void:
	state = next
	_state_time = 0.0
	_fired = false
