@tool
class_name AnimateMoveTo extends AnimationAction


# VARIABLES
## Children
var marker: Marker2D
## Options
const position_types: PackedStringArray = [
	"Vector2",
	"Marker",
	"Anchor",
	"Random"
]
const anchors: PackedStringArray = [
	"Center",
	"Left Center",
	"Top Left",
	"Top Center",
	"Top Right",
	"Right Center",
	"Bottom Right",
	"Bottom Center",
	"Bottom Left"
]
## Values
@export_group("Values")
var position: Vector2 = Vector2.ZERO:
	set(value):
		position = value
		_update_action()
var anchor: String = anchors[0]:
	set(value):
		anchor = value
		_update_action()
		notify_property_list_changed()
var position_type: String = position_types[0]:
	set(value):
		position_type = value
		_update_action()
		notify_property_list_changed()


# INTIALISATION
func _ready():
	if not is_instance_valid(marker):
		_determine_children()
	_update_action()
	notify_property_list_changed()

func _determine_children() -> void:
	var children := get_children()
	var names: PackedStringArray
	for child in children:
		if child.name == "Marker":
			marker = child
			return
	_create_marker()

func _create_marker() -> Marker2D:
	var node: Marker2D = Marker2D.new()
	node.name = "Marker"
	node.position = _get_center_screen_editor()
	add_child(node)
	node.set_owner(get_tree().get_edited_scene_root())
	return node


# UPDATE EDITOR UI
func _get_property_list():
	# Determines if the position variable needs to be shown or not
	var position_usage := PROPERTY_USAGE_NO_EDITOR
	if position_type == position_types[0]:
		position_usage = PROPERTY_USAGE_DEFAULT
	# Determines if the anchor variable needs to be shown or not
	var anchor_usage := PROPERTY_USAGE_NO_EDITOR
	if position_type == position_types[2]:
		anchor_usage = PROPERTY_USAGE_DEFAULT
	
	var properties: Array[Dictionary] = []
	properties.append({
		"name": "position_type",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": _get_hint("position_types")
	})
	properties.append({
		"name": "position",
		"type": TYPE_VECTOR2,
		"usage": position_usage,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": ""
	})
	properties.append({
		"name": "anchor",
		"type": TYPE_STRING,
		"usage": anchor_usage,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": _get_hint("anchors")
	})
	
	return properties


# DATA
func get_anchor_position() -> Vector2:
	var size: Vector2 = get_viewport().size
	var anchor_pos: Vector2
	match anchor:
		anchors[0]:
			anchor_pos = _get_center_screen()
		anchors[1]:
			anchor_pos = Vector2(0, size.y / 2)
		anchors[2]:
			anchor_pos = Vector2(0, 0)
		anchors[3]:
			anchor_pos = Vector2(size.x / 2, 0)
		anchors[4]:
			anchor_pos = Vector2(size.x, 0)
		anchors[5]:
			anchor_pos = Vector2(size.x, size.y / 2)
		anchors[6]:
			anchor_pos = Vector2(size.x, size.y)
		anchors[7]:
			anchor_pos = Vector2(size.x / 2, size.y)
		anchors[8]:
			anchor_pos = Vector2(0, size.y)
	return size


# CHANGE VALUES
func _update_action() -> void:
	var action_position: Vector2
	match position_type:
		position_types[0]:
			action_position = position
		position_types[1]:
			action_position = marker.global_position
		position_types[2]:
			action_position = get_anchor_position()
		position_types[3]:
			var size: Vector2 = get_viewport().size
			action_position = Vector2(randf_range(0,size.x),randf_range(0,size.y))
	action = gd.move_to(action_position,duration)
