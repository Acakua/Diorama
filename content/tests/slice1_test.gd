extends Node
## Slice 1 end to end. [content — spoilers]
##   full     - a whole day of scavenging through real scene changes, then an
##              active night (dark, quiet, re-nailing in the lulls): must survive
##   careless - light and radio on, nothing done: must lose before dawn
##   stranded - still in the corridor at dusk: must lose
##   passive  - chair + 3 planks, dark and quiet, no repairs: reported
##   chair    - chair only, dark and quiet: reported
##     godot --headless --path . res://content/tests/slice1_test.tscn
## Windowed it also saves screenshots to tests/screens/. Exit code = failures.

const HOME := "res://scenes/room/room_01.tscn"
const CORRIDOR := "res://content/places/corridor_4.tscn"
const FLAT := "res://content/places/flat_4b.tscn"
const SPEED := 4.0

var _checks := 0
var _failures := 0
var _shots := false
var _shot_dir := ""
var _report: PackedStringArray = []


func _ready() -> void:
	_shots = DisplayServer.get_name() != "headless"
	_shot_dir = ProjectSettings.globalize_path("res://tests/screens")
	if _shots:
		DirAccess.make_dir_recursive_absolute(_shot_dir)
	_run.call_deferred()


func _run() -> void:
	# Live beside the current scene so scene changes don't free this test.
	reparent(get_tree().root)
	var placeholder := Node.new()
	get_tree().root.add_child(placeholder)
	get_tree().current_scene = placeholder
	Journal.use_memory_only()
	Engine.time_scale = SPEED
	await _full_run()
	await _careless()
	await _stranded()
	await _passive(true)
	await _passive(false)
	Engine.time_scale = 1.0
	# Free the last place and let the audio server drop its playbacks.
	get_tree().current_scene.queue_free()
	await get_tree().create_timer(0.5).timeout
	print("\n" + "\n".join(_report))
	print("\n%d/%d checks passed" % [_checks - _failures, _checks])
	get_tree().quit(_failures)


# ------------------------------------------------------------------ scenarios

func _full_run() -> void:
	print("\n-- full day and an active night")
	await _load(HOME, 101)
	var home := _place()
	var player := _player()
	_check(GameState.phase == &"day" and GameState.hour < 16.1, "a run starts at 16:00, daytime")
	await _shot("s1_home_day")

	# Flashlight from the home cabinet.
	var cabinet: InteractiveCabinet = home.get_node("Cabinet")
	await _act(Vector3(3.05, 0, -1.75), cabinet, &"use")
	await _act(Vector3(3.05, 0, -1.75), cabinet, &"use")
	_check(GameState.has_tool(&"flashlight") and GameState.stash.count(&"battery") == 1,
			"home cabinet: flashlight and a spare battery")

	# Out the door into the corridor.
	var door: InteractiveDoor = home.get_node("Door")
	await _act(Vector3(-3.2, 0, -2.05), door, &"use")
	_check(door.is_open, "home door opens")
	await _travel_by_walking(Vector3(-4.85, 0, -2.43), CORRIDOR)
	_check(_place().scene_file_path == CORRIDOR, "walking through the door leads to the corridor")
	var cor := _place()
	_check(_player().global_position.distance_to(cor.get_node("From4A").global_position) < 0.3,
			"arrive in front of 4A")
	_check((cor.get_node("Door4A") as InteractiveDoor).is_open, "4A is open from the corridor side too")
	await _shot("s2_corridor")
	var locked: InteractiveDoor = cor.get_node("Door4C")
	await _act(Vector3(-0.2, 0, -0.4), locked, &"use")
	_check(not locked.is_open, "4C stays locked")
	await _act(Vector3(-4.4, 0, 0.5), cor.get_node("Props/RenovationPile"), &"use")
	_check(GameState.bag.count(&"plank") == 2, "renovation pile: 2 planks in the bag")

	# Into 4B.
	await _travel_by_walking(Vector3(-2.4, 0, -1.8), FLAT)
	var flat := _place()
	_check(flat.scene_file_path == FLAT, "4B is open and leads inside")
	await _shot("s3_flat_4b")
	for spec in [["Kitchen/UnderSink", Vector3(-1.55, 0, -1.35)], ["Kitchen/Drawer", Vector3(-0.45, 0, -1.35)],
			["Kitchen/Fridge", Vector3(0.35, 0, -1.25)], ["Closet", Vector3(-1.9, 0, -0.2)],
			["Nightstand", Vector3(1.5, 0, -1.55)], ["DeskDrawer", Vector3(1.9, 0, 1.0)]]:
		await _act(spec[1], flat.get_node(spec[0]), &"use")
	var wardrobe: InteractiveCabinet = flat.get_node("Wardrobe")
	await _act(Vector3(-2.0, 0, 1.4), wardrobe, &"use")
	if not wardrobe.contents.is_empty():
		await _act(Vector3(-2.0, 0, 1.4), wardrobe, &"use")
	_check(GameState.has_tool(&"hammer"), "4B: found the hammer")
	_check(GameState.bag.stacks.size() == GameState.bag.slots, "the bag fills up (3 slots)")
	_report.append("after 4B: bag %s, hour %s" % [_bag_text(), GameState.clock_text()])
	await _act(Vector3(-1.2, 0, 0.15), flat.get_node("Notes/TableNote"), &"use")
	_check(_player().state == PlayerController.State.FOCUS, "reading a note holds the player")
	await _shot("s4_note")
	_player().end_focus()

	# Home again (two trips' worth is more than one bag; leave the rest).
	await _travel_by_walking(Vector3(-3.85, 0, -1.4), CORRIDOR)
	await _travel_by_walking(Vector3(-4.6, 0, -1.8), HOME)
	home = _place()
	_check(GameState.bag.is_empty() and GameState.stash.count(&"plank") >= 2, "arriving home unpacks the bag")
	door = home.get_node("Door")
	await _act(Vector3(-3.2, 0, -2.05), door, &"use")
	_check(not door.is_open, "door closed again")
	for i in 3:
		if GameState.count(&"plank") > 0:
			await _act(Vector3(-3.3, 0, -2.4), door, &"item")
	_check(door.planks == 3, "three planks nailed across the door")
	await _shot("s5_planks")
	var chair: Carryable = home.get_node("Furniture/Chair")
	await _act(Vector3(0.75, 0, -1.65), chair, &"use")
	_check(_player().carried == chair, "picked up the chair")
	await _act(Vector3(-3.1, 0, -2.3), door, &"give")
	_check(door.wedge == chair, "chair wedged under the handle")
	_report.append("ready for night at %s: planks on door %d, spare planks %d, batteries %d" % [
		GameState.clock_text(), door.planks, GameState.count(&"plank"), GameState.count(&"battery")])

	# Wait for dusk, then play the night carefully.
	await _wait_until(func() -> bool: return GameState.phase != &"day", 400.0)
	_check(GameState.phase == &"night", "dusk at home starts the night")
	var night: NightDirector = home.get_node("NightDirector")
	await _night_bot(home, true)
	_check(night.is_over and night.survived, "active night is survived (door %.0f/100)" % door.health)
	_report.append("full run: survived=%s door=%.0f planks=%d spare=%d" % [
		night.survived, door.health, door.planks, GameState.count(&"plank")])
	await _wait_until(func() -> bool: return _place().overlay.is_end_shown(), 10.0)
	await _shot("s7_dawn_end")


func _careless() -> void:
	print("\n-- careless night")
	await _load(HOME, 202)
	var home := _place()
	(home.get_node("Radio") as Interactable).interact(_player())
	GameState.hour = 19.98
	await _wait_until(func() -> bool: return (home.get_node("NightDirector") as NightDirector).is_over, 600.0)
	var night: NightDirector = home.get_node("NightDirector")
	_check(night.is_over and not night.survived, "careless night is lost (at %s)" % GameState.clock_text())
	_report.append("careless: lost at %s" % GameState.clock_text())


func _stranded() -> void:
	print("\n-- stranded in the corridor")
	await _load(HOME, 303)
	var door: InteractiveDoor = _place().get_node("Door")
	await _act(Vector3(-3.2, 0, -2.05), door, &"use")
	await _travel_by_walking(Vector3(-4.85, 0, -2.43), CORRIDOR)
	GameState.hour = 19.98
	await _wait_until(func() -> bool: return GameState.phase == &"stranded", 10.0)
	_check(GameState.phase == &"stranded", "dusk away from home: stranded")
	await _wait_until(func() -> bool: return GameState.phase == &"over", 60.0)
	_check(GameState.phase == &"over" and _place().overlay.is_end_shown(), "caught in the corridor after dark")
	await _shot("s8_stranded")


func _passive(with_planks: bool) -> void:
	var label := "passive (chair + 3 planks)" if with_planks else "chair only"
	print("\n-- " + label)
	await _load(HOME, 404 if with_planks else 505)
	var home := _place()
	var player := _player()
	var door: InteractiveDoor = home.get_node("Door")
	if with_planks:
		GameState.give(&"hammer", 1)
		GameState.give(&"plank", 3)
		for i in 3:
			door.use_item(player)
	door.receive(home.get_node("Furniture/Chair"), player)
	(home.get_node("LightSwitch") as Interactable).interact(player)
	GameState.hour = 19.98
	var night: NightDirector = home.get_node("NightDirector")
	await _wait_until(func() -> bool: return night.is_over, 600.0)
	_report.append("%s: survived=%s door=%.0f at %s" % [label, night.survived, door.health, GameState.clock_text()])
	print("      ", _report[_report.size() - 1])


## Plays the night: dark and quiet, re-nails whenever there is a spare plank
## and he isn't at the door (or the assault is on and it's too late to hide).
func _night_bot(home: Node, renail: bool) -> void:
	var night: NightDirector = home.get_node("NightDirector")
	var door: InteractiveDoor = home.get_node("Door")
	var zombie: Zombie = home.get_node("Zombie")
	var player := _player()
	var lamp: CeilingLamp = home.get_node("CeilingLamp")
	if lamp.is_on:
		(home.get_node("LightSwitch") as Interactable).interact(player)
	var radio: InteractiveRadio = home.get_node("Radio")
	if radio.is_on:
		radio.interact(player)
	player.global_position = Vector3(-2.6, 0, -1.2)
	var shot_flash := false
	while not night.is_over:
		await get_tree().physics_frame
		var assault := zombie.aggression > 0.0
		var can_work := renail and door.planks < door.max_planks and GameState.count(&"plank") > 0 \
				and not player.is_busy() and (assault or zombie.state == Zombie.State.OFFSTAGE)
		if can_work:
			GameState.set_flashlight(true)
			await _act(Vector3(-3.3, 0, -2.4), door, &"item")
			if not shot_flash:
				shot_flash = true
				await _shot("s6_night_flashlight")
			GameState.set_flashlight(false)
			player.global_position = Vector3(-2.6, 0, -1.2)


# ------------------------------------------------------------------ helpers

func _load(scene: String, seed: int) -> void:
	GameState.new_run(seed)
	var before := GameState.current_place.get_instance_id() if GameState.current_place else 0
	get_tree().change_scene_to_file(scene)
	await _wait_until(func() -> bool: return is_instance_valid(GameState.current_place) \
			and GameState.current_place.get_instance_id() != before \
			and GameState.current_place.is_node_ready(), 10.0)
	_prepare_player()


func _place() -> Place:
	return GameState.current_place as Place


func _player() -> PlayerController:
	return _place().player


func _prepare_player() -> void:
	var player := _player()
	player.scripted = true
	player.set_process_unhandled_input(false)
	await get_tree().physics_frame


## Puts the player at `stand` facing `target`, then runs one action on it.
func _act(stand: Vector3, target: Interactable, mode: StringName) -> void:
	var player := _player()
	player.global_position = stand
	var to := target.get_interaction_position() - stand
	player.facing_yaw = atan2(to.x, to.z)
	for i in 4:
		await get_tree().physics_frame
	if player.detector.current != target and mode != &"give":
		_check(false, "%s is the target at %s (got %s)" % [target.interaction_name, stand,
				player.detector.current.interaction_name if player.detector.current else "nothing"])
		return
	player.scripted_hold = true
	match mode:
		&"use", &"give":
			player.try_interact()
		&"item":
			player.try_use_item()
	await _wait_until(func() -> bool: return not player.is_busy() \
			or player.state == PlayerController.State.FOCUS, 8.0)
	player.scripted_hold = false
	await get_tree().physics_frame


func _travel_by_walking(into: Vector3, expect: String) -> void:
	_player().global_position = into
	await _wait_until(func() -> bool: return is_instance_valid(GameState.current_place) \
			and GameState.current_place.scene_file_path == expect \
			and GameState.current_place.is_node_ready(), 10.0)
	await _prepare_player()
	await get_tree().create_timer(0.5).timeout


func _wait_until(condition: Callable, timeout: float) -> void:
	var start := Time.get_ticks_msec()
	while not condition.call():
		if (Time.get_ticks_msec() - start) / 1000.0 * SPEED > timeout:
			return
		await get_tree().process_frame


func _bag_text() -> String:
	var parts: PackedStringArray = []
	for s in GameState.bag.stacks:
		parts.append("%s x%d" % [s["id"], s["count"]])
	return ", ".join(parts)


func _shot(name: String) -> void:
	if not _shots:
		return
	await RenderingServer.frame_post_draw
	var path := _shot_dir.path_join(name + ".png")
	get_viewport().get_texture().get_image().save_png(path)
	print("      screenshot ", path)


func _check(ok: bool, what: String) -> void:
	_checks += 1
	if not ok:
		_failures += 1
	print(("PASS  " if ok else "FAIL  ") + what)
