@tool
class_name UIAnimation extends Node


# DATA
## Internal
func _get_hint(variable: String) -> String:
	var hint: String
	for name in self[variable]:
		hint += name + ","
	hint = hint.left(-1)
	return hint

func get_class() -> String:
	return "UIAnimation"

## Display
func _get_settings_screen_size() -> Vector2:
	var size_x: int = ProjectSettings.get_setting("display/window/size/viewport_width")
	var size_y: int = ProjectSettings.get_setting("display/window/size/viewport_height")
	return Vector2(size_x, size_y)

func _get_center_screen_editor() -> Vector2:
	var size: Vector2 = _get_settings_screen_size()
	var center: Vector2 = Vector2(size.x / 2, size.y / 2)
	return center

func _get_center_screen() -> Vector2:
	var size: Vector2 = get_viewport().size
	var center: Vector2 = Vector2(size.x / 2, size.y / 2)
	return center
