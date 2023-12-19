class_name BackConfirm
extends ColorRect

@export var back_button: Button
@export var hide_button: Button


func _ready() -> void:
	assert(back_button and hide_button)
	self.hide()
	back_button.pressed.connect(
			func():
				get_tree().paused = false
				Global.switch_to_scene(Preloader.game_scene)
	)
	hide_button.pressed.connect(
			func():
				get_tree().paused = false
				self.hide()
	)
