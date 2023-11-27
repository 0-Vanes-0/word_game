class_name RuneButton
extends TextureButton

@export var rune: Rune
var enabled_function := Callable()


func _ready() -> void:
	$MarginContainer.add_theme_constant_override("margin_top", self.custom_minimum_size.y / 10.0)
	$MarginContainer.add_theme_constant_override("margin_right", self.custom_minimum_size.x / 10.0)
	$MarginContainer.add_theme_constant_override("margin_bottom", self.custom_minimum_size.y / 10.0)
	$MarginContainer.add_theme_constant_override("margin_left", self.custom_minimum_size.x / 10.0)
	if rune and rune.rune_icon:
		$MarginContainer/Rune.texture = rune.rune_icon


func _physics_process(delta: float) -> void:
	if not enabled_function.is_null():
		self.disabled = not enabled_function.call()


func set_rune(rune: Rune):
	self.rune = rune
	if rune.rune_icon:
		$MarginContainer/Rune.texture = rune.rune_icon


func set_enabled_function(function: Callable):
	enabled_function = Callable(function)
