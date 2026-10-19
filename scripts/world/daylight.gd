class_name Daylight
extends Node
## Drives a place's window light and ambient from GameState.hour: warm
## afternoon sun, a golden then violet dusk, cold moonlight, and dawn.

@export var window_light: Light3D
@export var world: WorldEnvironment
## Window glass material; its glow follows the sky (pale by day, blue at night).
@export var glass: StandardMaterial3D
## Overall brightness of this place's window (a corridor window is weaker).
@export var strength := 1.0
## How much of the window light is open sky rather than sun: a north window
## never gets the sun, only a cool, even light.
@export_range(0.0, 1.0) var sky := 0.0

const SKY_COLOR := Color(0.74, 0.82, 0.96)

## [hour, light colour, light energy, ambient colour, ambient energy]
const KEYS := [
	[16.0, Color(1.0, 0.86, 0.66), 12.0, Color(0.64, 0.6, 0.56), 0.55],
	[18.5, Color(1.0, 0.7, 0.45), 10.0, Color(0.62, 0.53, 0.48), 0.5],
	[19.7, Color(0.78, 0.55, 0.72), 6.0, Color(0.46, 0.43, 0.56), 0.42],
	[20.5, Color(0.55, 0.68, 1.0), 9.0, Color(0.42, 0.5, 0.7), 0.38],
	[28.8, Color(0.55, 0.68, 1.0), 9.0, Color(0.42, 0.5, 0.7), 0.38],
	[29.6, Color(1.0, 0.72, 0.45), 14.0, Color(0.62, 0.56, 0.52), 0.57],
	[31.0, Color(1.0, 0.86, 0.7), 12.0, Color(0.66, 0.62, 0.58), 0.6],
]


func _process(_delta: float) -> void:
	apply(GameState.hour)


func apply(hour: float) -> void:
	var a: Array = KEYS[0]
	var b: Array = KEYS[KEYS.size() - 1]
	for i in KEYS.size() - 1:
		if hour >= KEYS[i][0] and hour <= KEYS[i + 1][0]:
			a = KEYS[i]
			b = KEYS[i + 1]
			break
	var t := 0.0 if b[0] == a[0] else clampf((hour - a[0]) / (b[0] - a[0]), 0.0, 1.0)
	t = smoothstep(0.0, 1.0, t)
	if window_light:
		window_light.light_color = (a[1] as Color).lerp(b[1], t).lerp(SKY_COLOR, sky)
		window_light.light_energy = lerpf(a[2], b[2], t) * strength
	if world:
		world.environment.ambient_light_color = (a[3] as Color).lerp(b[3], t)
		world.environment.ambient_light_energy = lerpf(a[4], b[4], t)
	if glass:
		var sky := (a[1] as Color).lerp(b[1], t)
		var night := 1.0 - clampf((lerpf(a[2], b[2], t) - 9.0) / 3.0, 0.0, 1.0)
		glass.emission = sky.lerp(Color(0.35, 0.45, 0.7), night)
		glass.emission_energy_multiplier = lerpf(0.9, 0.25, night)
