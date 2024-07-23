extends EnemyBase

func _ready():
	wall_detector = $wall_detector
	texture = $texture
	
	anim.animation_finished.connect(kill_ground_enemy)

func _physics_process(delta):
	_apply_gravity(delta)
	movement(delta)
	flip_direction()

