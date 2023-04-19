class_name UIAnimationConstants extends Node

# GDAction Types
enum CHAINING {
	SEQUENCE,
	GROUP,
	IF_ELSE,
	WHILE,
	REPEAT,
	REPEAT_FOREVER
}
enum CONTROL_FLOW {
	WAIT,
	PAUSE,
	RESUME,
	CANCEL
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
	COLORIZE_ALL,
	APPLY_SHADER,
	DO_FUNC,
	DO_FUNC_FOR_TIME,
	HIDE,
	SHOW,
	REMOVE
}

# Animation File 
const SEQUENCE_ROOT: Dictionary = {
	"name": "Sequence",
	"index": 0,
	"parent": "none",
	"children": [],
	"val1": null,
	"val2": null,
	"property_type": null,
	"property_val": null
}
const GROUP_ROOT: Dictionary = {
	"name": "Group",
	"index": 0,
	"parent": "none",
	"children": [],
	"val1": null,
	"val2": null,
	"property_type": null,
	"property_val": null
}

# Property Type
enum PROPERTY_TYPES {
	NONE,
	DELAY,
	SPEED,
	CURVE,
	EASE
}
## Easing Presets
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
