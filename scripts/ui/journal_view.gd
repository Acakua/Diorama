class_name JournalView
extends CanvasLayer
## The journal screen: categories on the left, entries in the middle, the
## selected entry on the right. Opening it pauses the game. Built in code;
## it only needs to exist once per place (the place kit instances it).

var is_open := false

var _root: Control
var _tabs: HBoxContainer
var _list: ItemList
var _title: Label
var _text: Label
var _forget: Button
var _category: StringName = &"clues"
var _shown: Array[Dictionary] = []
var _forget_armed := false


func _ready() -> void:
	layer = 4
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group(&"journal_view")
	_build()
	_root.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"journal"):
		toggle()
		get_viewport().set_input_as_handled()
	elif is_open and event.is_action_pressed(&"ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	if is_open:
		close()
	else:
		open()


func open() -> void:
	is_open = true
	_root.visible = true
	_forget_armed = false
	_forget.text = "Forget everything"
	get_tree().paused = true
	# Start on the first category that has something in it.
	for c in Journal.CATEGORIES:
		if not Journal.entries(c).is_empty():
			_show_category(c)
			return
	_show_category(&"clues")


func close() -> void:
	is_open = false
	_root.visible = false
	get_tree().paused = false


func _show_category(category: StringName) -> void:
	_category = category
	for b in _tabs.get_children():
		(b as Button).button_pressed = b.name == String(category)
	_shown = Journal.entries(category)
	_list.clear()
	for e in _shown:
		_list.add_item(e["title"])
	if _shown.is_empty():
		_title.text = ""
		_text.text = "Nothing yet."
	else:
		_list.select(_shown.size() - 1)
		_show_entry(_shown.size() - 1)


func _show_entry(index: int) -> void:
	if index < 0 or index >= _shown.size():
		return
	_title.text = _shown[index]["title"]
	_text.text = _shown[index]["text"]


func _on_forget() -> void:
	if not _forget_armed:
		_forget_armed = true
		_forget.text = "Really forget everything?"
		return
	Journal.forget_all()
	_forget_armed = false
	_forget.text = "Forget everything"
	_show_category(_category)


func _build() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(dim)

	var paper := PanelContainer.new()
	paper.set_anchors_preset(Control.PRESET_CENTER)
	paper.offset_left = -400
	paper.offset_right = 400
	paper.offset_top = -250
	paper.offset_bottom = 250
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.9, 0.86, 0.76)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(22)
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 14
	paper.add_theme_stylebox_override(&"panel", style)
	_root.add_child(paper)

	var ink := Color(0.16, 0.13, 0.1)
	var box := VBoxContainer.new()
	box.add_theme_constant_override(&"separation", 12)
	paper.add_child(box)
	var header := HBoxContainer.new()
	box.add_child(header)
	var heading := Label.new()
	heading.text = "Journal"
	heading.add_theme_font_size_override(&"font_size", 26)
	heading.add_theme_color_override(&"font_color", ink)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(heading)
	var close_button := Button.new()
	close_button.text = "Close"
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.pressed.connect(close)
	header.add_child(close_button)

	_tabs = HBoxContainer.new()
	_tabs.add_theme_constant_override(&"separation", 8)
	box.add_child(_tabs)
	for c in Journal.CATEGORIES:
		var tab := Button.new()
		tab.name = String(c)
		tab.text = Journal.CATEGORIES[c]
		tab.toggle_mode = true
		tab.focus_mode = Control.FOCUS_NONE
		tab.pressed.connect(_show_category.bind(c))
		_tabs.add_child(tab)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override(&"separation", 18)
	box.add_child(body)
	_list = ItemList.new()
	_list.custom_minimum_size = Vector2(250, 0)
	_list.focus_mode = Control.FOCUS_NONE
	_list.add_theme_color_override(&"font_color", Color(0.93, 0.91, 0.86))
	_list.add_theme_color_override(&"font_selected_color", Color.WHITE)
	_list.item_selected.connect(_show_entry)
	body.add_child(_list)
	var page := VBoxContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override(&"separation", 10)
	body.add_child(page)
	_title = Label.new()
	_title.add_theme_font_size_override(&"font_size", 20)
	_title.add_theme_color_override(&"font_color", ink)
	page.add_child(_title)
	_text = Label.new()
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_text.add_theme_font_size_override(&"font_size", 16)
	_text.add_theme_color_override(&"font_color", ink)
	page.add_child(_text)

	_forget = Button.new()
	_forget.text = "Forget everything"
	_forget.focus_mode = Control.FOCUS_NONE
	_forget.size_flags_horizontal = Control.SIZE_SHRINK_END
	_forget.pressed.connect(_on_forget)
	box.add_child(_forget)
