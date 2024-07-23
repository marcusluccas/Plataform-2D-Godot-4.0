extends Area2D

@onready var collision = $collision
@onready var spikes = $spikes
 
# Called when the node enters the scene tree for the first time.
func _ready():
	collision.shape.size = spikes.get_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.name == "player" && body.has_method("take_demage"):
		body.take_demage(Vector2(0, -250))
