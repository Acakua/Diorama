extends NightDirector
## Night 1 (v2). [content — spoilers: see content/bible.md]

@export var corridor_in: Node3D
@export var corridor_out: Node3D
@export var break_in_path: Node3D
@export var peephole: PeepholeView
@export var birds: AudioStreamPlayer3D

## Earliest clock hour of each visit before the assault (jittered per run).
const VISITS := [21.0, 22.7, 24.5]
## He sets off up the corridor a little before this so the blows start on time.
const ASSAULT := 26.5
const ASSAULT_END := 29.0
## Longest a visit lasts (s) unless he is worked up.
const VISIT_CAP := 70.0

var _next_visit := 0
var _visit_due := INF
var _visit_started := 0.0
var _assault := false
var _said := {}


func _setup(late: bool) -> void:
	zombie.set_routes(_points(corridor_out), _points(break_in_path))
	zombie.knock_damage = 0.6
	zombie.bang_damage = 1.5
	zombie.give_up_time = 15.0
	door.tear_chance = 0.2
	zombie.left.connect(_on_left)
	door.hit.connect(_on_door_hit)
	door.plank_torn.connect(func() -> void: _say("tear", "It tore a board off!"))
	peephole.opened.connect(_on_peek)
	if late:
		zombie.attention = 0.6
		_visit_due = 5.0
		_next_visit = 1
	else:
		_schedule_visit()
	at_hour(20.5, func() -> void: radio.play_bulletin([
		"...this is an emergency broadcast.",
		"Residents are advised to stay indoors and lock all doors.",
		"Keep your lights low. Do not open your door to anyone.",
	]))
	at_hour(25.0, func() -> void: radio.play_bulletin([
		"...reports say the infected are drawn to light and sound.",
		"If something is at your door: stay quiet, stay dark, and board it up.",
	]))
	at_hour(ASSAULT - 0.4, _begin_assault)
	at_hour(ASSAULT_END, _end_assault)
	at_hour(29.17, func() -> void: radio.play_bulletin([
		"...the sun is coming up. The infected seem to slow down in daylight.",
		"An evacuation is being organised for the coming days. Stay on this frequency.",
	]))
	at_hour(29.3, func() -> void: birds.play())


func _process(delta: float) -> void:
	super(delta)
	if is_over or not is_running or _assault:
		return
	if zombie.state == Zombie.State.OFFSTAGE and time >= _visit_due:
		_start_visit()
	elif zombie.is_at_door() and time - _visit_started > VISIT_CAP and zombie.attention < 0.7:
		zombie.leave()


func _on_noise(_position: Vector3, loudness: float) -> void:
	# Noise while he is away brings him back sooner (or at all).
	if _assault or GameState.hour >= ASSAULT_END or loudness < 0.25:
		return
	if zombie.state == Zombie.State.OFFSTAGE:
		_visit_due = minf(_visit_due, time + GameState.rng.randf_range(6.0, 12.0))


func _start_visit() -> void:
	_visit_due = INF
	_visit_started = time
	zombie.attention *= 0.5
	zombie.walk(_points(corridor_in), &"door")


func _schedule_visit() -> void:
	if _next_visit >= VISITS.size():
		_visit_due = INF
		return
	var hour: float = VISITS[_next_visit] + GameState.rng.randf_range(-0.3, 0.3)
	_visit_due = maxf(time + 8.0, (hour - start_hour) * hour_seconds)
	_next_visit += 1


func _on_left() -> void:
	if _assault:
		zombie.walk(_points(corridor_in), &"door")
	elif GameState.hour < ASSAULT_END:
		_schedule_visit()


func _begin_assault() -> void:
	_assault = true
	zombie.aggression = 1.0
	zombie.bang_damage = 3.8
	if zombie.state == Zombie.State.OFFSTAGE:
		zombie.walk(_points(corridor_in), &"door")


func _end_assault() -> void:
	_assault = false
	_visit_due = INF
	_next_visit = VISITS.size()
	zombie.aggression = 0.0
	zombie.attention = 0.0
	zombie.leave()


func _on_door_hit(damage: float) -> void:
	if damage >= 0.5:
		_say("bang", "It's trying to get in. I need to board up that door.")


func _on_peek() -> void:
	if zombie.is_at_door():
		_say("peek", "That's Mr. Hale from 4B... What happened to his face?", 5.0)


func _say(key: String, text: String, seconds := 4.5) -> void:
	if not _said.has(key):
		_said[key] = true
		overlay.show_thought(text, seconds)


func _points(markers: Node3D) -> Array[Vector3]:
	var points: Array[Vector3] = []
	for marker in markers.get_children():
		points.append((marker as Node3D).global_position)
	return points
