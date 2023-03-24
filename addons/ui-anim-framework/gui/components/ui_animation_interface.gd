@tool
class_name UIAnimationInterface extends MarginContainer


signal repopulate


# VARIABLES
## References
@onready var main_panel: UIAnimationPanel


# POPULATE/UPDATE UI
func update_ui() -> void:
	_populate_interface()
	_update_interface()

func _populate_interface() -> void:
	pass

func _update_interface() -> void:
	pass

## Toggle between interfaces
func interface_toggle(group: PackedStringArray, index: int) -> void:
	if self[group[index]].visible:
		return
	for variable_ref in group:
		self[variable_ref].hide()
	self[group[index]].show()
