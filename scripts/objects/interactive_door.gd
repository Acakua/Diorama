class_name InteractiveDoor
extends Interactable
## A door on a real hinge, opening away from the side the player usually uses.
##
## Closed, the panel's collider blocks the doorway. It switches off as soon as
## the door starts to open, and comes back after closing only once nobody is
## standing in the doorway, so the door never traps or shoves the player.
##
## Barricades: a chair wedged under the handle (E with the chair in hand) and
## up to three planks nailed across (R, needs a hammer, light and time, and
## makes noise). Either keeps the door shut; heavy blows can tear a plank off.
## It has health and shows each hit (jolt, dust, cracks, camera shake), has a
## peephole (F), can be locked, and can be broken open.
##
## A door seen from two places (the home door from the corridor) shares its
## state through `shared_key`.
## Local space: origin at the bottom centre of the opening on the swing-side
## wall face, +Z toward the swing side, hinge on the +X side.

## The player opened the door (the zombie listens for this).
signal opened_by_player
## Something hit the door; `damage` is what it actually lost.
signal hit(damage: float)
signal broken
## A plank was torn off by a blow.
signal plank_torn

@export var open_angle_deg := 92.0
@export var open_time := 0.55
@export var close_time := 0.5
@export var panel_width := 0.84
## Where the player steps to (local space) when standing in the swing.
@export var stand_closed := Vector3(-0.75, 0.0, 0.7)
@export var stand_open := Vector3(-0.55, 0.0, 1.05)
## Where the player stands to look through the peephole.
@export var stand_peek := Vector3(0.0, 0.0, 0.42)
@export var has_peephole := true
@export var start_open := false
@export var locked := false
@export var locked_text := "It's locked."
## Doors that show the same door in two places share state under this key.
@export var shared_key := ""

@export_group("Night")
@export var max_health := 100.0
## Damage multiplier while a chair is wedged under the handle.
@export var wedge_damage_scale := 0.6
@export var max_planks := 3
## Each nailed plank takes this much off every blow (they add up).
@export var plank_armor := 0.2
## Chance that a heavy blow tears a plank off.
@export var tear_chance := 0.25
@export var nail_time := 2.4
@export var pry_time := 1.6

const BODY_RADIUS := 0.32
const HANDLE_DOWN := -0.55
## Health fractions below which each crack shows.
const CRACK_AT := [0.75, 0.5, 0.25]
## How far a ruined door sags open in its frame (degrees).
const SAG_DEG := 4.0
## Seconds between hammer blows while nailing.
const HAMMER_EVERY := 0.45

var is_open := false
var is_broken := false
var health := 100.0
var planks := 0
## The chair wedged under the handle, if any.
var wedge: Carryable = null
## Closed resting angle; grows as the door is battered.
var _rest := 0.0
var _tween: Tween
var _collision_pending := false
var _hammer_timer := 0.0

@onready var _pivot: Node3D = $DoorPivot
@onready var _handle: Node3D = $DoorPivot/Handle
@onready var _panel_shape: CollisionShape3D = $DoorPivot/DoorBody/CollisionShape3D
@onready var _doorway: Area3D = $DoorwayArea
@onready var _lens: Node3D = $DoorPivot/PeepholeLens
@onready var _wedge_point: Node3D = $WedgePoint
@onready var _dust: GPUParticles3D = $Dust
@onready var _cracks: Array[Node3D] = [$DoorPivot/Crack1, $DoorPivot/Crack2, $DoorPivot/Crack3]
@onready var _planks: Array[Node3D] = [$Planks/Plank1, $Planks/Plank2, $Planks/Plank3]


func _ready() -> void:
	super()
	health = max_health
	if start_open:
		is_open = true
	if shared_key != "" and GameState.shared.has(shared_key):
		set_state(GameState.shared[shared_key])
	elif shared_key == "":
		add_to_group(&"persistent")
	_apply_pose()


func can_interact() -> bool:
	return not is_broken


func get_prompt() -> String:
	if locked:
		return "Try Door"
	if wedge:
		return "Remove Chair"
	if planks > 0:
		return "Pry Off Plank"
	return "Close Door" if is_open else "Open Door"


func get_hold_time() -> float:
	return pry_time if planks > 0 and not wedge and not locked else 0.0


func get_secondary_prompt() -> String:
	return "Look Through Peephole" if has_peephole and not is_open and not is_broken else ""


func get_secondary_stand_position(_player_position: Vector3) -> Variant:
	return to_global(stand_peek)


func secondary_interact(player: Node3D) -> void:
	var view := get_tree().get_first_node_in_group(&"peephole_view") as PeepholeView
	if view == null:
		return
	view.open(_lens.global_transform, self)
	var eye := _lens.global_position + global_basis.z * 0.1
	(player as PlayerController).begin_focus(eye, view.close)


func get_item_prompt() -> String:
	if is_open or is_broken or locked or planks >= max_planks or GameState.count(&"plank") == 0:
		return ""
	return "Nail Plank"


func get_item_hold_time() -> float:
	return nail_time


func get_block_reason(mode: StringName) -> String:
	if mode == &"item" or (mode == &"use" and planks > 0 and not wedge):
		if not GameState.has_tool(&"hammer"):
			return "I need a hammer for this."
	if mode == &"item" and not _has_work_light():
		return "Too dark to see the nails."
	return ""


func on_hold_tick(_player: Node3D, mode: StringName, delta: float) -> void:
	_hammer_timer -= delta
	if _hammer_timer > 0.0:
		return
	_hammer_timer = HAMMER_EVERY
	play_sound(&"SfxHammer" if mode == &"item" else &"SfxPry")
	GameState.noise(global_position, 0.3 if mode == &"item" else 0.15)


func accepts(item: Interactable) -> bool:
	var chair := item as Carryable
	return chair != null and chair.wedges_doors and not is_open and not is_broken \
			and not locked and wedge == null


func get_accept_prompt(item: Interactable) -> String:
	return "Wedge %s Under Handle" % item.interaction_name


func get_stand_position(player_position: Vector3) -> Variant:
	var local := to_local(player_position)
	if local.z < -0.25 or locked:
		return null  # on the far side: the door swings away from us
	var rel := Vector2(local.x - _pivot.position.x, local.z - _pivot.position.z)
	var in_swing := local.z > -0.05 and swing_contains(
			rel, PI, deg_to_rad(open_angle_deg), panel_width, BODY_RADIUS)
	var in_frame := local.z < 0.3 and absf(local.x) < 0.7
	if not (in_swing or in_frame):
		return null
	return to_global(stand_open if is_open else stand_closed)


func _on_interact(player: Node3D) -> String:
	if locked:
		play_sound(&"SfxKnock")
		_jolt(deg_to_rad(0.4), false)
		return locked_text
	if wedge:
		var chair := wedge
		wedge = null
		chair.docked = false
		(player as PlayerController).pick_up(chair)
		return "Chair removed"
	if planks > 0:
		_set_planks(planks - 1)
		GameState.give(&"plank", 1)
		return "Plank pried off"
	is_open = not is_open
	_save_shared()
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
		opened_by_player.emit()
	else:
		_tween.tween_property(_pivot, "rotation:y", _rest, close_time) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_tween.tween_callback(_on_shut)
		# A small rebound off the frame.
		_tween.tween_property(_pivot, "rotation:y", _rest + deg_to_rad(1.2), 0.06) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		_tween.tween_property(_pivot, "rotation:y", _rest, 0.1) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return "Door opened" if is_open else "Door closed"


func _on_use_item(_player: Node3D) -> String:
	if not GameState.take(&"plank"):
		return ""
	_set_planks(planks + 1)
	var plank := _planks[planks - 1]
	var rest := plank.position
	plank.position = rest + Vector3(0, 0, 0.08)
	create_tween().tween_property(plank, "position", rest, 0.12)
	return "Plank nailed (%d/%d)" % [planks, max_planks]


func _on_receive(item: Interactable, _player: Node3D) -> String:
	wedge = item as Carryable
	wedge.docked = true
	wedge.place_at(_wedge_point.global_transform, _wedge_point)
	play_sound(&"SfxWedge")
	return "Chair wedged under the handle"


## True if the door is held shut by a chair or planks.
func is_barricaded() -> bool:
	return wedge != null or planks > 0


## A blow from the other side. `heavy` picks the bang sound over a knock and
## may tear a plank off.
func take_hit(damage: float, heavy: bool) -> void:
	if is_broken:
		return
	var factor := (wedge_damage_scale if wedge else 1.0) * maxf(0.0, 1.0 - plank_armor * planks)
	var dealt := damage * factor
	health = maxf(0.0, health - dealt)
	hit.emit(dealt)
	play_sound(&"SfxBang" if heavy else &"SfxKnock")
	var jolt := (0.6 + damage * 1.2) * (0.4 if is_barricaded() else 1.0)
	_jolt(deg_to_rad(jolt), heavy)
	if heavy:
		_dust.restart()
		get_tree().call_group(&"camera_shake", &"shake", 0.15 + damage * 0.06)
		if planks > 0 and GameState.rng.randf() < tear_chance:
			_tear_plank()
	for i in _cracks.size():
		_cracks[i].visible = health / max_health < CRACK_AT[i]
	_rest = deg_to_rad(SAG_DEG) * (1.0 - health / max_health) * (0.4 if is_barricaded() else 1.0)
	_save_shared()
	if health <= 0.0:
		break_open()


## A light knock that does no damage.
func knock() -> void:
	if is_broken:
		return
	play_sound(&"SfxKnock")
	_jolt(deg_to_rad(0.3), false)


func break_open() -> void:
	if is_broken:
		return
	is_broken = true
	is_open = true
	_collision_pending = false
	_panel_shape.set_deferred(&"disabled", true)
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_pivot, "rotation:y", deg_to_rad(86.0), 0.22) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	play_sound(&"SfxBreak")
	_dust.restart()
	get_tree().call_group(&"camera_shake", &"shake", 0.9)
	if wedge:
		_knock_over(wedge)
		wedge = null
	while planks > 0:
		_tear_plank()
	_save_shared()
	broken.emit()


func get_state() -> Dictionary:
	return {"is_open": is_open, "health": health, "planks": planks, "broken": is_broken}


func set_state(state: Dictionary) -> void:
	is_open = state.get("is_open", is_open)
	health = state.get("health", health)
	is_broken = state.get("broken", false)
	_set_planks(state.get("planks", 0))
	_apply_pose()


func _physics_process(delta: float) -> void:
	if _collision_pending and not _doorway.has_overlapping_bodies():
		_collision_pending = false
		_panel_shape.disabled = false
	if _hammer_timer > 0.0:
		_hammer_timer -= delta


func _apply_pose() -> void:
	_rest = deg_to_rad(SAG_DEG) * (1.0 - health / max_health)
	_pivot.rotation.y = deg_to_rad(open_angle_deg if is_open else 0.0) + (0.0 if is_open else _rest)
	_panel_shape.disabled = is_open
	for i in _cracks.size():
		_cracks[i].visible = health / max_health < CRACK_AT[i]


func _set_planks(count: int) -> void:
	planks = clampi(count, 0, max_planks)
	for i in _planks.size():
		_planks[i].visible = i < planks
	_save_shared()


func _tear_plank() -> void:
	var plank := _planks[planks - 1]
	_set_planks(planks - 1)
	plank_torn.emit()
	play_sound(&"SfxTear")
	# Show a copy falling away; the real one is already hidden.
	var falling := plank.duplicate() as Node3D
	plank.get_parent().add_child(falling)
	falling.visible = true
	var landed := Vector3(falling.position.x, 0.03, falling.position.z + 0.35)
	var drop := falling.create_tween().set_parallel()
	drop.tween_property(falling, "position", landed, 0.4) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	drop.tween_property(falling, "rotation:z", falling.rotation.z + 0.4, 0.4)
	drop.chain().tween_interval(2.5)
	drop.chain().tween_callback(falling.queue_free)


func _has_work_light() -> bool:
	if GameState.flashlight_on:
		return true
	var hour := fmod(GameState.hour, 24.0)
	if hour > 6.5 and hour < 19.5:
		return true
	for lamp in get_tree().get_nodes_in_group(&"room_lights"):
		if (lamp as CeilingLamp).is_on:
			return true
	return false


func _save_shared() -> void:
	if shared_key != "":
		GameState.shared[shared_key] = get_state()


func _on_shut() -> void:
	play_sound(&"SfxClose")
	_collision_pending = true
	var latch := create_tween()
	latch.tween_property(_handle, "rotation:z", HANDLE_DOWN * 0.3, 0.05)
	latch.tween_property(_handle, "rotation:z", 0.0, 0.1)


func _jolt(angle: float, heavy: bool) -> void:
	if is_open or (_tween and _tween.is_running()):
		return
	var t := create_tween()
	t.tween_property(_pivot, "rotation:y", _rest + angle, 0.05) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(_pivot, "rotation:y", _rest, 0.2) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.parallel().tween_property(_handle, "rotation:z", HANDLE_DOWN * (0.5 if heavy else 0.15), 0.04)
	t.tween_property(_handle, "rotation:z", 0.0, 0.12)


func _knock_over(chair: Carryable) -> void:
	chair.release_in_place()
	var fall := chair.create_tween().set_parallel()
	fall.tween_property(chair, "global_position", chair.global_position + global_basis.z * 0.5, 0.35)
	fall.tween_property(chair, "rotation:x", deg_to_rad(-85.0), 0.35) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
