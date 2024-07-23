extends CharacterBody2D

var move_speed := 50.0
var direction := 1

func _process(delta):
	position.x += direction * move_speed * delta

func set_direction(dir):
	direction = dir
	if dir < 0:
		$anim.flip_h = true
	else:
		$anim.flip_h = false


func _on_notifier_screen_exited():
	queue_free()
