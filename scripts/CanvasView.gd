extends SubViewportContainer

@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.2
@export var max_zoom: float = 5.0

var is_panning: bool = false
var pan_start_mouse: Vector2

signal clear_selection

@onready var canvas_root: Control = $Canvas_SubViewport/CanvasRoot

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			clear_selection.emit()
	
	# --- Масштабирование (колесико мыши) ---
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_canvas(1.0 + zoom_speed, event.position)
			accept_event() # Событие обработано, не передаем дальше
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_canvas(1.0 - zoom_speed, event.position)
			accept_event()
			
		# --- Панорамирование (зажатие средней кнопки мыши) ---
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				is_panning = true
				pan_start_mouse = event.position
			else:
				is_panning = false
			accept_event()

	# --- Движение мыши для панорамирования ---
	elif event is InputEventMouseMotion and is_panning:
		var mouse_delta = event.position - pan_start_mouse
		canvas_root.position += mouse_delta
		pan_start_mouse = event.position
		accept_event()

func _zoom_canvas(factor: float, mouse_pos: Vector2) -> void:
	var old_scale = canvas_root.scale.x
	var new_scale = clamp(old_scale * factor, min_zoom, max_zoom)
	
	# Вычисляем, как сместить холст, чтобы зум происходил относительно курсора мыши
	var mouse_offset = mouse_pos - canvas_root.position
	canvas_root.scale = Vector2(new_scale, new_scale)
	canvas_root.position = mouse_pos - mouse_offset * (new_scale / old_scale)
