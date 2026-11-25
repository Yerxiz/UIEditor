extends Control

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

# Сигнал, чтобы главный скрипт знал, что мы кликнули по этому элементу
signal element_clicked(element)

func _gui_input(event: InputEvent) -> void:
	# Обработка нажатия мыши
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			# Запоминаем, за какую точку мы схватили элемент
			drag_offset = get_global_mouse_position() - global_position
			# Поднимаем элемент на передний план
			move_to_front()
			# Сообщаем главному окну, что элемент выбран
			element_clicked.emit(self)
		else:
			is_dragging = false
			
	# Обработка движения мыши
	elif event is InputEventMouseMotion and is_dragging:
		# Двигаем элемент за мышью
		global_position = get_global_mouse_position() - drag_offset
