@tool
extends UIAnimationInterface


# VARIABLES
## Children
@onready var file_explorer: UIAnimationInterface = $HBoxContainer/FileExplorer
@onready var animation_creator: UIAnimationInterface = $HBoxContainer/AnimationCreator


# INITIALISATION
func _ready_inject() -> void:
	file_explorer.animation_creator = animation_creator
	animation_creator.file_explorer = file_explorer
	await get_tree().process_frame
	file_explorer.main_panel = main_panel


# POPULATE UI
func _populate_interface() -> void:
	file_explorer._populate_interface()
	animation_creator._populate_interface()


# UI UPDATES
func _update_interface() -> void:
	file_explorer._update_interface()
	animation_creator._update_interface()
