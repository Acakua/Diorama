extends Place
## 4A, home. [content — spoilers: see content/bible.md]

@export var cabinet: InteractiveCabinet
@export var radio: InteractiveRadio

## [hour, lines] read out once per run while the radio is on during the day.
const DAY_BULLETINS := [
	[16.25, [
		"...police are asking residents of the eastern districts to stay home tonight.",
		"Hospitals report a sharp rise in fever cases. Avoid anyone who seems unwell.",
	]],
	[18.0, [
		"...the city has declared a curfew from eight p.m.",
		"Gather water, food and supplies while you still can.",
	]],
]


func _first_visit() -> void:
	cabinet.contents.assign({&"flashlight": 1, &"battery": 1})


func _process(_delta: float) -> void:
	if GameState.phase != &"day" or not radio.is_on:
		return
	for i in DAY_BULLETINS.size():
		var key := "day_bulletin_%d" % i
		if GameState.hour >= DAY_BULLETINS[i][0] and not GameState.shared.has(key):
			GameState.shared[key] = true
			var lines: Array[String] = []
			lines.assign(DAY_BULLETINS[i][1])
			radio.play_bulletin(lines)
