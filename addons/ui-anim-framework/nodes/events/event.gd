@tool
class_name AnimationEvent extends UIAnimation


# VARIABLES
## References
var parent: AnimationSequencer
var groups: PackedStringArray
## Options
enum MODES {
	SINGLE_GROUP,
	SINGLE_NODE,
	MULTIPLE_GROUPS,
	ALL_GROUPS,
	ALL_UI
}
## Values
@export_category("Nodes")
@export var mode: MODES = 0:
	set(value):
		mode = value
		notify_property_list_changed()
@export_group("Options")
var group: String
var add_group: bool = false:
	set(value):
		if not groups_affected.has(group):
			groups_affected.append(group)
		notify_property_list_changed()
var groups_affected: PackedStringArray = []
var node: NodePath


# INITIALISATION
func _ready():
	parent = get_parent().get_parent()
	if is_instance_valid(parent):
		parent.updated.connect(update)
	notify_property_list_changed()


# UPDATE EDITOR UI
func _get_property_list():
	var properties: Array[Dictionary] = []
	
	match mode:
		MODES.MULTIPLE_GROUPS:
			properties.append({
				"name": "group",
				"type": TYPE_STRING,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": _get_hint("groups")
			})
			properties.append({
				"name": "add_group",
				"type": TYPE_BOOL,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": ""
			})
			properties.append({
				"name": "groups_affected",
				"type": TYPE_PACKED_STRING_ARRAY,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": _get_hint("groups")
			})
		MODES.SINGLE_GROUP:
			properties.append({
				"name": "group",
				"type": TYPE_STRING,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": _get_hint("groups")
			})
		MODES.SINGLE_NODE:
			properties.append({
				"name": "node",
				"type": TYPE_NODE_PATH,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_NONE,
				"hint_string": ""
			})
	
	return properties


# UPDATE VALUES
func update() -> void:
	if is_instance_valid(parent):
		groups = parent.groups
	notify_property_list_changed()
