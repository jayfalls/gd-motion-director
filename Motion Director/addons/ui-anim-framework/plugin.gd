@tool
extends EditorPlugin


# VARIABLES
const panel_path: String = "res://addons/ui-anim-framework/gui/panel.tscn"
var panel: UIAnimationPanel


# INTIALISATION
func _init():
	name = "UIAnimFrameworkPluginPlugin"
	print("UI Animation Framework initialized!")


# LOAD/UNLOAD
func _enter_tree():
	# Initialization of the plugin goes here.
	var startup := UIAnimationStartup.new()
	add_child(startup)
	# Load the dock scene and instantiate it.
	panel = preload(panel_path).instantiate()
	panel.editor_file_system = get_editor_interface().get_resource_filesystem()
	panel.interface = get_editor_interface().get_selection()
	scene_changed.connect(panel._editor_scene_changed)
	add_control_to_bottom_panel(panel, "Motion Director")

func _exit_tree():
	# Clean-up of the plugin goes here.
	# Erase the control from the memory.
	remove_control_from_bottom_panel(panel)
	panel.free()
