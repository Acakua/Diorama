class_name Readable
extends Interactable
## A note, a letter, a scrawl on a wall: E shows it on screen until the player
## presses a key or walks away.

@export var title := ""
@export_multiline var text := ""
## Kept in the journal under this id once read.
@export var journal_id: StringName = &""
## An optional clue the note gives away.
@export var clue_id: StringName = &""
@export var clue_title := ""
@export_multiline var clue_text := ""


func get_prompt() -> String:
	return "Read %s" % interaction_name


func _on_interact(player: Node3D) -> String:
	var overlay := get_tree().get_first_node_in_group(&"night_overlay") as NightOverlay
	if overlay == null:
		return ""
	overlay.show_note(title, text)
	if journal_id != &"":
		Journal.learn(journal_id, &"notes", title, text)
	if clue_id != &"":
		Journal.learn(clue_id, &"clues", clue_title, clue_text)
	(player as PlayerController).begin_focus(get_interaction_position(), overlay.hide_note,
			PackedStringArray(["Close", "", ""]))
	return ""
