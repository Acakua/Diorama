class_name NightOverlay
extends CanvasLayer
## Story-side UI: the clock in the corner, the objective, radio subtitles, the
## character's passing thoughts, notes being read, and the end screen
## (R starts a new run).

var _tweens := {}

@onready var _clock: Label = $Clock
@onready var _objective: Label = $Objective
@onready var _subtitle: Label = $Subtitle
@onready var _thought: Label = $Thought
@onready var _note: Control = $Note
@onready var _note_title: Label = $Note/Paper/Box/Title
@onready var _note_text: Label = $Note/Paper/Box/Text
@onready var _end: Control = $End
@onready var _end_title: Label = $End/Box/Title
@onready var _end_text: Label = $End/Box/Text


func _ready() -> void:
	add_to_group(&"night_overlay")
	for label in [_objective, _subtitle, _thought]:
		label.modulate.a = 0.0
	_note.visible = false
	_end.visible = false


func _process(_delta: float) -> void:
	_clock.text = GameState.clock_text()


func _unhandled_input(event: InputEvent) -> void:
	if _end.visible and event.is_action_pressed(&"restart"):
		GameState.restart_run()


func show_objective(text: String, seconds := 8.0) -> void:
	_show(_objective, text, seconds)


## One radio line; the radio decides how long it stays.
func show_subtitle(text: String, seconds: float) -> void:
	_show(_subtitle, text, seconds)


## The player character thinking out loud.
func show_thought(text: String, seconds := 4.5) -> void:
	_show(_thought, text, seconds)


func show_note(title: String, text: String) -> void:
	_note_title.text = title
	_note_text.text = text
	_note.visible = true
	_note.modulate.a = 0.0
	create_tween().tween_property(_note, "modulate:a", 1.0, 0.2)


func hide_note() -> void:
	_note.visible = false


func is_end_shown() -> bool:
	return _end.visible


func show_end(survived: bool, detail: String) -> void:
	_note.visible = false
	_end_title.text = "You made it through the night." if survived else "You didn't make it."
	_end_text.text = detail
	_end.visible = true
	_end.modulate.a = 0.0
	create_tween().tween_property(_end, "modulate:a", 1.0, 1.2 if survived else 0.6)


func _show(label: Label, text: String, seconds: float) -> void:
	label.text = text
	if _tweens.has(label):
		(_tweens[label] as Tween).kill()
	var t := create_tween()
	t.tween_property(label, "modulate:a", 1.0, 0.3)
	t.tween_interval(maxf(0.0, seconds - 0.6))
	t.tween_property(label, "modulate:a", 0.0, 0.3)
	_tweens[label] = t
