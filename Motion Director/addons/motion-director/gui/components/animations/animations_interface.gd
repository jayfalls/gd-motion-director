@tool
extends MotionDirectorInterface


# VARIABLES
## Children
@onready var file_explorer: MotionDirectorInterface = $HBoxContainer/FileExplorer
@onready var motion_creator: MotionDirectorInterface = $HBoxContainer/MotionCreator


# INITIALISATION
func _ready_inject() -> void:
	file_explorer.motion_creator = motion_creator
	motion_creator.file_explorer = file_explorer
	await get_tree().process_frame
	file_explorer.main_panel = main_panel


# POPULATE UI
func _populate_interface() -> void:
	file_explorer._populate_interface()
	motion_creator._populate_interface()


# UI UPDATES
func _update_interface() -> void:
	file_explorer._update_interface()
	motion_creator._update_interface()
