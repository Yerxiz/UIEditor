extends Control

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

signal element_clicked(element)
signal element_dragged(element)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			drag_offset = get_global_mouse_position() - global_position
			move_to_front()
			element_clicked.emit(self)
		else:
			is_dragging = false
			
	elif event is InputEventMouseMotion and is_dragging:
		global_position = get_global_mouse_position() - drag_offset
		element_dragged.emit(self)
