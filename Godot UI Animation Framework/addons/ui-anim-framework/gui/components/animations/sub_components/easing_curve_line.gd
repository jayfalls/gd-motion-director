@tool
extends Line2D


# VARIABLES
## Temp Values
@export var box_size: int = 150
@export var editor_offset: int = 12
@export var curve_val: float = 0 # Between -5 & 5

# UPDATE
func change_curve_value(value: float):
	curve_val = value
	if curve_val == 0:
		default_color = Color.BLACK
		position = Vector2(0, box_size / 2)
		points = [Vector2(0,0), Vector2(box_size, 0)]
	else:
		default_color = Color.GREEN
		position = Vector2(0, box_size)
		_determine_points()
	
	var real_offset = (editor_offset * 2 / 3) + 1
	position += Vector2(real_offset, real_offset)

#UPDATE
func _determine_points() -> void:
	var vec: PackedVector2Array
	for val in range(0, box_size, 5):
		var mapped_val: float = remap(val, 0, box_size, 0, 1)
		var eased_val: float = ease(mapped_val, curve_val)
		var new_val: int = lerp(0, box_size, eased_val)
		vec.append(Vector2(val, -new_val))
	vec.append(Vector2(box_size,-box_size))
	points = vec
