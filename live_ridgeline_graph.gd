@tool
class_name LiveRidgelineGraph
extends Control



@export var resolution: int = 256
@export var labels: Array[String] = []
@export var inputs: Array[Vector3]:
	set(v):
		var needs_reconfig: bool = v.size() != inputs.size()
		inputs = v
		if needs_reconfig: reconfig()
@export var range_gradient: Gradient

@export_group("Test Input")
# @export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var enable_test_input: bool = false
@export var enable_test_input: bool = false
@export var test_values: Array[float] = []

var buffer: Array[PackedVector2Array]
var colors: Array[PackedColorArray]

var test_buffer: Array[float]

func _ready() -> void:
	update_buffer_size()

func reconfig() -> void:
	if not is_node_ready(): await ready
	buffer.clear()
	colors.clear()
	test_buffer.clear()
	update_buffer_size()


func _physics_process(delta: float) -> void:
	if enable_test_input:
		for i in inputs.size():
				test_buffer[i] = test_values[i] if i < test_values.size() else 0.
		process_values(test_buffer)


func process_values(a: Array[float]) -> void:
	for i in inputs.size():
		for j in range(resolution - 1, 0, -1):
			buffer[i][j] = Vector2(
				size.x / float(resolution) * j,
				buffer[i][j - 1].y
			)
			colors[i][j] = colors[i][j - 1]
		buffer[i][0] = Vector2(
			0., 
			( 1. - clampf(remap(
				a[i],
				inputs[i].x, inputs[i].y, # ··················································· x and y of inputs[] vectors define bracket_min and bracket_max respectively
				0., 1.
			), 0., 1.) + inputs[i].z ) * size.y / float(inputs.size()) * 1.4 # ················ default maximum height of the ridge (double the segment height) 
			+ size.y / float(inputs.size()) * (i - 1)) # ······································ ridge-index position in the layout frame
		colors[i][0] = range_gradient.sample(abs(inputs[i].z - remap(a[i], inputs[i].x, inputs[i].y, 0., 1.)) / maxf(inputs[i].z, 1. - inputs[i].z))
	queue_redraw()

func _draw() -> void:
	for i in inputs.size():
		var z_line_h: float = (i + 0.4) * (size.y / float(inputs.size()))
		draw_dashed_line(Vector2(0., z_line_h), Vector2(size.x, z_line_h), Color(1., 1., 1., 0.3), 1., 4.)
		draw_polyline_colors(buffer[i], colors[i], 1, false)

func update_buffer_size() -> void:
	test_buffer.resize(inputs.size())
	buffer.resize(inputs.size())
	colors.resize(inputs.size())
	
	for i in inputs.size():
		buffer[i] = PackedVector2Array()
		buffer[i].resize(resolution)
		colors[i] = PackedColorArray()
		colors[i].resize(resolution)
