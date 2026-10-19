extends Node
## How the home room sounds, checked without ears:
##   the game listens from the player's head, turned like the camera
##   footsteps land while walking and stop when standing
##   something in the corridor is muffled by the closed door, clear once it opens
##   the room's echo changes when the place changes
##   the window's day loop fades into the night loop at dusk
##     godot --headless --path . res://tests/audio_test.tscn

const ROOM := preload("res://scenes/room/room_01.tscn")

var room: Place
var player: PlayerController
var _checks := 0
var _failures := 0


func _ready() -> void:
	Journal.use_memory_only()
	GameState.new_run(5)
	GameState.clock_running = false
	room = ROOM.instantiate()
	room.get_node("NightDirector").enabled = false
	add_child(room)
	player = room.player
	player.scripted = true
	player.set_process_unhandled_input(false)
	_run.call_deferred()


func _run() -> void:
	await _frames(10)

	var ear := get_viewport().get_audio_listener_3d()
	var camera := get_viewport().get_camera_3d()
	_check(ear is Ear and ear.global_position.distance_to(player.global_position + Vector3.UP * 1.6) < 0.05,
			"the listener is at the player's head")
	_check(absf(angle_difference(ear.global_rotation.y, camera.global_rotation.y)) < 0.01,
			"and faces the way the camera looks")

	var steps: Footsteps = player.get_node("Footsteps")
	var count := [0]
	player.animator.stepped.connect(func() -> void: count[0] += 1)
	player.scripted_direction = Vector3(1, 0, 0)
	await _frames(60)
	player.scripted_direction = Vector3.ZERO
	var walked: int = count[0]
	_check(walked >= 3 and steps.stream is AudioStreamRandomizer, "a second of walking: %d footsteps" % walked)
	await _frames(40)
	count[0] = 0
	await _frames(60)
	_check(count[0] == 0, "standing still: no footsteps")

	# Something groaning just outside the door.
	var zombie: Zombie = room.get_node("Zombie")
	var door: InteractiveDoor = room.get_node("Door")
	zombie.global_position = Vector3(-4.85, 0, -2.2)
	zombie.visible = true
	var voice: OccludedSound = zombie.get_node("Voice")
	voice.play()
	await _frames(5)
	_check(voice.bus == &"Muffled", "through the closed door it is muffled")
	door._on_interact(player)
	await _frames(90)
	_check(door.is_open and voice.bus == &"World", "with the door open it is clear")
	voice.stop()
	zombie.visible = false

	var reverb := AudioServer.get_bus_effect(AudioServer.get_bus_index(&"World"), 0) as AudioEffectReverb
	_check(is_equal_approx(reverb.room_size, room.reverb_size), "the room's echo is set (size %.2f)" % reverb.room_size)
	var corridor: Place = load("res://content/places/corridor_4.tscn").instantiate()
	corridor.reverb_size = 0.6
	corridor._apply_acoustics()
	_check(is_equal_approx(reverb.room_size, 0.6), "another place sets its own echo")
	corridor.free()
	room._apply_acoustics()

	var outside: Ambience = room.get_node("Outside")
	GameState.hour = 17.0
	for i in 3:
		await get_tree().process_frame
	var day_db: float = outside._day.volume_db
	var night_db: float = outside._night.volume_db
	GameState.hour = 22.0
	for i in 3:
		await get_tree().process_frame
	_check(day_db > night_db + 30.0 and outside._night.volume_db > outside._day.volume_db + 30.0,
			"the window sounds like day at 17:00 and like night at 22:00")

	room.queue_free()
	await get_tree().create_timer(0.3).timeout
	print("\n%d/%d checks passed" % [_checks - _failures, _checks])
	get_tree().quit(_failures)


func _frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


func _check(ok: bool, what: String) -> void:
	_checks += 1
	if not ok:
		_failures += 1
	print(("PASS  " if ok else "FAIL  ") + what)
