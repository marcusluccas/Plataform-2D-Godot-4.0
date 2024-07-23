extends CharacterBody2D


const SPEED = 200.0
const AIR_FRICTION := 0.5

const COIN_SCENE := preload("res://prefabs/coin_rigid.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.

var is_jumping := false
var can_jump := true
var is_hurted := false
var knockback_vector := Vector2.ZERO
var knockback_power := 20
var direction

@export var jump_height := 64
@export var max_time_to_peek := 0.5

var jump_velocity
var gravity
var fall_gravity

@onready var animation := $anim as AnimatedSprite2D
@onready var remote_transform := $remote as RemoteTransform2D
@onready var coyote_timer = $coyote_timer as Timer
@onready var jump_sfx = $coyote_timer/jump_sfx as AudioStreamPlayer
@onready var destroy_sfx = preload("res://prefabs/destroy_sfx.tscn")

signal player_has_died()

func _ready():
	jump_velocity = (jump_height * 2) / max_time_to_peek
	gravity = (jump_height * 2) / pow(max_time_to_peek, 2)
	fall_gravity = gravity * 2

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.x = 0

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and can_jump:
		velocity.y = -jump_velocity
		is_jumping = true
		jump_sfx.play()
	elif is_on_floor():
		is_jumping = false
	
	if velocity.y > 0 or not Input.is_action_pressed("ui_accept"):
		velocity.y += fall_gravity * delta
	else:
		velocity.y += gravity * delta
	
	if is_on_floor() and !can_jump:
		can_jump = true
	elif can_jump and coyote_timer.is_stopped():
		coyote_timer.start()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = lerp(velocity.x, direction * SPEED, AIR_FRICTION)
		animation.scale.x = direction
#		show_trail()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector
		
	_set_state()
	move_and_slide()

	for platforms in get_slide_collision_count():
		var collsion = get_slide_collision(platforms)
		if collsion.get_collider().has_method("has_collided_with"):
			collsion.get_collider().has_collided_with(collsion, self)

func _on_hurtbox_body_entered(body: Node2D) -> void:
	var knockback = Vector2((global_position.x - body.global_position.x) * knockback_power, -200)
	take_demage(knockback)
			
	if body.is_in_group("fireball"):
		body.queue_free()
		
func follow_camera(camera):
	var camera_path = camera.get_path()
	remote_transform.remote_path = camera_path

func take_demage(knockback_force := Vector2.ZERO, duration := 0.25):
	if Globals.player_life > 0:
		Globals.player_life -= 1
	else:
		queue_free()
		emit_signal("player_has_died")
	
	if knockback_force != Vector2.ZERO:
		knockback_vector = knockback_force
		
		var knockback_tween := get_tree().create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		knockback_tween.parallel().tween_property(self, "knockback_vector", Vector2.ZERO, duration)
		animation.modulate = Color(1, 0, 0, 1)
		knockback_tween.parallel().tween_property(animation, "modulate", Color(1, 1, 1, 1), duration)
	
	lose_coins()
	
	is_hurted = true
	await get_tree().create_timer(.3).timeout
	is_hurted = false

func  _input(event):
	if event is InputEventScreenTouch:
			if Input.is_action_just_pressed("ui_accept") and can_jump:
				velocity.y = -jump_velocity
				is_jumping = true
			elif is_on_floor():
				is_jumping = false
				
				
func _set_state():
	var state = "idle"
	
	if !is_on_floor():
		state = "jump"
	elif direction != 0:
		state = "run"
		
	if is_hurted:
		state = "hurt"
	
	if animation.name != state:
		animation.play(state)

func _on_head_collider_body_entered(body):
	if body.has_method("break_sprite"):
		body.hitpoints -= 1
		if body.hitpoints < 0:
			body.break_sprite()
			play_destroy_sfx()
		else:
			body.animation_player.play("hit")
			body.hit_block_sfx.play()
			body.create_coin()


func _on_coyote_timer_timeout():
	can_jump = false

func play_destroy_sfx():
	var sound_sfx = destroy_sfx.instantiate()
	get_parent().add_child(sound_sfx)
	sound_sfx.play()
	await sound_sfx.finished
	sound_sfx.queue_free()

func lose_coins():
	var lost_coins :int = min(Globals.coins, 5)
	$collision.set_deferred("disabled", true)
	Globals.coins -= lost_coins
	for i in lost_coins:
		var coin = COIN_SCENE.instantiate()
		get_parent().call_deferred("add_child", coin)
		coin.global_position = global_position
		coin.apply_impulse(Vector2(randi_range(-200, 200), -250))
	await get_tree().create_timer(0.5).timeout
	$collision.set_deferred("disabled", false)
