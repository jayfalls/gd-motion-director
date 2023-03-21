@tool
extends EditorPlugin


func _init():
	name = "UIAnimFrameworkPluginPlugin"
	#add_autoload_singleton("BeehaveGlobalMetrics", "res://addons/beehave/metrics/beehave_global_metrics.gd")
	print("UI Animation Framework initialized!")

func _enter_tree():
	pass


func _exit_tree():
	# Clean-up of the plugin goes here.
	pass
