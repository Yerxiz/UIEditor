extends Control

@onready var hierarchy = $MainLayout/HaT_PanelContainer/VSplitContainer/Hierarchy
@onready var toolbar = $MainLayout/HaT_PanelContainer/VSplitContainer/Toolbar
@onready var canvas = $MainLayout/Canvas_SubViewportContainer/Canvas_SubViewport/CanvasRoot
@onready var inspector = $MainLayout/Inspector_PanelContainer/Inspector

var element_counter : int = 0
var selected_element : Control = null
var elements : Dictionary


func _ready() -> void:
	var add_button = toolbar.get_node("AddButton")
	var add_label = toolbar.get_node("AddLabel")


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
	
	new_element.position.x = canvas.size.x / 2.0
	new_element.position.y = canvas.size.y / 2.0
	new_element.name = type + str(element_counter)
	element_counter += 1
	
	canvas.add_child(new_element)
	
	_update_all_elements(new_element, type, ind)
	_update_hierarchy()
	

func _on_element_selected(element : Control) -> void:
	selected_element = element
	_update_inspector()


func _update_all_elements(new_element : Control, type : String,
							ind : int) -> void:
	var prop_name : String = type + "_" + str(ind)
	
	var data : Dictionary = {
		"type": type,
		"name": prop_name, 
		"size": new_element.size, 
		"position": new_element.position, 
		"rotation": new_element.rotation
	}
	if "text" in new_element:
		data["text"] = new_element.text
	if "color" in new_element:
		data["color"] = new_element.color
		
	elements[new_element] = data


func _update_hierarchy() -> void:
	pass


func _update_inspector() -> void:
	var current_element : Control
	if selected_element:
		if elements.has(selected_element):
			print(elements[selected_element])
			#current_element = elements[selected_element]
			pass


func _on_main_layout_dragged(offset: int) -> void:
	for el in elements:
		el.position.x -= offset
		el.position.y -= offset * $MainLayout/AspectRatioContainer.ratio


func _on_delete_button_button_up() -> void:
	var current_element : Control
	if selected_element:
		if elements.has(selected_element):
			#current_element = elements[selected_element]
			elements.erase(selected_element)
			selected_element.queue_free()
