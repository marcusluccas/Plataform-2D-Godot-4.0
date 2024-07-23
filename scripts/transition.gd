extends CanvasLayer

@onready var color_rect = $color_rect as ColorRect

func _ready():
	show_new_scene()

func chance_scene(path, delay = 2.5):
	var scene_transition = get_tree().create_tween()
	scene_transition.tween_property(color_rect, "threshold", 1.0, 0.5).set_delay(delay)
	await scene_transition.finished
	assert(get_tree().change_scene_to_file(path) == OK)

func show_new_scene():
		var show_transition = get_tree().create_tween()
		show_transition.tween_property(color_rect, "threshold", 0.0, 0.5).from(1.0)
