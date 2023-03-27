@tool
class_name UIAnimation extends Resource

# VARIABLES
## Identifier
const is_anim_file: Object = null

## Dynamic Values
### Easing
@export var easing: bool = false
@export var easing_value: float = 5

## Constants
### GDAction Types
enum CHAINING {
	GROUP,
	SEQUENCE,
	REPEAT,
	REPEAT_FOREVER
}

enum CONTROL_FLOW {
	WAIT,
	REVERSED
}

enum ACTIONS {
	MOVE_TO,
	MOVE_TO_X,
	MOVE_TO_Y,
	MOVE_BY,
	MOVE_BY_X,
	MOVE_BY_Y,
	ROTATE_BY,
	ROTATE_TO,
	SCALE_BY,
	SCALE_BY_VECTOR,
	SCALE_TO,
	SCALE_TO_VECTOR,
	FADE_ALPHA_BY,
	FADE_ALPHA_TO,
	COLORIZE,
	COLORIZE_ALL
}
### Easing Presets
const EASING_PRESETS: Dictionary = {
	"Linear": 1,
	"EaseInSine": 1.4,
	"EaseOutSine": -1.4,
	"EaseInOutSine": -1.8,
	"EaseInCubic": 2.2,
	"EaseOutCubic": 0.4,
	"EaseInOutCubic": -3,
	"EaseInQuint": 5,
	"EaseOutQuint": 0.2,
	"EaseInOutQuint": -5
}
