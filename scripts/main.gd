extends Control

@onready var hierarchy = $MainLayout/HaT_PanelContainer/VSplitContainer/Hierarchy
@onready var toolbar = $MainLayout/HaT_PanelContainer/VSplitContainer/Toolbar
@onready var canvas = $MainLayout/Canvas_SubViewportContainer/Canvas_SubViewport/CanvasRoot
@onready var inspector = $MainLayout/Inspector_PanelContainer/Inspector

# Ссылки на элементы в Toolbar
@onready var add_button_btn = $MainLayout/HaT_PanelContainer/VSplitContainer/Toolbar/AddButton
@onready var add_label_btn = $MainLayout/HaT_PanelContainer/VSplitContainer/Toolbar/AddLabel
@onready var add_color_rect_btn = $MainLayout/HaT_PanelContainer/VSplitContainer/Toolbar/AddColorRect
@onready var save_btn = $MainLayout/HaT_PanelContainer/VSplitContainer/Toolbar/SaveBtn
@onready var clear_btn = $MainLayout/HaT_PanelContainer/VSplitContainer/Toolbar/ClearBtn

# Ссылки на элементы в Инспекторе
@onready var delete_btn = $MainLayout/Inspector_PanelContainer/Inspector/DeleteButton

@onready var prop_name_hboxcont = $MainLayout/Inspector_PanelContainer/Inspector/PropName_HBoxContainer
@onready var prop_name_edit = $MainLayout/Inspector_PanelContainer/Inspector/PropName_HBoxContainer/PropName_LineEdit

@onready var prop_anchor_hboxcont = $MainLayout/Inspector_PanelContainer/Inspector/PropAnchor_HBoxContainer
@onready var prop_anchor_option =  $MainLayout/Inspector_PanelContainer/Inspector/PropAnchor_HBoxContainer/PropAnchor_OptionButton

@onready var prop_x_hboxcont = $MainLayout/Inspector_PanelContainer/Inspector/PropX_HBoxContainer
@onready var prop_x_spinbox = $MainLayout/Inspector_PanelContainer/Inspector/PropX_HBoxContainer/PropX_SpinBox

@onready var prop_y_hboxcont = $MainLayout/Inspector_PanelContainer/Inspector/PropY_HBoxContainer
@onready var prop_y_spinbox = $MainLayout/Inspector_PanelContainer/Inspector/PropY_HBoxContainer/PropY_SpinBox

@onready var prop_width_hboxcont = $MainLayout/Inspector_PanelContainer/Inspector/PropWidth_HBoxContainer
@onready var prop_width_spinbox = $MainLayout/Inspector_PanelContainer/Inspector/PropWidth_HBoxContainer/PropWidth_SpinBox

@onready var prop_height_hboxcont = $MainLayout/Inspector_PanelContainer/Inspector/PropHeight_HBoxContainer
@onready var prop_height_spinbox = $MainLayout/Inspector_PanelContainer/Inspector/PropHeight_HBoxContainer/PropHeight_SpinBox

@onready var prop_text_hboxcont = $MainLayout/Inspector_PanelContainer/Inspector/PropText_HBoxContainer
@onready var prop_text_edit = $MainLayout/Inspector_PanelContainer/Inspector/PropText_HBoxContainer/PropText_LineEdit

@onready var prop_color_hboxcont = $MainLayout/Inspector_PanelContainer/Inspector/PropColor_HBoxContainer
@onready var prop_color_picker = $MainLayout/Inspector_PanelContainer/Inspector/PropColor_HBoxContainer/PropColor_ColorPickerBtn

# Ссылка на FileDialog
@onready var save_file_dialog = $SaveFileDialog

var element_counter : int = 0
var selected_element : Control = null:
	set(value):
		if selected_element == value:
			return
		selected_element = value
		_update_inspector()
		
		
var elements : Dictionary
var inspector_props : Array


func _ready() -> void:
	add_button_btn.button_up.connect(_on_add_element.bind("button"))
	add_label_btn.button_up.connect(_on_add_element.bind("label"))
	add_color_rect_btn.button_up.connect(_on_add_element.bind("color_rect"))
	
	save_btn.button_up.connect(_on_save_button_pressed)
	save_file_dialog.file_selected.connect(_on_file_selected)
	
	delete_btn.button_up.connect(_on_delete_button_button_up)
	
	prop_name_hboxcont.hide()
	prop_anchor_hboxcont.hide()
	prop_x_hboxcont.hide()
	prop_y_hboxcont.hide()
	prop_width_hboxcont.hide()
	prop_height_hboxcont.hide()
	prop_text_hboxcont.hide()
	prop_color_hboxcont.hide()
	
	prop_name_edit.text_changed.connect(_on_inspector_changed)
	prop_x_spinbox.value_changed.connect(_on_inspector_changed)
	prop_y_spinbox.value_changed.connect(_on_inspector_changed)
	prop_width_spinbox.value_changed.connect(_on_inspector_changed)
	prop_height_spinbox.value_changed.connect(_on_inspector_changed)
	prop_text_edit.text_changed.connect(_on_inspector_changed)
	prop_color_picker.color_changed.connect(_on_inspector_changed)
	
	prop_anchor_option.item_selected.connect(_on_anchor_preset_selected)


func _on_add_element(type : String) -> void:
	var new_element : Control
	type = type.to_lower()
	
	var ind : int = 1
	for key in elements:
		if elements[key]["type"] == type:
			ind += 1
	
	if type == "button":
		new_element = Button.new()
		new_element.text = "Button_" + str(ind)
		new_element.name = new_element.text
		
	elif type == "label":
		new_element = Label.new()
		new_element.text = "Text_" + str(ind)
		new_element.name = new_element.text
		new_element.mouse_filter = Control.MOUSE_FILTER_PASS
	elif type == "color_rect":
		new_element = ColorRect.new()
		new_element.name = "ColorRect_" + str(ind)
		new_element.size = Vector2(40.0, 40.0)
		
	new_element.set_script(load("res://scripts/DraggableElement.gd"))
	new_element.element_clicked.connect(_on_element_selected)
	new_element.element_dragged.connect(_on_element_dragged)
	
	new_element.anchor_left = 0.0
	new_element.anchor_top = 0.0
	new_element.position = Vector2(canvas.size.x / 2.0, canvas.size.y / 2.0)
	
	element_counter += 1
	
	canvas.add_child(new_element)
	
	_update_all_elements(new_element, type, ind)
	_update_hierarchy()
	
	selected_element = new_element


func _update_all_elements(new_element : Control, type : String,
							ind : int) -> void:
	var prop_name : String = type + "_" + str(ind)
	
	var data : Dictionary = {
		"type": type,
		"name": prop_name,
		"anchor_preset": prop_anchor_option.selected,
		"size": new_element.size,
		"position": new_element.position,
		"rotation": new_element.rotation
	}
	if "text" in new_element:
		data["text"] = new_element.text
	if "color" in new_element:
		data["color"] = new_element.color
		
	elements[new_element] = data


func _on_anchor_preset_selected(index : int) -> void:
	if not selected_element : return
	
	match index:
		0:	# Top-Left
			selected_element.anchor_left = 0.0
			selected_element.anchor_top = 0.0
			selected_element.anchor_right = 0.0
			selected_element.anchor_bottom = 0.0
		1:	# Center
			selected_element.anchor_left = 0.5
			selected_element.anchor_top = 0.5
			selected_element.anchor_right = 0.5
			selected_element.anchor_bottom = 0.5
			
			var width = selected_element.size.x
			var height = selected_element.size.y
			selected_element.offset_left = -width / 2.0
			selected_element.offset_top = -height / 2.0
			selected_element.offset_right = width / 2.0
			selected_element.offset_bottom = height / 2.0
			
	_set_block_inspector_props_signals(true)
	prop_x_spinbox.value = selected_element.position.x
	prop_y_spinbox.value = selected_element.position.y
	_set_block_inspector_props_signals(false)
	
	elements[selected_element]["anchor_preset"] = index


func _on_element_selected(element : Control) -> void:
	selected_element = element
	print(elements[selected_element])
	
	for item in hierarchy.get_root().get_children():
		if item.get_metadata(0) == element:
			item.select(0)
			break


func _on_element_dragged(element : Control) -> void:
	if element == selected_element:
		_set_block_inspector_props_signals(true)
		prop_x_spinbox.value = element.position.x
		prop_y_spinbox.value = element.position.y
		_set_block_inspector_props_signals(false)
		elements[element]["position"] = element.position


func _update_inspector() -> void:
	var current_element : Control
	if not selected_element or not elements.has(selected_element):
		return
	print(elements[selected_element])
	
	prop_name_hboxcont.show()
	prop_anchor_hboxcont.show()
	prop_x_hboxcont.show()
	prop_y_hboxcont.show()
	prop_width_hboxcont.show()
	prop_height_hboxcont.show()
	var data = elements[selected_element]
	
	_set_block_inspector_props_signals(true)
	
	prop_name_edit.text = data["name"]
	prop_x_spinbox.value = data["position"].x
	prop_y_spinbox.value = data["position"].y
	prop_width_spinbox.value = data["size"].x
	prop_height_spinbox.value = data["size"].y
	
	if data.has("anchor_preset"):
		prop_anchor_option.select(data["anchor_preset"])
	
	if data["type"] in ["button", "label"]:
		prop_text_hboxcont.show()
		prop_color_hboxcont.hide()
		prop_text_edit.text = data["text"]
	elif data["type"] == "color_rect":
		prop_text_hboxcont.hide()
		prop_color_hboxcont.show()
		prop_color_picker.color = data["color"]
	
	_set_block_inspector_props_signals(false)


func _update_hierarchy() -> void:
	hierarchy.clear()
	var root = hierarchy.create_item()
	root.set_text(0, "Canvas")
	
	for el in elements:
		if is_instance_valid(el):
			var item = hierarchy.create_item(root)
			item.set_text(0, el.name)
			item.set_metadata(0, el)


func _on_hierarchy_item_selected() -> void:
	var selected_item = hierarchy.get_selected()
	if selected_item:
		var el = selected_item.get_metadata(0)
		if el and is_instance_valid(el):
			selected_element = el
			el.move_to_front()


func _on_inspector_changed(_value = null) -> void:
	if not selected_element: return
	
	var data = elements[selected_element]
	
	if prop_name_edit.text:
		selected_element.name = prop_name_edit.text
		data["name"] = prop_name_edit.text
	
	selected_element.position.x = prop_x_spinbox.value
	selected_element.position.y = prop_y_spinbox.value
	data["position"] = selected_element.position
	
	selected_element.size.x = prop_width_spinbox.value
	selected_element.size.y = prop_height_spinbox.value
	data["size"] = selected_element.size
	
	if data["type"] in ["button", "label"]:
		selected_element.text = prop_text_edit.text
		data["text"] = prop_text_edit.text
		
	elif data["type"] == "color_rect":
		selected_element.color = prop_color_picker.color
		data["color"] = prop_color_picker.color
		
	_update_hierarchy()


func _set_block_inspector_props_signals(value : bool) -> void:
	prop_name_edit.set_block_signals(value)
	prop_anchor_option.set_block_signals(value)
	prop_x_spinbox.set_block_signals(value)
	prop_y_spinbox.set_block_signals(value)
	prop_width_spinbox.set_block_signals(value)
	prop_height_spinbox.set_block_signals(value)
	prop_text_edit.set_block_signals(value)
	prop_color_picker.set_block_signals(value)


func _on_delete_button_button_up() -> void:
	if selected_element and elements.has(selected_element):
		elements.erase(selected_element)
		selected_element.queue_free()
		
		if not elements:
			prop_name_hboxcont.hide()
			prop_anchor_hboxcont.hide()
			prop_x_hboxcont.hide()
			prop_y_hboxcont.hide()
			prop_width_hboxcont.hide()
			prop_height_hboxcont.hide()
			prop_text_hboxcont.hide()
			prop_color_hboxcont.hide()
			
		_update_hierarchy()
		
func _on_save_button_pressed() -> void:
	save_file_dialog.popup_centered()
	
func _on_file_selected(path: String) -> void:
	if not path.ends_with(".json"):
		path += ".json"
		
	# 1. Базовую структура JSON
	var export_data = {
		"format_version": "1.0",
		"engine_target": "Universal",
		"canvas": {
			"width": 1920,
			"height": 1080
		},
		"elements": []
	}
	
	# 2. Проходим по всем элементам на холсте и собираем их данные
	for el in elements:
		if is_instance_valid(el):
			var el_data = elements[el]
			
			# Словарь для конкретного элемента
			var json_element = {
				"id": el_data["name"],
				"type": el_data["type"],
				"transform": {
					"x": roundi(el_data["position"].x),
					"y": roundi(el_data["position"].y),
					"width": roundi(el_data["size"].x),
					"height": roundi(el_data["size"].y),
					"rotation": el_data["rotation"]
				},
				"anchor_preset": el_data["anchor_preset"],
				"properties": {}
			}
			
			if el_data["type"] == "button" or el_data["type"] == "label":
				json_element["properties"]["text"] = el_data["text"]
			elif el_data["type"] == "color_rect":
				json_element["properties"]["color_hex"] = "#" + el_data["color"].to_html()
				
			export_data["elements"].append(json_element)
			
	# 3. Превращаем словарь в строку JSON с отступами
	var json_string = JSON.stringify(export_data, "\t", false)
	
	# 4. Записываем в файл
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("Проект успешно сохранен: ", path)
		_show_success_dialog("Проект успешно сохранен в JSON.")
	else:
		print("Ошибка при сохранении файла.")


func _show_success_dialog(message: String) -> void:
	var dialog = AcceptDialog.new()
	dialog.dialog_text = message
	dialog.title = "Save is success"
	add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
