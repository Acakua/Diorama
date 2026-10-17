extends NightDirector
## Night 1, "A knock at the door". Beat sheet and balance notes:
## docs/night_01.md.

## Marker3D children, walked in order: outside, up to the window...
@export var outside_path: Node3D
## ...and on past it.
@export var outside_away: Node3D
## What it stares at while it stands at the window.
@export var window_point: Node3D
## From the far end of the corridor to the spot in front of the door.
@export var corridor_in: Node3D
## From the door back out of sight.
@export var corridor_out: Node3D
## Through the doorway into the room.
@export var break_in_path: Node3D
@export var peephole: PeepholeView
@export var birds: AudioStreamPlayer3D

var _thought_first_bang := false
var _thought_peek := false


func _setup() -> void:
	zombie.set_routes(_points(corridor_out), _points(break_in_path))
	radio.set_on(true)
	door.hit.connect(_on_door_hit)
	peephole.opened.connect(_on_peek)

	at(0.5, func() -> void: overlay.show_objective("Survive until 6:00"))
	at(12.0, func() -> void: radio.play_bulletin([
		"...this is an emergency broadcast.",
		"Residents are advised to stay indoors and lock all doors.",
		"Keep your lights low. Do not open your door to anyone.",
	]))
	at(60.0, func() -> void:
		zombie.walk(_points(outside_path), &"stop", window_point.global_position))
	at(67.0, func() -> void: overlay.show_thought("There's someone at the window..."))
	at(71.0, func() -> void: zombie.walk(_points(outside_away), &"gone"))
	at(95.0, _come_to_door)
	at(150.0, func() -> void: radio.play_bulletin([
		"...reports say the infected are drawn to light and sound.",
		"If something is at your door: stay quiet, stay dark, and barricade it.",
	]))
	at(165.0, func() -> void:
		if zombie.aggression <= 0.0:
			zombie.leave())
	at(200.0, _come_to_door)
	at(270.0, _climax)
	at(320.0, func() -> void:
		zombie.aggression = 0.0
		zombie.attention = 0.0
		zombie.leave())
	at(330.0, func() -> void: radio.play_bulletin([
		"...the sun is coming up. Authorities say the infected slow down in daylight.",
		"Stay where you are. Help is being organised.",
	]))
	at(346.0, func() -> void: birds.play())


func _come_to_door() -> void:
	if zombie.state == Zombie.State.OFFSTAGE:
		zombie.walk(_points(corridor_in), &"door")


## It knows someone is in there: it bangs no matter how quiet the room is.
func _climax() -> void:
	zombie.aggression = 1.0
	zombie.bang_damage = 2.2
	_come_to_door()


func _on_door_hit(damage: float) -> void:
	if not _thought_first_bang and damage >= 1.0:
		_thought_first_bang = true
		overlay.show_thought("It's trying to get in. I need to block that door.")


func _on_peek() -> void:
	if not _thought_peek and zombie.is_at_door():
		_thought_peek = true
		overlay.show_thought("That's Mr. Hale from 4B... What happened to his face?", 5.0)


func _points(markers: Node3D) -> Array[Vector3]:
	var points: Array[Vector3] = []
	for marker in markers.get_children():
		points.append((marker as Node3D).global_position)
	return points
