class_name LiveRidgelineGraph
extends Control

@export var resolution: int = 256
@export var inputs: Array[Vector2]:
	set(v):
		var needs_reconfig: bool = v.size() != inputs.size()
		inputs = v
		if needs_reconfig: reconfig()
@export var range_gradient: Gradient

var buffer: Array[PackedVector2Array]
var colors: Array[PackedColorArray]

func _ready() -> void:
	pass

func reconfig() -> void:
	if not is_node_ready(): await ready
	buffer.clear()
	colors.clear()
	buffer.resize(inputs.size())
	buffer.resize(inputs.size())
	
	for i in inputs.size():
		buffer[i] = PackedVector2Array()
		buffer[i].resize(resolution)
		colors[i] = PackedColorArray()
		colors[i].resize(resolution)
	

func process_values(a: Array[float]) -> void:
	for i in inputs.size():
		for j in range(resolution - 1, 0, -1):
			buffer[i][j] = Vector2(
				size.x / float(resolution) * j,
				buffer[i][j - 1].y
			)
			colors[i][j] = colors[i][j - 1]
		buffer[i][0] = Vector2(0., a[i])
		colors[i][0] = range_gradient.sample(remap(a[i], inputs[i].x, inputs[i].y, 0., 1.))	
	queue_redraw()

func _draw() -> void:
	for i in inputs.size():
		draw_polyline_colors(buffer[i], colors[i], 1, false)
