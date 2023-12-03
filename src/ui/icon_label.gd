class_name IconLabel
extends HBoxContainer

enum Sizes {
	x16, x24, x36, x48, x64
}
const SIZE_VECTORS := {
	Sizes.x16: Vector2.ONE * 16,
	Sizes.x24: Vector2.ONE * 24,
	Sizes.x36: Vector2.ONE * 36,
	Sizes.x48: Vector2.ONE * 48,
	Sizes.x64: Vector2.ONE * 64,
}
@export var icon: Texture2D
@export var icon_size: Sizes = Sizes.x16


func _ready() -> void:
	if icon:
		$Icon.texture = icon


func set_icon(value: Texture2D, size: Sizes):
	$Icon.texture = value
	$Icon.custom_minimum_size = SIZE_VECTORS.get(size)
	self.icon = value