@tool
class_name UIAnimation extends Resource

# VARIABLES
## Identifier
const is_anim_file: Object = null

## Special Values
@export var locked: bool = false

## Dynamic Values
### Animation Data
@export var animations: Dictionary = {
	".": UIAnimationConstants.DEFAULT_ROOT.duplicate(),
	"./Move To": UIAnimationConstants.DEFAULT_ACTION.duplicate()
	}
### Property Type
@export var property_type: int = 0
@export var delay_value: float = 1
@export var speed_value: float = 1
@export var curve: Curve
@export var easing_value: float = 5
