@tool
class_name LivePlotLine
extends ColorRect

var resolution: int = 256
@export var color_theme: ColorTheme = ColorTheme.PLAIN
@export_group("Test Input")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var toggle_test_input: bool = false
@export_range(0., 1., 0.0001) var test_input_value: float


@export_group("Value Bracket")
## Top value boundary on the plotted graph
@export var bracket_max: float = 1.
## Bottom value boundary on the plotted graph
@export var bracket_min: float = 0.
## Amount of value sample to be factored for calculating the updated averaged value
## Higher values make the weighted graph smoother; smaller ones will make it approach
## the exact source values.
@export var bracket_avg: int = 64
var bracket_width: float = 1.



var buffer				: PackedVector2Array
var average				: PackedVector2Array
var stored_range		: PackedVector2Array
var stored_range_avg	: PackedVector2Array

var current_max			: float = 0.
var current_max_avg		: float = 0.
var current_min			: float = 0.
var current_min_avg 	: float = 0.

func _ready() -> void:
	
	if not resized.is_connected(on_resized): resized.connect(on_resized)
	
	buffer = PackedVector2Array()
	average = PackedVector2Array()
	stored_range = PackedVector2Array()
	stored_range_avg = PackedVector2Array()
	buffer.resize(resolution)
	average.resize(resolution)
	stored_range.resize(resolution / 2)
	stored_range_avg.resize(resolution / 2)
	for i in resolution:
		buffer[i] = Vector2(float(i) / float(resolution) * size.x, 0.)
		average[i] = buffer[i]

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		if toggle_test_input:
			process_value(clampf(test_input_value, 0., 1.))
	pass	

func process_value(x: float) -> void:
	
	const RANGE_BARS_OFFSET: float = 2.
	
	current_min = buffer[0].y
	current_max = buffer[0].y
	current_min_avg = average[0].y
	current_max_avg = average[0].y
	bracket_width = size.x / float(resolution) * bracket_avg
	var n_avg: float = x
	for i in range(resolution - 1, 0, -1):
		buffer[i] = Vector2(float(i) / float(resolution) * size.x, buffer[i - 1].y)
		average[i] = Vector2(buffer[i].x, average[i - 1].y)
		if i < bracket_avg:
			if buffer[i].y < current_min: current_min = buffer[i].y
			if buffer[i].y > current_max: current_max = buffer[i].y
			if average[i].y < current_min_avg: current_min_avg = average[i].y
			if average[i].y > current_max_avg: current_max_avg = average[i].y
			n_avg += buffer[i].y
	for i in range((resolution / 4) - 1, 0, -1):
		var x_pos: float = bracket_width + i * (size.x - bracket_width) / (float(resolution) / 4.) + RANGE_BARS_OFFSET
		# Top Points of range indicators
		stored_range[i * 2] = Vector2(x_pos, stored_range[2 * (i - 1)].y)
		stored_range_avg[i * 2] = Vector2(x_pos, stored_range_avg[2 * (i - 1)].y)
		# Bottom points of range indicators
		stored_range[i * 2 + 1] = Vector2(x_pos, stored_range[2 * (i - 1) + 1].y)
		stored_range_avg[i * 2 + 1] = Vector2(x_pos, stored_range_avg[2 * (i - 1) + 1].y)
	
	buffer[0] = Vector2(0., (1. - x) * size.y)
	average[0] = Vector2(0., n_avg / float(bracket_avg))
	stored_range[0] = Vector2(bracket_width + RANGE_BARS_OFFSET, current_max)
	stored_range[1] = Vector2(bracket_width + RANGE_BARS_OFFSET, current_min)
	stored_range_avg[0] = Vector2(bracket_width + RANGE_BARS_OFFSET, current_max_avg)
	stored_range_avg[1] = Vector2(bracket_width + RANGE_BARS_OFFSET, current_min_avg)
	
	
	queue_redraw()


func _draw() -> void:
	draw_multiline(stored_range, Color(1., 1., 1., 0.15), 2., false)
	draw_multiline(stored_range_avg, Color(Color.ORANGE.r, Color.ORANGE.g, Color.ORANGE.b, 0.35), 4., false)
	draw_line(
		Vector2(bracket_width, 0.), 
		Vector2(bracket_width, size.y),
		Color(0., 0., 0., 0.4), 1., false
	)
	draw_line(
		Vector2(0., current_max),
		Vector2(bracket_width, current_max),
		Color(0., 0., 0., 0.4), 1., false
	)
	draw_line(
		Vector2(0., current_min),
		Vector2(bracket_width, current_min),
		Color(0., 0., 0., 0.4), 1., false
	)
	
	draw_polyline(average, Color.ORANGE, 1.)
	draw_polyline(buffer, Color.WHITE, 1.)
	

func on_resized() -> void: queue_redraw()



enum ColorTheme {
	PLAIN, GRUVBOX, MIASMA
}

const COLOR_THEMES: Dictionary[ColorTheme, Dictionary] = {
	ColorTheme.PLAIN : {
		
	},
	ColorTheme. GRUVBOX : {
		
	},
	ColorTheme.MIASMA : {
		
	}
}
