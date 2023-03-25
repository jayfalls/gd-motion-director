@tool
class_name UIAnimationSettings extends Resource


# VARIABLES
## Info
const save_path: String = "res://addons/ui-anim-framework/data/settings.res"
var has_changed: bool = false

## Defaults
### Animations
const default_animation_folder: String = "res://addons/ui-anim-framework/animations/"

## Dynamic
@export var animation_folders: PackedStringArray:
	set(value):
		animation_folders = value
		has_changed = true
