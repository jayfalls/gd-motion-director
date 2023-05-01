@tool
class_name MotionDirectorSettings extends Resource


# VARIABLES
## Info
const save_path: String = "res://addons/motion-director/data/settings.res"
const motion_file: String =  "res://addons/motion-director/nodes/motion.gd"

## Defaults
### Motions
const default_motion_folder: String = "res://addons/motion-director/data/default_motions/"

## Dynamic Values
@export var motion_folders: PackedStringArray
