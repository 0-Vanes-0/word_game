class_name RectButton
extends TextureButton

@export var label: Label


func _ready() -> void:
	assert(label)


func set_text_size(size: int):
	label.label_settings.font_size = size
