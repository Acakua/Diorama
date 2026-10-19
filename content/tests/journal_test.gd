extends Node
## The journal and its first shortcut. [content — spoilers]
##   places, notes and clues land in the journal as they are found
##   "Under the Ficus" stays hidden until the 4B calendar clue is known
##   the key from it unlocks 4C; the letter there adds the next clue
##   a new run keeps the journal, so the shortcut is there from the start
##   the journal is written to disk and read back; opening it pauses the game
##     godot --headless --path . res://content/tests/journal_test.tscn

const HOME := "res://scenes/room/room_01.tscn"
const CORRIDOR := "res://content/places/corridor_4.tscn"
const FLAT_B := "res://content/places/flat_4b.tscn"
const FLAT_C := "res://content/places/flat_4c.tscn"
const TEST_SAVE := "user://journal_test.json"

var _checks := 0
var _failures := 0


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	reparent(get_tree().root)
	var placeholder := Node.new()
	get_tree().root.add_child(placeholder)
	get_tree().current_scene = placeholder
	Journal.use_memory_only()

	await _load(HOME, 11)
	_check(Journal.knows(&"place_home"), "home goes in the journal")
	await _act(Vector3(-3.2, 0, -2.05), _place().get_node("Door"), &"use")
	await _travel(Vector3(-4.85, 0, -2.43), CORRIDOR)
	var ficus: Interactable = _place().get_node("Props/UnderFicus")
	_check(not ficus.is_available() and _player().get_actions(ficus).is_empty(),
			"before the clue, there is nothing to do at the ficus")

	await _travel(Vector3(-2.4, 0, -1.8), FLAT_B)
	await _act(Vector3(-1.05, 0, -1.7), _place().get_node("Notes/Calendar"), &"use")
	_player().end_focus()
	_check(Journal.knows(&"note_hale_calendar") and Journal.knows(&"clue_okafor_key"),
			"reading the calendar adds the note and the clue")

	await _travel(Vector3(-3.85, 0, -1.4), CORRIDOR)
	ficus = _place().get_node("Props/UnderFicus")
	_check(ficus.is_available(), "with the clue, the ficus can be searched")
	await _act(Vector3(-3.75, 0, 0.35), ficus, &"use")
	_check(GameState.has_tool(&"key_4c"), "found the spare key")
	var door_c: InteractiveDoor = _place().get_node("Door4C")
	_check(door_c.get_prompt() == "Unlock Door", "4C offers to be unlocked")
	await _act(Vector3(-0.2, 0, -0.4), door_c, &"use")
	await _act(Vector3(-0.2, 0, -0.4), door_c, &"use")
	_check(not door_c.locked and door_c.is_open, "4C unlocked and opened")
	await _travel(Vector3(-0.2, 0, -1.8), FLAT_C)
	_check(_place().scene_file_path == FLAT_C and Journal.knows(&"place_4c"), "inside 4C")
	await _act(Vector3(-0.5, 0, 0.15), _place().get_node("Letter"), &"use")
	_player().end_focus()
	_check(Journal.knows(&"clue_roof_keys"), "the letter adds the next clue")
	await _act(Vector3(-1.1, 0, -1.15), _place().get_node("Dresser"), &"use")
	_check(GameState.count(&"battery") >= 2, "the dresser has batteries")
	var sewing: Searchable = _place().get_node("SewingTable")
	await _act(Vector3(1.75, 0, -0.95), sewing, &"use")
	_check(sewing.searched, "the sewing table under the window can be searched")

	# A new run forgets the world but not the journal.
	await _load(HOME, 12)
	_check(not GameState.has_tool(&"key_4c") and Journal.knows(&"clue_okafor_key"),
			"a new run: no key, but the clue is still known")
	await _act(Vector3(-3.2, 0, -2.05), _place().get_node("Door"), &"use")
	await _travel(Vector3(-4.85, 0, -2.43), CORRIDOR)
	_check((_place().get_node("Props/UnderFicus") as Interactable).is_available(),
			"the shortcut is there from the start of the new run")

	# The journal screen pauses the game.
	(_place().get_node("Hud/Journal") as Button).pressed.emit()
	await get_tree().process_frame
	var view := get_tree().get_first_node_in_group(&"journal_view") as JournalView
	_check(view.is_open and get_tree().paused, "the Journal button opens it and pauses the game")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var dir := ProjectSettings.globalize_path("res://tests/screens")
		DirAccess.make_dir_recursive_absolute(dir)
		get_viewport().get_texture().get_image().save_png(dir.path_join("j1_journal.png"))
	view.close()
	_check(not get_tree().paused, "closing it resumes")

	# Saved to disk and read back.
	Journal.persistent = true
	Journal.save_path = TEST_SAVE
	Journal.learn(&"test_entry", &"notes", "Test", "Written by the journal test.")
	Journal.use_memory_only()
	Journal.persistent = true
	Journal.save_path = TEST_SAVE
	Journal.reload()
	_check(Journal.knows(&"test_entry") and Journal.knows(&"clue_roof_keys"), "the journal is saved and loads back")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	Journal.use_memory_only()

	get_tree().current_scene.queue_free()
	await get_tree().create_timer(0.3).timeout
	print("\n%d/%d checks passed" % [_checks - _failures, _checks])
	get_tree().quit(_failures)


func _load(scene: String, seed: int) -> void:
	GameState.new_run(seed)
	var before := GameState.current_place.get_instance_id() if GameState.current_place else 0
	get_tree().change_scene_to_file(scene)
	await _until(func() -> bool: return is_instance_valid(GameState.current_place) \
			and GameState.current_place.get_instance_id() != before \
			and GameState.current_place.is_node_ready(), 10.0)
	await _prepare()


func _travel(into: Vector3, expect: String) -> void:
	_player().global_position = into
	await _until(func() -> bool: return is_instance_valid(GameState.current_place) \
			and GameState.current_place.scene_file_path == expect \
			and GameState.current_place.is_node_ready(), 10.0)
	await _prepare()
	await get_tree().create_timer(0.5).timeout


func _prepare() -> void:
	_player().scripted = true
	_player().set_process_unhandled_input(false)
	await get_tree().physics_frame


func _place() -> Place:
	return GameState.current_place as Place


func _player() -> PlayerController:
	return _place().player


func _act(stand: Vector3, target: Interactable, mode: StringName) -> void:
	var player := _player()
	player.global_position = stand
	var to := target.get_interaction_position() - stand
	player.facing_yaw = atan2(to.x, to.z)
	for i in 4:
		await get_tree().physics_frame
	if player.detector.current != target:
		_check(false, "%s is the target at %s (got %s)" % [target.interaction_name, stand,
				player.detector.current.interaction_name if player.detector.current else "nothing"])
		return
	player.scripted_hold = true
	if mode == &"use":
		player.try_interact()
	await _until(func() -> bool: return not player.is_busy() \
			or player.state == PlayerController.State.FOCUS, 8.0)
	player.scripted_hold = false
	await get_tree().physics_frame


func _until(condition: Callable, timeout: float) -> void:
	var start := Time.get_ticks_msec()
	while not condition.call() and (Time.get_ticks_msec() - start) / 1000.0 < timeout:
		await get_tree().process_frame


func _check(ok: bool, what: String) -> void:
	_checks += 1
	if not ok:
		_failures += 1
	print(("PASS  " if ok else "FAIL  ") + what)
