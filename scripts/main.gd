extends Control

@onready var hierarchy = $MainLayout/HaT_PanelContainer/VSplitContainer/Hierarchy
@onready var toolbar = $MainLayout/HaT_PanelContainer/VSplitContainer/Toolbar
@onready var canvas = $MainLayout/Canvas_SubViewportContainer/Canvas_SubViewport/CanvasRoot
@onready var inspector = $MainLayout/Inspector_PanelContainer/Inspector

# Ссылки на элементы в Инспекторе
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
	var add_button = toolbar.get_node("AddButton")
	var add_label = toolbar.get_node("AddLabel")
	
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
		
	elif type == "label":
		new_element = Label.new()
		new_element.text = "Text_" + str(ind)
		new_element.mouse_filter = Control.MOUSE_FILTER_PASS
	elif type == "color_rect":
		new_element = ColorRect.new()
		new_element.size = Vector2(40.0, 40.0)
		
	new_element.set_script(load("res://scripts/DraggableElement.gd"))
	new_element.element_clicked.connect(_on_element_selected)
	new_element.element_dragged.connect(_on_element_dragged)
	
	new_element.anchor_left = 0.0
	new_element.anchor_top = 0.0
	new_element.position = Vector2(canvas.size.x / 2.0, canvas.size.y / 2.0)
	
	new_element.name = type + str(element_counter)
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


func _on_element_dragged(element : Control) -> void:
	if element == selected_element:
		_set_block_inspector_props_signals(true)
		prop_x_spinbox.value = element.position.x
		prop_y_spinbox.value = element.position.y
		_set_block_inspector_props_signals(false)
		elements[element]["position"] = element.position


func _update_hierarchy() -> void:
	pass


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
