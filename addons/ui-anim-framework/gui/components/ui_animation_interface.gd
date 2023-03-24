@tool
class_name UIAnimationInterface extends MarginContainer


signal repopulate


# VARIABLES
## References
@onready var main_panel: UIAnimationPanel

# POPULATE UI
func _populate_interface() -> void:
	pass


# UI UPDATES
## Toggle between interfaces
func interface_toggle(group: PackedStringArray, index: int) -> void:
	if self[group[index]].visible:
		return
	for variable_ref in group:
		self[variable_ref].hide()
	self[group[index]].show()
