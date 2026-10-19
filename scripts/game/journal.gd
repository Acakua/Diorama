extends Node
## What the player has learned, autoloaded as "Journal". Unlike everything in
## GameState it survives a lost run and quitting the game (user://journal.json):
## notes read, people met, places found, clues worked out. Content can hide
## things until a clue is known (Interactable.requires_knowledge).

## Emitted once per new entry.
signal learned(entry: Dictionary)

## Display order and titles.
const CATEGORIES := {&"clues": "Clues", &"notes": "Notes", &"people": "People", &"places": "Places"}

## Off in tests, so they never touch the player's real journal.
var persistent := true
var save_path := "user://journal.json"
var _entries: Array[Dictionary] = []
var _by_id := {}


func _ready() -> void:
	_load()


## Records an entry; returns false if it was already known.
func learn(id: StringName, category: StringName, title: String, text: String) -> bool:
	if _by_id.has(id):
		return false
	var entry := {"id": String(id), "category": String(category), "title": title, "text": text}
	_entries.append(entry)
	_by_id[id] = entry
	_save()
	learned.emit(entry)
	return true


func knows(id: StringName) -> bool:
	return id == &"" or _by_id.has(id)


## Entries of one category, oldest first.
func entries(category: StringName) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for e in _entries:
		if e["category"] == String(category):
			out.append(e)
	return out


func count() -> int:
	return _entries.size()


## Wipes everything learned (a fresh start for the player).
func forget_all() -> void:
	_entries.clear()
	_by_id.clear()
	_save()


## Re-reads the save file (tests use this to check what was written).
func reload() -> void:
	_entries.clear()
	_by_id.clear()
	_load()


## Tests: start empty and never read or write the save file.
func use_memory_only() -> void:
	persistent = false
	_entries.clear()
	_by_id.clear()


func _load() -> void:
	if not persistent or not FileAccess.file_exists(save_path):
		return
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(save_path))
	if not data is Array:
		return
	for e in data:
		if e is Dictionary and e.has("id"):
			var entry: Dictionary = e
			_entries.append(entry)
			_by_id[StringName(entry["id"])] = entry


func _save() -> void:
	if not persistent:
		return
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_entries, "\t"))
