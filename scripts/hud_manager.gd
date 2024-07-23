extends Control

@onready var coins_counter = $container/coins_container/coins_counter as Label
@onready var timer_counter = $container/timer_container/timer_counter as Label
@onready var score_counter = $container/score_container/score_counter as Label
@onready var life_counter = $container/life_container/life_counter as Label
@onready var clock_timer = $clock_timer

var minutes = 0
var secunds = 0
@export_range(0, 5) var default_minutes := 1
@export_range(0, 59) var default_secunds := 0

signal time_is_up

# Called when the node enters the scene tree for the first time.
func _ready():
	coins_counter.text = str("%04d" % Globals.coins)
	score_counter.text = str("%06d" % Globals.score)
	life_counter.text = str("%02d" % Globals.player_life)
	timer_counter.text = str("%02d" % default_minutes) + ":" + str("%02d" % default_secunds)
	reset_clock_timer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	coins_counter.text = str("%04d" % Globals.coins)
	score_counter.text = str("%06d" % Globals.score)
	life_counter.text = str("%02d" % Globals.player_life)
	
	if minutes == 0 && secunds == 0:
		emit_signal("time_is_up")

func _on_clock_timer_timeout():
	if secunds == 0:
		if minutes > 0:
			minutes -= 1
			secunds = 60
	secunds -= 1
	
	timer_counter.text = str("%02d" % minutes) + ":" + str("%02d" % secunds)

func reset_clock_timer():
	minutes = default_minutes
	secunds = default_secunds
