class_name NightDirector
extends Node
## Runs a night at home. From the moment it begins (normally 20:00, later if
## the player got home late) to end_hour it advances the clock, fires the
## night script's timed beats, passes noises on to the script, plays a
## heartbeat that follows the danger at the door, and shows the win / lose
## screen. Each night extends this and lists its beats in _setup().

signal ended(survived: bool)

## Off in tests that only exercise the room.
@export var enabled := true
## 29.5 = 05:30 the next morning.
@export var end_hour := 29.5
## Real seconds per in-game hour at night.
@export var hour_seconds := 22.0

@export_group("Scene")
@export var player: PlayerController
@export var door: InteractiveDoor
@export var zombie: Zombie
@export var lamp: CeilingLamp
@export var radio: InteractiveRadio
@export var overlay: NightOverlay
@export var heartbeat: AudioStreamPlayer

## Seconds since the night began.
var time := 0.0
var is_running := false
var is_over := false
var survived := false
var start_hour := 20.0
var _beats: Array = []


func _ready() -> void:
	add_to_group(&"listeners")
	set_process(false)
	if radio:
		radio.subtitle.connect(overlay.show_subtitle)


## Starts the night. `late` is true when the player got home after dark.
func begin(late := false) -> void:
	if not enabled or is_running or is_over:
		return
	is_running = true
	start_hour = GameState.hour
	zombie.broke_in.connect(_lose)
	heartbeat.volume_db = -60.0
	heartbeat.play()
	_setup(late)
	_beats.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0])
	set_process(true)


## Override: call at() / at_hour() for each beat of the night.
func _setup(_late: bool) -> void:
	pass


## Override: a noise was made somewhere (see GameState.noise()).
func _on_noise(_position: Vector3, _loudness: float) -> void:
	pass


## Runs `action` once, `seconds` after the night began.
func at(seconds: float, action: Callable) -> void:
	_beats.append([seconds, action])


## Runs `action` once at clock time `hour` (past midnight add 24: 01:30 = 25.5).
## Times already past run straight away.
func at_hour(hour: float, action: Callable) -> void:
	at((hour - start_hour) * hour_seconds, action)


func hear(position: Vector3, loudness: float) -> void:
	if is_running and not is_over:
		_on_noise(position, loudness)


func _process(delta: float) -> void:
	if is_over:
		return
	time += delta
	GameState.hour = start_hour + time / hour_seconds
	while not _beats.is_empty() and _beats[0][0] <= time:
		var beat: Array = _beats.pop_front()
		(beat[1] as Callable).call()
		if is_over:
			return
	_update_heartbeat(delta)
	if GameState.hour >= end_hour:
		_win()


func _update_heartbeat(delta: float) -> void:
	var danger := zombie.danger()
	var target := -60.0 if danger < 0.05 else lerpf(-22.0, -4.0, danger)
	heartbeat.volume_db = move_toward(heartbeat.volume_db, target, delta * 20.0)
	heartbeat.pitch_scale = lerpf(0.9, 1.25, danger)


func _win() -> void:
	is_over = true
	survived = true
	GameState.set_phase(&"over")
	player.controls_enabled = false
	heartbeat.stop()
	var detail := "Dawn breaks at %s. The hallway is quiet." % GameState.clock_text()
	overlay.show_end(true, detail + "\n\nDay 2 — to be continued.\n\n[R] New run    [Esc] Quit")
	ended.emit(true)


func _lose() -> void:
	if is_over:
		return
	is_over = true
	survived = false
	GameState.set_phase(&"over")
	player.controls_enabled = false
	heartbeat.stop()
	await get_tree().create_timer(1.4).timeout
	var detail := "It got in at %s." % GameState.clock_text()
	overlay.show_end(false, detail + "\n\n[R] New run    [Esc] Quit")
	ended.emit(false)
