extends Line2D
class_name TrailEffect

const MAX_PONTOS := 3000
@onready var trail := Curve2D.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	trail = Curve2D.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	trail.add_point(get_parent().position)
	if trail.get_baked_points().size() > MAX_PONTOS:
		trail.remove_point(0)
	points = trail.get_baked_points()
	
static func create_trail() -> TrailEffect:
	var trail_scene = preload("res://prefabs/trail_effect.tscn")
	return trail_scene.instantiate()

func _on_trail_timer_timeout():
	set_process(false)
	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await fade_tween.finished
	queue_free()
