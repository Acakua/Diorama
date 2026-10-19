extends Place
## Floor 4 corridor. [content — spoilers: see content/bible.md]

@export var pile: Searchable
@export var ficus: Searchable


func _first_visit() -> void:
	pile.contents.assign({&"plank": 2})
	ficus.contents.assign({&"key_4c": 1})
