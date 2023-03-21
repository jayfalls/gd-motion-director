@tool
class_name TriggerWaitFor extends AnimationTrigger


@export var duration: float = 1


func _ready():
	if get_parent().get_class() == "Node":
		wait()
	else:
		get_parent().triggered.connect(wait)


func wait() -> void:
	await get_tree().create_timer(duration).timeout
	trigger()
