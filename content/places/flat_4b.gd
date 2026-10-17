extends Place
## 4B, Mr. Hale's flat. [content — spoilers: see content/bible.md]

@export var sink: Searchable
@export var kitchen_drawer: Searchable
@export var fridge: Searchable
@export var closet: Searchable
@export var wardrobe: InteractiveCabinet
@export var nightstand: Searchable
@export var desk_drawer: Searchable


func _first_visit() -> void:
	var rng := GameState.rng
	sink.contents.assign({&"hammer": 1})
	closet.contents.assign({&"plank": 2})
	if rng.randf() < 0.5:
		wardrobe.contents.assign({&"plank": 1})
	# Two batteries in two of three drawers.
	var spots: Array[Searchable] = [kitchen_drawer, nightstand, desk_drawer]
	for i in range(spots.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp := spots[i]
		spots[i] = spots[j]
		spots[j] = tmp
	spots[0].contents.assign({&"battery": 1})
	spots[1].contents.assign({&"battery": 1})
