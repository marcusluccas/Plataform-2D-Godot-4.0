extends EnemyBase

@onready var spawn_enemy = $spawn_enemy as Marker2D

func _ready():
	spawn_instance = preload("res://actors/cherry.tscn")
	spawn_instance_position = spawn_enemy
	can_spawn = true
	anim.animation_finished.connect(kill_air_enemy)
