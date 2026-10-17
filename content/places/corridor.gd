extends Place
## Floor 4 corridor. [content — spoilers: see content/bible.md]

@export var pile: Searchable


func _first_visit() -> void:
	pile.contents.assign({&"plank": 2})
