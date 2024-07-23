extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.coins = 0
	Globals.score = 0
	Globals.player_life = 3



func _on_restart_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")


func _on_quit_btn_pressed():
	get_tree().quit()
