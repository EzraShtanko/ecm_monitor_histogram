@tool
class_name LiveHistogram
extends ColorRect

const RESOLUTION: int = 256
const shader_CANVAS_HISTOGRAM: Shader = preload("res://addons/ecm_monitor_histogram/canvas_histogram.gdshader")

@export var bracket_max: float = 1.:
	set(v): bracket_max = v;	reconfig.post()
@export var bracket_min: float = 0.:
	set(v): bracket_min = v;	reconfig.post()
@export_range(1, RESOLUTION - 1) var bracket_avg: int = 32

@export var color_nil: Color 	= Color(0.2, 		0.1, 	0., 	0.25):
	set(v): color_nil = v;		reconfig.post()
@export var color_max: Color 	= Color(0.25, 	0.5, 	0.4, 	0.4):
	set(v): color_max = v;		reconfig.post()
@export var color_avg: Color 	= Color(	0.8,	0.1,	0.,		0.65):
	set(v): color_avg = v;		reconfig.post()
@export var color_low: Color	= Color(0.,		0.1,	0.5,	0.4):
	set(v): color_low = v;		reconfig.post()
@export var color_clip: Color	= Color( 1.0,		1.0,	0.6,	0.8):
	set(v): color_clip = v;		reconfig.post()

var buffer: PackedVector2Array

class Reconfig extends mio.Reconfig:
	var x: LiveHistogram
	func _init(_x: LiveHistogram): x = _x
	func _process(f: int = 0xffff) -> void:
		(x.material as ShaderMaterial).set_shader_parameter(&"color_value_nil", 	x.color_nil)
		(x.material as ShaderMaterial).set_shader_parameter(&"color_value_max", 	x.color_max)
		(x.material as ShaderMaterial).set_shader_parameter(&"color_value_avg", 	x.color_avg)
		(x.material as ShaderMaterial).set_shader_parameter(&"color_value_clip", 	x.color_clip)
var reconfig := Reconfig.new(self)


func _ready() -> void:
	var flag_new_shader_required = false
	if not material: flag_new_shader_required = true
	elif not material is ShaderMaterial: flag_new_shader_required = true
	elif not (material as ShaderMaterial).shader == shader_CANVAS_HISTOGRAM: flag_new_shader_required = true
	material = ShaderMaterial.new()
	material.shader = shader_CANVAS_HISTOGRAM
	buffer = PackedVector2Array()
	buffer.resize(RESOLUTION)

func _physics_process(delta: float) -> void:
	reconfig.process()


func log_value(v: float) -> void:
	var w = (v - bracket_min) / bracket_max
	if not is_node_ready(): return
	var avg = w
	for i in range(RESOLUTION - 1, 1, -1):
		buffer[i] = buffer[i - 1]
		if i < bracket_avg: avg += buffer[i]
	avg /= float(bracket_avg)
	buffer[0].x = w
	buffer[0].y = avg
	(material as ShaderMaterial).set_shader_parameter(&"buffer", buffer)
