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
@export var icon_texture: Texture2D
@export var icon_size: Sizes = Sizes.x24


static func create() -> IconLabel:
	return Preloader.icon_label.instantiate() as IconLabel


func _ready() -> void:
	if icon_texture:
		set_icon(icon_texture, icon_size)


func set_icon(value: Texture2D, size: Sizes):
	$Icon.texture = value
	$Icon.custom_minimum_size = SIZE_VECTORS.get(icon_size)
	icon_texture = value


func set_text(text: Variant):
	$Label.text = str(text)
