@tool
class_name UIAnimationSettings extends Resource


# VARIABLES
## Info
const save_path: String = "res://addons/ui-anim-framework/data/settings.res"
const anim_file: String =  "res://addons/ui-anim-framework/nodes/ui_animation.gd"

## Defaults
### Animations
const default_animation_folder: String = "res://addons/ui-anim-framework/default_animations/"

## Dynamic Values
@export var animation_folders: PackedStringArray
