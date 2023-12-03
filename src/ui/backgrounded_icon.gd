class_name BackgroundedIcon
extends MarginContainer

@export var icon: Texture2D


func _ready() -> void:
	if icon:
		$Icon.texture = icon


func set_icon(icon: Texture2D):
	self.icon = icon
	$Icon.texture = icon
