extends CharacterBody2D

const FIREBALL := preload("res://prefabs/fireball.tscn")

var move_speed := 50.0
var direction := 1
var health_points := 3
@onready var sprite = $sprite as Sprite2D
@onready var anim = $anim as AnimationPlayer
@onready var fireball_spawn_point = $fireball_spawn_point as Marker2D
@onready var ground_detector = $ground_detector as RayCast2D
@onready var player_detector = $player_detector as RayCast2D
@onready var hurt_sprite = $sprite/hurt_sprite as Sprite2D


enum EnemyState {PATROL, ATTACK, HURT}
var current_state = EnemyState.PATROL
@export var target : CharacterBody2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	match(current_state):
		EnemyState.PATROL : patrol_state()
		EnemyState.ATTACK : attack_state()
	
func patrol_state():
	anim.play("running")
	if is_on_wall():
		flip_enemy()
		
	if not ground_detector.is_colliding():
		flip_enemy()
	
	velocity.x = move_speed * direction
	
	if player_detector.is_colliding():
		_chance_state(EnemyState.ATTACK)
	
	move_and_slide()
	
func attack_state():
	anim.play("shooting")
	if not player_detector.is_colliding():
		_chance_state(EnemyState.PATROL)

func hurt_state():
	anim.play("hurt")
	hurt_sprite.visible = true
	await get_tree().create_timer(0.3).timeout
	hurt_sprite.visible = false
	_chance_state(EnemyState.PATROL)
	if health_points > 0:
		health_points -= 1
	else:
		queue_free()

func _chance_state(state):
	current_state = state

func flip_enemy():
	direction *= -1
	sprite.scale.x *= -1
	player_detector.scale.x  *= -1
	fireball_spawn_point.position.x *= -1

func spawn_fireball():
	var new_fireball = FIREBALL.instantiate()
	if sign(fireball_spawn_point.position.x) == 1:
		new_fireball.set_direction(1)
	else:
		new_fireball.set_direction(-1)
	add_sibling(new_fireball)
	new_fireball.global_position = fireball_spawn_point.global_position


func _on_hitbox_body_entered(body):
	_chance_state(EnemyState.HURT)
	hurt_state()
