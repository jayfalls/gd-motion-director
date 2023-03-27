@tool
class_name EaseCurveVisualiser extends MarginContainer


# VARIABLES
## Tweakables
@export var box_size: int = 150

## Children 
@onready var panel: PanelContainer = $Panel/PanelContainer
@onready var curve_line := $%EasingCurveLine

## Constants 
const editor_offset: int = 18

## Temp Values
var curve_val: float = 0 # Between -5 & 5

# INITIALISATION
func _ready():
	panel.custom_minimum_size = Vector2(box_size + editor_offset,box_size + editor_offset)
	curve_line.box_size = box_size
	curve_line.editor_offset = editor_offset
	change_curve_value(0)

func change_curve_value(value: float):
	curve_line.change_curve_value(value)
