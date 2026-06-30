@tool
extends EditorPlugin


func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	pass


func _enter_tree() -> void:
	add_custom_type("LiveHistogram", "ColorRect", preload("res://addons/ecm_monitor_histogram/live_histogram.gd"), preload("res://addons/ecm_monitor_histogram/img/bar_graph.svg"))


func _exit_tree() -> void:
	remove_custom_type("LiveHistogram")
