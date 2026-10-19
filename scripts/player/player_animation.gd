class_name PlayerAnimation
extends Node3D
## Procedural idle / walk / reach for the low-poly body. There is no skeleton:
## every joint is a Node3D pivot and this script sets their rotations each
## frame from the speed and reach values PlayerController hands it.
##
## The model faces +Z and +X is the character's left. A positive X rotation
## swings a hanging limb backward and tips an upright part forward.

## A foot touched down (twice per stride, while walking).
signal stepped

@export var stride_length := 1.25
@export var leg_swing_deg := 22.0
@export var knee_bend_deg := 34.0
@export var arm_swing_deg := 15.0
## Hip-to-sole distance, used to keep the planted foot on the floor.
@export var leg_length := 0.9
@export var breath_period := 3.6

@export_group("Posture")
## Extra forward bend of the spine (rad); the zombie stoops.
@export var hunch := 0.0
## Sideways tilt of the head (rad).
@export var head_tilt := 0.0
## 0..1: drags the right leg.
@export var limp := 0.0

var speed := 0.0
var max_speed := 2.3
## 0..1, how far the arm is raised toward reach_target.
var reach_weight := 0.0
## 0..1 pulse right after contact: a push for &"press", a tug for &"pull".
var action_weight := 0.0
var reach_style: StringName = &"press"
var reach_target := Vector3.ZERO
## Reach with both arms (a two-handed shove).
var reach_both := false
## Arms forward holding something in front of the chest.
var carrying := false

var _phase := 0.0
var _walk := 0.0
var _time := 0.0
var _use_left := false
var _was_reaching := false
var _carry := 0.0

@onready var _hips: Node3D = $Hips
@onready var _spine: Node3D = $Hips/Spine
@onready var _neck: Node3D = $Hips/Spine/Neck
@onready var _shoulder_l: Node3D = $Hips/Spine/ShoulderL
@onready var _elbow_l: Node3D = $Hips/Spine/ShoulderL/ElbowL
@onready var _shoulder_r: Node3D = $Hips/Spine/ShoulderR
@onready var _elbow_r: Node3D = $Hips/Spine/ShoulderR/ElbowR
@onready var _hip_l: Node3D = $Hips/HipL
@onready var _knee_l: Node3D = $Hips/HipL/KneeL
@onready var _ankle_l: Node3D = $Hips/HipL/KneeL/AnkleL
@onready var _hip_r: Node3D = $Hips/HipR
@onready var _knee_r: Node3D = $Hips/HipR/KneeR
@onready var _ankle_r: Node3D = $Hips/HipR/KneeR/AnkleR
@onready var _hips_rest := _hips.position
@onready var _shoulder_rest_y := _shoulder_l.position.y


func _process(delta: float) -> void:
	_time += delta
	_walk = lerpf(_walk, clampf(speed / max_speed, 0.0, 1.0), 1.0 - exp(-9.0 * delta))
	var before := _phase
	_phase = fmod(_phase + delta * speed / stride_length * TAU, TAU)
	# A heel lands when the legs are spread widest (sin(phase) = +-1).
	if _walk > 0.1 and speed > 0.1 and fposmod(_phase - PI / 2.0, PI) < fposmod(before - PI / 2.0, PI):
		stepped.emit()
	var w := _walk
	var idle := 1.0 - w
	var s := sin(_phase)
	var c := cos(_phase)
	var breath := sin(_time * TAU / breath_period)
	_carry = move_toward(_carry, 1.0 if carrying else 0.0, delta * 5.0)

	# Legs swing opposite each other. The knee folds while a leg travels
	# forward (the foot lifts) and the ankle keeps the sole roughly flat.
	var leg := deg_to_rad(leg_swing_deg) * w
	var knee := deg_to_rad(knee_bend_deg) * w
	_hip_l.rotation.x = -s * leg
	_hip_r.rotation.x = s * leg
	_knee_l.rotation.x = maxf(0.0, c) * knee + 0.04
	_knee_r.rotation.x = maxf(0.0, -c) * knee * (1.0 - limp * 0.6) + 0.04 + limp * 0.12
	_ankle_l.rotation.x = -(_hip_l.rotation.x + _knee_l.rotation.x) * 0.6
	_ankle_r.rotation.x = -(_hip_r.rotation.x + _knee_r.rotation.x) * 0.6

	# The pelvis drops as the legs spread so the planted foot stays down; that
	# drop is the body bob. Hips and shoulders twist against each other.
	var drop := leg_length * (1.0 - cos(s * leg)) * 0.9
	_hips.position = _hips_rest + Vector3(0.0, -drop + idle * breath * 0.002, 0.0)
	_hips.rotation = Vector3(0.0, s * 0.07 * w, c * (0.02 + limp * 0.05) * w)
	_spine.rotation = Vector3(0.07 * w + idle * breath * 0.012 + hunch - _carry * 0.04,
			-s * 0.11 * w * (1.0 - _carry), -c * 0.015 * w)

	var reaching := reach_weight > 0.001
	if reaching and not _was_reaching:
		_use_left = to_local(reach_target).x > 0.0
	_was_reaching = reaching

	# Lean into a reach; a press pushes a little further, a pull tugs back.
	if reaching:
		var lean := reach_weight * 0.12
		lean += action_weight * (-0.1 if reach_style == &"pull" else 0.05)
		_spine.rotation.x += lean

	# Arms swing against the legs, hang slightly away from the body and rise
	# a touch with each breath.
	var arm := deg_to_rad(arm_swing_deg) * w
	var lift := idle * breath * 0.004
	_shoulder_l.position.y = _shoulder_rest_y + lift
	_shoulder_r.position.y = _shoulder_rest_y + lift
	_apply_arm(_shoulder_l, _elbow_l, Vector3(s * arm, 0.0, 0.07 + idle * breath * 0.01),
			-(0.16 + maxf(0.0, -s) * 0.35 * w), reaching and (_use_left or reach_both), 1.0)
	_apply_arm(_shoulder_r, _elbow_r, Vector3(-s * arm, 0.0, -0.07 - idle * breath * 0.01),
			-(0.16 + maxf(0.0, s) * 0.35 * w), reaching and (not _use_left or reach_both), -1.0)

	# Head: a slow idle glance around, steadied while walking, and a look at
	# whatever the hand is going for.
	var head := Vector3(-0.04 * w - idle * breath * 0.01 - hunch * 0.5,
			idle * sin(_time * 0.37) * 0.1, head_tilt)
	if reaching:
		var to := _spine.to_local(reach_target) - _neck.position - Vector3(0.0, 0.17, 0.0)
		var pitch := clampf(atan2(-to.y, Vector2(to.x, to.z).length()), -0.4, 0.6)
		head = head.lerp(Vector3(pitch, 0.0, 0.0), reach_weight)
	_neck.rotation = head


## `side` is +1 for the left arm, -1 for the right.
func _apply_arm(shoulder: Node3D, elbow: Node3D, swing: Vector3, bend: float,
		reach: bool, side: float) -> void:
	var q := Quaternion.from_euler(swing)
	if _carry > 0.001:
		# Both forearms forward and slightly inward, holding the item.
		q = q.slerp(Quaternion.from_euler(Vector3(-1.15, 0.0, -side * 0.12)), _carry)
		bend = lerpf(bend, -0.55, _carry)
	if reach:
		var parent := shoulder.get_parent() as Node3D
		var local := parent.global_transform.affine_inverse() * reach_target
		var dir := (local - shoulder.position).normalized()
		q = q.slerp(Quaternion(Vector3.DOWN, dir), reach_weight)
		var reach_bend := -0.1
		if reach_style == &"pull":
			reach_bend -= action_weight * 0.55
		else:
			reach_bend += action_weight * 0.1
		bend = lerpf(bend, reach_bend, reach_weight)
	shoulder.quaternion = q
	elbow.rotation = Vector3(bend, 0.0, 0.0)
