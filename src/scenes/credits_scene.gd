extends Control

var is_clicked := false


func _on_gui_input(event: InputEvent) -> void:
	if event.is_pressed() and not is_clicked:
		is_clicked = true
		Global.switch_to_scene(Preloader.game_scene)
