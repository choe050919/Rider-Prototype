extends Control

func _on_ball_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ball_game.tscn")

func _on_vehicle_button_pressed():
	get_tree().change_scene_to_file("res://scenes/vehicle_game.tscn")
