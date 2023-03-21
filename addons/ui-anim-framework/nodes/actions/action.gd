@tool
class_name AnimationAction extends UIAnimation


# VARIABLES
## References
var nodes: Array[NodePath]
## Values
var action: GDAction
@export_group("Values")
@export var duration: float = 1:
	set(value):
		duration = value
		_update_action()


# ANIMATION
func act() -> void:
	for node in nodes:
		pass
		#action.start(node)


# CHANGE VALUES
func _update_action() -> void:
	pass
