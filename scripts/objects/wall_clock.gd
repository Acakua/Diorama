class_name WallClock
extends Node3D
## Wall clock whose hands follow the game clock, so the time of day is in the
## room as well as in the corner of the screen.

@onready var _hour: Node3D = $HourHand
@onready var _minute: Node3D = $MinuteHand


func _process(_delta: float) -> void:
	set_time(GameState.hour)


## `hours` may run past 24 (e.g. 29.5 = 05:30 next morning).
func set_time(hours: float) -> void:
	# Hands turn clockwise seen from the front (+Z), i.e. negative about Z.
	_hour.rotation.z = -fmod(hours, 12.0) / 12.0 * TAU
	_minute.rotation.z = -fmod(hours, 1.0) * TAU
