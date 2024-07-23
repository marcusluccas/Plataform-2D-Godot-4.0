extends Area2D

var coins := 1
@onready var coin_sfx = $coin_sfx as AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body) -> void:
	$anim.play("Collect")
	coin_sfx.play()
	"res://sounds/jump_sfx.wav"
	await $collision.call_deferred("queue_free")
	Globals.coins += coins

func _on_anim_animation_finished() -> void:
	if $anim.animation == "Collect":
		queue_free()
