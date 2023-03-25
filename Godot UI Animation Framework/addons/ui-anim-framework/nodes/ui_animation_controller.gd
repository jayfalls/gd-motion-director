@tool
class_name UIAnimationController extends Node


# VARIABLES
## Identifier
const is_ui_anim: Object = null

# References
var edited_scene_root: Node

## Values
### Groups
@export var groups: PackedStringArray
@export var unique_nodes: Dictionary # All the unique node paths and their names
@export var grouped_nodes: Dictionary # All the groups and their nodes

## Events
enum MODES {
	SINGLE_GROUP,
	SINGLE_NODE,
	MULTIPLE_GROUPS,
	ALL_GROUPS
}
@export var events: PackedStringArray
@export var unique_animations: Dictionary # All the unique animations and their names
@export var event_animations: Dictionary # All the events and their animations
@export var event_modes: Dictionary # All the events and their group modes
@export var event_groups: Dictionary # All the events and their groups

## Triggers


# INITIALISATION
func _ready():
	_get_configuration_warnings()
	notify_property_list_changed()


# ERROR HANDLING
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	if get_parent() != edited_scene_root:
		warnings.append("UIAnimationController needs to be child of root node")
	return warnings

func _notification(what):
	# Happens when the node is reparented
	if what == NOTIFICATION_PARENTED:
		_get_configuration_warnings()


# UPDATE EDITOR UI
## Hide the export variables from the editor
func _get_property_list():
	var properties: Array[Dictionary] = []
	properties.append({
		"name": "groups",
		"type": TYPE_PACKED_STRING_ARRAY,
		"usage": PROPERTY_USAGE_NO_EDITOR,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": ""
	})
	properties.append({
		"name": "unique_nodes",
		"type": TYPE_DICTIONARY,
		"usage": PROPERTY_USAGE_NO_EDITOR,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": ""
	})
	properties.append({
		"name": "grouped_nodes",
		"type": TYPE_DICTIONARY,
		"usage": PROPERTY_USAGE_NO_EDITOR,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": ""
	})
	return properties


# UPDATE VALUES
## Groups & Nodes
### Modification
func rename_group(old_name: String, new_name: String) -> void:
	var index: int = groups.find(old_name)
	groups[index] = new_name
	var old_node_paths: Array[NodePath] = grouped_nodes[old_name]
	grouped_nodes.erase(old_name)
	grouped_nodes[new_name] = old_node_paths

func rename_node(path: NodePath, new_name: String) -> void:
	unique_nodes[path] = new_name

### Deletion
func remove_group(group_name: String) -> void:
	grouped_nodes.erase(group_name)
	var control_index: int = groups.find(group_name)
	groups.remove_at(control_index)
	_remove_unique_nodes()

func _remove_unique_nodes() -> void:
	# Create a list of all nodes in every group
	var all_grouped_nodes: Array[NodePath]
	for node_array in grouped_nodes.values():
		all_grouped_nodes.append_array(node_array)
	# Create a list of unique nodes from that list
	var all_unique_nodes: Array[NodePath]
	for node in all_grouped_nodes:
		if not node in all_unique_nodes:
			all_unique_nodes.append(node)
	# Remove any unique ssnodes not found
	for node in unique_nodes.keys():
		if not node in all_unique_nodes:
			unique_nodes.erase(node)
