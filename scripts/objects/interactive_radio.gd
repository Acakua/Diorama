class_name InteractiveRadio
extends Interactable
## Desk radio. Pressing the power button dips the button, turns the volume
## knob, lights the indicator and the dial, slides the tuning needle, makes the
## speaker pulse with the beat and fades the music in (and all of it back out).
## At night it also reads out emergency bulletins, but only while it is on.

## One line of a bulletin, shown as a subtitle for `seconds`.
signal subtitle(text: String, seconds: float)

@export var is_on := false
@export var music_volume_db := -9.0
## Seconds each bulletin line stays on screen.
@export var line_time := 3.8

const LED_ENERGY := 5.0
const DIAL_ENERGY := 2.2
const GLOW_ENERGY := 1.4
const KNOB_ON := -2.2
const NEEDLE_TRAVEL := 0.05
## Matches the tempo of the bundled loop (84 BPM).
const BEAT_HZ := 1.4

var _led_mat: StandardMaterial3D
var _dial_mat: StandardMaterial3D
var _tween: Tween
var _level := 0.0
var _beat_time := 0.0
var _button_rest := Vector3.ZERO
var _needle_rest := Vector3.ZERO
var _bulletin: Array[String] = []
var _line_timer := 0.0

@onready var _button: Node3D = $ButtonPivot
@onready var _knob: Node3D = $KnobPivot
@onready var _needle: Node3D = $Needle
@onready var _speaker: Node3D = $SpeakerPivot
@onready var _led: MeshInstance3D = $Led
@onready var _dial: MeshInstance3D = $Dial
@onready var _glow: OmniLight3D = $Glow
@onready var _music: AudioStreamPlayer3D = $Music
@onready var _voice: AudioStreamPlayer3D = $Voice


func _ready() -> void:
	super()
	add_to_group(&"persistent")
	_led_mat = _led.material_override.duplicate()
	_led.material_override = _led_mat
	_dial_mat = _dial.material_override.duplicate()
	_dial.material_override = _dial_mat
	_button_rest = _button.position
	_needle_rest = _needle.position
	_music.finished.connect(_on_music_finished)
	_apply(is_on, 0.0)


func get_prompt() -> String:
	return "Turn Radio Off" if is_on else "Turn Radio On"


func get_led_energy() -> float:
	return _led_mat.emission_energy_multiplier


func get_state() -> Dictionary:
	return {"is_on": is_on}


func set_state(state: Dictionary) -> void:
	set_on(state.get("is_on", is_on))


## Switches on or off without the button press (e.g. at the start of a night).
func set_on(on: bool) -> void:
	is_on = on
	_apply(on, 0.0)


## Reads `lines` out over the music. Missed if the radio is off.
func play_bulletin(lines: Array[String]) -> void:
	if not is_on:
		return
	_bulletin = lines.duplicate()
	_line_timer = 0.0
	_voice.play()
	create_tween().tween_property(_music, "volume_db", music_volume_db - 16.0, 0.4)


func _on_interact(_player: Node3D) -> String:
	is_on = not is_on
	play_sound(&"SfxButton")
	var press := create_tween()
	press.tween_property(_button, "position:y", _button_rest.y - 0.007, 0.05) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	press.tween_property(_button, "position:y", _button_rest.y, 0.12) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_apply(is_on, 0.35)
	return "Radio on" if is_on else "Radio off"


func _process(delta: float) -> void:
	_read_bulletin(delta)
	_level = move_toward(_level, 1.0 if is_on else 0.0, delta * 3.0)
	if _level <= 0.0:
		_speaker.scale = Vector3.ONE
		_beat_time = 0.0
		return
	_beat_time += delta
	var beat := pow(maxf(0.0, sin(_beat_time * TAU * BEAT_HZ)), 8.0)
	_speaker.scale = Vector3.ONE * (1.0 + 0.07 * beat * _level)


func _read_bulletin(delta: float) -> void:
	if not _voice.playing:
		return
	if not is_on:
		_bulletin.clear()
		_voice.stop()
		return
	_line_timer -= delta
	if _line_timer > 0.0:
		return
	if _bulletin.is_empty():
		_voice.stop()
		create_tween().tween_property(_music, "volume_db", music_volume_db, 0.8)
		return
	subtitle.emit(_bulletin.pop_front(), line_time)
	_line_timer = line_time


func _apply(on: bool, time: float) -> void:
	if _tween:
		_tween.kill()
	var knob_to := KNOB_ON if on else 0.0
	var needle_to := _needle_rest.x + (NEEDLE_TRAVEL if on else 0.0)
	if time <= 0.0:
		_led_mat.emission_energy_multiplier = LED_ENERGY if on else 0.0
		_dial_mat.emission_energy_multiplier = DIAL_ENERGY if on else 0.0
		_glow.light_energy = GLOW_ENERGY if on else 0.0
		_knob.rotation.z = knob_to
		_needle.position.x = needle_to
		if on:
			_music.volume_db = music_volume_db
			_music.play()
		return
	_tween = create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(_led_mat, "emission_energy_multiplier", LED_ENERGY if on else 0.0, 0.12)
	_tween.tween_property(_dial_mat, "emission_energy_multiplier", DIAL_ENERGY if on else 0.0, time)
	_tween.tween_property(_glow, "light_energy", GLOW_ENERGY if on else 0.0, time)
	_tween.tween_property(_knob, "rotation:z", knob_to, 0.3)
	_tween.tween_property(_needle, "position:x", needle_to, 0.5)
	if on:
		if not _music.playing:
			_music.volume_db = -30.0
			_music.play()
		_tween.tween_property(_music, "volume_db", music_volume_db, 0.6)
	else:
		_tween.tween_property(_music, "volume_db", -40.0, 0.3)
		_tween.chain().tween_callback(_music.stop)


func _on_music_finished() -> void:
	# Safety net in case the stream was imported without loop points.
	if is_on:
		_music.play()
