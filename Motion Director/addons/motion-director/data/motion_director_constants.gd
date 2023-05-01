class_name MotionDirectorConstants extends Node

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
enum ACTION {
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
const DEFAULT_ROOT: Dictionary = {
	"name": "Sequence",
	"index": 0,
	"parent": "none",
	"children": ["./Move To"],
	"val1": null,
	"val2": null,
	"val3": null,
	"property_type": null,
	"property_val": null
}

const DEFAULT_CHAINING: Dictionary = {
	"name": "Sequence",
	"index": 0,
	"parent": ".",
	"children": [],
	"val1": null,
	"val2": null,
	"val3": null,
	"property_type": null,
	"property_val": null
}

const DEFAULT_CONTROL_FLOW: Dictionary = {
	"name": "Wait",
	"index": 0,
	"parent": ".",
	"children": [],
	"val1": 0,
	"val2": null,
	"val3": null,
	"property_type": null,
	"property_val": null
}

const DEFAULT_ACTION: Dictionary = {
	"name": "Move To",
	"index": 0,
	"parent": ".",
	"children": [],
	"val1": 0,
	"val2": 0,
	"val3": null,
	"property_type": 0,
	"property_val": 0
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
