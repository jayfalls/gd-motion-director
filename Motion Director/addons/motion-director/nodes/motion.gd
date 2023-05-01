@tool
class_name MotionDirector extends Resource

# VARIABLES
## Identifier
const is_motion_file: Object = null

## Special Values
@export var locked: bool = false

## Dynamic Values
### AMotion Data
@export var motions: Dictionary = {
	".": MotionDirectorConstants.DEFAULT_ROOT.duplicate(),
	"./Move To": MotionDirectorConstants.DEFAULT_ACTION.duplicate()
	}
### Property Type
@export var property_type: int = 0
@export var delay_value: float = 1
@export var speed_value: float = 1
@export var curve: Curve
@export var easing_value: float = 5
