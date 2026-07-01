@tool
class_name LivePlotLine
extends ColorRect


var line_plot: RID

var resolution: int = 256

@export_group("Test Input")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var toggle_test_input: bool = false
@export_range(0., 1., 0.0001) var test_input_value: float 


var buffer: PackedVector2Array
var current_max: float = 0.
var current_min: float = 0.

func _ready() -> void:
	buffer = PackedVector2Array()
	buffer.resize(resolution)
	for i in resolution:
		buffer[i] = Vector2(float(i) / float(resolution) * size.x, 1.)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		if toggle_test_input:
			process_value(clampf(test_input_value, 0., 1.))
	pass	

func process_value(x: float) -> void:
	for i in range(resolution - 1, 0, -1): 
		buffer[i] = Vector2(float(i) / float(resolution) * size.x, buffer[i - 1].y)
	buffer[0] = Vector2(0., (1. - x) * size.y)
	queue_redraw()


func _draw() -> void:
	draw_polyline(buffer, Color.WHITE, 1.)
