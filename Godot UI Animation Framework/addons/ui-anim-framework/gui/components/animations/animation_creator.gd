@tool
extends UIAnimationInterface


# VARIABLES
## References
var file_explorer: UIAnimationInterface
## Children
@onready var current_selected_label: Label = $%CurrentSelectedLabel


# UI UPDATES
func _update_interface() -> void:
	_update_selected_anim()

func _update_selected_anim() -> void:
	var selected_anim = file_explorer.selected_anim
	if selected_anim == "":
		current_selected_label.add_theme_color_override("font_color", Color.ORANGE)
		current_selected_label.text = "None"
	else:
		current_selected_label.add_theme_color_override("font_color", Color.GREEN)
		current_selected_label.text = file_explorer.selected_anim_name
