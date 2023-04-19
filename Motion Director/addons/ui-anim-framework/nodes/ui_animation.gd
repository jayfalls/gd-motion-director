@tool
class_name UIAnimation extends Resource

# VARIABLES
## Identifier
const is_anim_file: Object = null

## Special Values
@export var locked: bool = false

## Dynamic Values
### Animation Data
var test1: Dictionary = {
	"name": "Wait",
	"index": 1,
	"parent": "./Group",
	"children": [],
	"val1": null,
	"val2": null,
	"property_type": null,
	"property_val": null
}
var test2: Dictionary = {
	"name": "Group",
	"index": 0,
	"parent": ".",
	"children": ["./Group/Wait", "./Group/Move To"],
	"val1": null,
	"val2": null,
	"property_type": null,
	"property_val": null
}
var test3: Dictionary = {
	"name": "Move To",
	"index": 0,
	"parent": "./Group",
	"children": [],
	"val1": Vector2(100,250),
	"val2": 2,
	"property_type": "Ease",
	"property_val": -5
}
var test4: Dictionary = {
	"name": "Pause",
	"index": 1,
	"parent": ".",
	"children": [],
	"val1": null,
	"val2": null,
	"property_type": null,
	"property_val": null
}
const root_test: Dictionary = {
	"name": "Sequence",
	"index": 0,
	"parent": "none",
	"children": ["./Pause","./Group"],
	"val1": null,
	"val2": null,
	"property_type": null,
	"property_val": null
}

@export var animations:Dictionary = {
	".": root_test,
	"./Group": test2,
	"./Pause": test4,
	"./Group/Wait": test1,
	"./Group/Move To": test3
	}
### Property Type
@export var property_type: int = 0
@export var delay_value: float = 1
@export var speed_value: float = 1
@export var curve: Curve
@export var easing_value: float = 5
