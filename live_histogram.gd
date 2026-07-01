@tool
class_name LiveHistogram
extends ColorRect

const RESOLUTION: int = 256

const shader_CANVAS_HISTOGRAM		: Shader 			= preload("res://addons/ecm_monitor_histogram/canvas_histogram.gdshader")
const res_DEFAULT_LABEL_SETTINGS	: LabelSettings 	= preload("res://addons/ecm_monitor_histogram/default_label_settings.tres")


const updated_FRAME		:= 0x01 << 0
const updated_COLORS	:= 0x01 << 1
const updated_LABELS	:= 0x01 << 2


@export var label				: String	= "Untitled Monitor":
	set(v): label = v;			reconfig.post(updated_LABELS)
@export var bracket_max			: float = 1.:
	set(v): bracket_max = v;	reconfig.post(updated_LABELS)
@export var bracket_min			: float = 0.:
	set(v): bracket_min = v;	reconfig.post(updated_LABELS)
@export_range(1, RESOLUTION - 1) var bracket_avg: int = 32
@export var custom_label_settings: LabelSettings

@export var color_nil: Color 	= Color(0.2, 		0.1, 	0., 	0.25):
	set(v): color_nil = v;		reconfig.post(updated_COLORS)
@export var color_max: Color 	= Color(0.25, 	0.5, 	0.4, 	0.4):
	set(v): color_max = v;		reconfig.post(updated_COLORS)
@export var color_avg: Color 	= Color(	0.8,	0.1,	0.,		0.65):
	set(v): color_avg = v;		reconfig.post(updated_COLORS)
@export var color_low: Color	= Color(0.,		0.1,	0.5,	0.4):
	set(v): color_low = v;		reconfig.post(updated_COLORS)
@export var color_clip: Color	= Color( 1.0,		1.0,	0.6,	0.8):
	set(v): color_clip = v;		reconfig.post(updated_COLORS)


var label_max	: Label
var label_min	: Label
var label_name	: Label


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
	if not resized.is_connected(on_resized): resized.connect(on_resized)
	if not ready.is_connected(on_ready): ready.connect(on_ready)
	
	var flag_new_shader_required = false
	if not material: flag_new_shader_required = true
	elif not material is ShaderMaterial: flag_new_shader_required = true
	elif not (material as ShaderMaterial).shader == shader_CANVAS_HISTOGRAM: flag_new_shader_required = true
	material = ShaderMaterial.new()
	material.shader = shader_CANVAS_HISTOGRAM
	buffer = PackedVector2Array()
	buffer.resize(RESOLUTION)
		

func on_ready() -> void:
	ready.disconnect(on_ready)
	if not $LabelName:
		label_name = Label.new()
		label_name.name = "LabelName"
		label_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label_name.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		add_child(label_name)
		label_name.owner = self
		label_name.text = label
		label_name.force_update_transform()
		
		label_name.anchor_top = 0.
		label_name.anchor_bottom = 0.
		label_name.anchor_left = 0.65
		label_name.anchor_right = 0.65
		label_name.position = Vector2(size.x * 0.65, 0.)
	elif not label_name:
		label_name = $LabelName
	
	
	if not $LabelMax:
		label_max = Label.new()
		label_max.name = "LabelMax"
		label_max.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label_max.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		add_child(label_max)
		label_max.text = "%5.2f" % bracket_max
		
		label_max.anchor_top = 0.
		label_max.anchor_bottom = 0.
		label_max.anchor_left = 1.
		label_max.anchor_right = 1.
	elif not label_max:
		label_max = $LabelMax
	
	
	if not $LabelMin:
		pass
	elif not label_min:
		label_min = $LabelMin
	
	
	
	for i: Label in [label_name, label_min, label_max]:
		i.label_settings = custom_label_settings if custom_label_settings else res_DEFAULT_LABEL_SETTINGS
	
	
	
func on_resized() -> void: reconfig.post()
	
	

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


func _exit_tree() -> void:
	
	pass
