class_name Ambience
extends Node3D
## What can be heard from outside a window: one loop by day, another after
## dark, cross-fading at dusk and dawn with GameState.hour. Either loop may be
## left empty. Both keep playing; only their volume changes.

@export var day: AudioStream
@export var night: AudioStream
@export var volume_db := 0.0
@export var unit_size := 3.0

var _day: AudioStreamPlayer3D
var _night: AudioStreamPlayer3D


func _ready() -> void:
	_day = _make_player(day)
	_night = _make_player(night)
	_process(0.0)


func _process(_delta: float) -> void:
	var light := daylight(GameState.hour)
	_set_level(_day, light)
	_set_level(_night, 1.0 - light)


## 1 in daylight, 0 at night, easing through dusk (19:30-20:30) and dawn
## (05:00-06:00, i.e. hour 29-30).
static func daylight(hour: float) -> float:
	if hour < 24.0:
		return 1.0 - smoothstep(19.5, 20.5, hour)
	return smoothstep(29.0, 30.0, hour)


func _make_player(loop: AudioStream) -> AudioStreamPlayer3D:
	if loop == null:
		return null
	var player := AudioStreamPlayer3D.new()
	player.stream = loop
	player.unit_size = unit_size
	player.max_db = 6.0
	player.bus = &"World"
	add_child(player)
	player.play()
	return player


func _set_level(player: AudioStreamPlayer3D, amount: float) -> void:
	if player:
		player.volume_db = volume_db + linear_to_db(maxf(amount, 0.0001))
