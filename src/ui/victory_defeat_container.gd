class_name VictoryDefeatContainer
extends ColorRect

@export var victory_defeat_label: Label
@export var result_label: Label
@export var back_button: Button


func _ready() -> void:
	assert(victory_defeat_label and result_label and back_button)
	self.hide()
	back_button.pressed.connect(
			func():
				Global.switch_to_scene(Preloader.game_scene)
	)
