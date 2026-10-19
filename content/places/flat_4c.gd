extends Place
## 4C, Mrs. Okafor's flat. [content — spoilers: see content/bible.md]

@export var dresser: Searchable
@export var closet: Searchable
@export var sewing: Searchable


func _first_visit() -> void:
	dresser.contents.assign({&"battery": 2})
	closet.contents.assign({&"plank": 1})
	if GameState.rng.randf() < 0.5:
		sewing.contents.assign({&"battery": 1})
