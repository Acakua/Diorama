extends Node
## Registers content-only items at startup, autoloaded as "Content".
## [content — spoilers: see content/bible.md]


func _ready() -> void:
	Items.register(&"key_4c", {"name": "Spare Key (4C)", "equipment": true})
