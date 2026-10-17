extends Node
## Everything that outlives a single place, autoloaded as "GameState": the run
## (seed, day, clock, phase), the bag, the home stash and tools, the
## flashlight, what each place looked like when the player left it, noise,
## and travelling between places behind a fade.

signal phase_changed(phase: StringName)
signal items_changed
## Something the player should be told (flashlight died, bag full...).
signal notice(text: String)

const HOME := "res://scenes/room/room_01.tscn"
const DAY_START := 16.0
const DUSK := 20.0
## Real seconds per in-game hour during the day.
const DAY_HOUR_SECONDS := 45.0
## Seconds of light per flashlight battery.
const BATTERY_SECONDS := 70.0
## Seconds the player has to get home once it is dark.
const STRANDED_LIMIT := 25.0

var run_seed := 0
## Seeded per run; every content roll uses it.
var rng := RandomNumberGenerator.new()
var day := 1
## Hours since midnight of day 1; runs past 24 at night (29.5 = 05:30).
var hour := DAY_START
## &"day", &"stranded" (outside after dusk), &"night", &"over".
var phase: StringName = &"day"
## Off in tests that want a frozen clock.
var clock_running := true
var bag := Inventory.new(3)
var stash := Inventory.new(-1)
## Tools found so far: id -> true.
var equipment := {}
var flashlight_on := false
var flashlight_charge := 1.0
## State shared by places that show the same thing (a door seen from both sides).
var shared := {}
## Scene path -> {node path: state}, saved when the player leaves a place.
var places := {}
## Name of the marker the next place spawns the player at ("" = its default).
var entry := ""
var current_place: Node = null
var stranded_time := 0.0

var _fade: ColorRect
var _travelling := false


func _ready() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_fade)
	bag.changed.connect(items_changed.emit)
	stash.changed.connect(items_changed.emit)
	new_run()


## Starts over: day 1, 16:00, empty bag, untouched building. `seed` < 0 picks one.
func new_run(seed := -1) -> void:
	run_seed = seed if seed >= 0 else randi()
	rng.seed = run_seed
	day = 1
	hour = DAY_START
	phase = &"day"
	clock_running = true
	bag.stacks.clear()
	stash.stacks.clear()
	equipment.clear()
	flashlight_on = false
	flashlight_charge = 1.0
	shared.clear()
	places.clear()
	entry = ""
	stranded_time = 0.0
	items_changed.emit()


func restart_run() -> void:
	new_run()
	_change_scene(HOME)


func is_home() -> bool:
	return current_place != null and current_place.scene_file_path == HOME


func set_phase(next: StringName) -> void:
	if phase == next:
		return
	phase = next
	phase_changed.emit(next)


func clock_text() -> String:
	return "%02d:%02d" % [int(hour) % 24, int(fmod(hour, 1.0) * 60.0)]


func _process(delta: float) -> void:
	if phase == &"day" and clock_running:
		hour += delta / DAY_HOUR_SECONDS
		if hour >= DUSK:
			hour = DUSK
			set_phase(&"night" if is_home() else &"stranded")
	elif phase == &"stranded":
		stranded_time += delta
	_drain_flashlight(delta)


# ------------------------------------------------------------------ items

func has_tool(id: StringName) -> bool:
	return equipment.has(id)


## How many the player can use right now: the bag, plus the stash at home.
func count(id: StringName) -> int:
	return bag.count(id) + (stash.count(id) if is_home() else 0)


## Uses up `amount` (stash first when at home). False if there aren't enough.
func take(id: StringName, amount := 1) -> bool:
	if count(id) < amount:
		return false
	var left := amount
	if is_home():
		left -= stash.remove(id, left)
	if left > 0:
		bag.remove(id, left)
	return true


## Picks up `amount`; tools are kept for good. At home it goes straight to the
## stash. Returns how many were taken (bag space can run out).
func give(id: StringName, amount: int) -> int:
	if Items.is_equipment(id):
		equipment[id] = true
		items_changed.emit()
		return amount
	return (stash if is_home() else bag).add(id, amount)


## Moves the bag into the home stash. Returns what moved.
func unpack() -> Dictionary:
	return bag.move_all_to(stash)


# ------------------------------------------------------------------ flashlight

func set_flashlight(on: bool) -> void:
	if on and not has_tool(&"flashlight"):
		return
	if on and flashlight_charge <= 0.0:
		if not take(&"battery"):
			notice.emit("The flashlight is dead. I need batteries.")
			return
		flashlight_charge = 1.0
	flashlight_on = on
	items_changed.emit()


func _drain_flashlight(delta: float) -> void:
	if not flashlight_on:
		return
	flashlight_charge -= delta / BATTERY_SECONDS
	if flashlight_charge > 0.0:
		return
	if take(&"battery"):
		flashlight_charge = 1.0
		notice.emit("Swapped in a fresh battery")
	else:
		flashlight_charge = 0.0
		flashlight_on = false
		notice.emit("The flashlight died.")
	items_changed.emit()


# ------------------------------------------------------------------ noise, travel

## Something made a sound at `position` (0..1 loud). Listeners decide if they hear it.
func noise(position: Vector3, loudness: float) -> void:
	get_tree().call_group(&"listeners", &"hear", position, loudness)


## Leaves the current place (saving it) for `scene_path`, spawning at `entry_name`.
func travel(scene_path: String, entry_name: String) -> void:
	if _travelling:
		return
	if current_place and current_place.has_method(&"save_state"):
		current_place.save_state()
	entry = entry_name
	_change_scene(scene_path)


func _change_scene(scene_path: String) -> void:
	_travelling = true
	var out := create_tween()
	out.tween_property(_fade, "color:a", 1.0, 0.25)
	await out.finished
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await get_tree().process_frame
	create_tween().tween_property(_fade, "color:a", 0.0, 0.35)
	_travelling = false
