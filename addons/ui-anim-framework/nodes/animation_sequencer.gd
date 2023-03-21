@tool
class_name AnimationSequencer extends UIAnimation


signal updated

# VARIABLES
## Setup/Assignment Variables
@export_category("Setup")
@export var groups: PackedStringArray = ["Default"]:
	set(value):
		groups = value
		_update_groups()
var group: String = groups[0]:
	set(value):
		group = value
		_update_group()
var nodes: Array[NodePath] = []:
	set(value):
		nodes = value
		grouped_nodes[group] = nodes
# All the nodes in grouped format
var grouped_nodes: Dictionary = {}


# SET UP CHILD NODES
func _ready():
	_determine_children()

func _determine_children() -> void:
	var children := get_children()
	var names: PackedStringArray
	for child in children:
		names.append(child.name)
	if not names.has("Events"):
		create_node("Events")
	if not names.has("Triggers"):
		create_node("Triggers")

func create_node(name: String) -> void:
	var node: Node = Node.new()
	node.name = name
	add_child(node)
	node.set_owner(get_tree().get_edited_scene_root())


# UPDATE EDITOR UI
func _get_property_list():
	var properties: Array[Dictionary] = []
	# Assignment
	properties.append({
		"name": "Assignment",
		"type": 0,
		"usage": PROPERTY_USAGE_CATEGORY,
		"hint": 0,
		"hint_string": ''
	})
	properties.append({
		"name": "group",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": _get_hint("groups")
	})
	properties.append({
		"name": "nodes",
		"type": TYPE_ARRAY,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ""
	})
	
	emit_signal("updated")
	return properties

# UPDATE VARIABLES
func _update_groups() -> void:
	# Clear the object dictionary of orphan groups
	var grouped_nodes_copy: Dictionary
	var keys: PackedStringArray = grouped_nodes.keys()
	for name in groups:
		if keys.has(name):
			grouped_nodes_copy[name] = grouped_nodes[name]
	grouped_nodes = grouped_nodes_copy
	
	notify_property_list_changed()

func _update_group() -> void:
	# Updates the nodes variable to reflect the current group
	var keys = grouped_nodes.keys()
	if keys.has(group):
		nodes = grouped_nodes[group]
	else:
		nodes.clear()
	
	notify_property_list_changed()
