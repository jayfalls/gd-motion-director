@tool
class_name AnimationTrigger extends UIAnimation


signal triggered


# VARIABLES
var events: PackedStringArray


func trigger() -> void:
	emit_signal("triggered")
