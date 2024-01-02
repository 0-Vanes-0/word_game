class_name IconButton
extends TextureButton

var _on_press := Callable()


func _ready() -> void:
	$CenterContainer/IconDisabled.show()
	$CenterContainer/IconEnabled.hide()
	
	$CenterContainer/IconEnabled.custom_minimum_size = ceil(Vector2.ONE * self.custom_minimum_size.x * 0.4)
	$CenterContainer/IconDisabled.custom_minimum_size = ceil(Vector2.ONE * self.custom_minimum_size.x * 0.4)
	$CenterContainer/Unpressable.custom_minimum_size = ceil(Vector2.ONE * self.custom_minimum_size.x * 0.4)
	


func _on_button_down() -> void:
	if not self.toggle_mode:
		$CenterContainer/IconEnabled.show()
		$CenterContainer/IconDisabled.hide()
		if not _on_press.is_null():
			_on_press.call()


func _on_button_up() -> void: # not working after pause?
	if not self.toggle_mode:
		$CenterContainer/IconDisabled.show()
		$CenterContainer/IconEnabled.hide()


func _on_toggled(button_pressed: bool) -> void:
	if self.toggle_mode:
		if button_pressed:
			$CenterContainer/IconEnabled.show()
			$CenterContainer/IconDisabled.hide()
			if not _on_press.is_null():
				_on_press.call()
		else:
			$CenterContainer/IconDisabled.show()
			$CenterContainer/IconEnabled.hide()


func set_icons(disabled_icon_texture: Texture2D, enabled_icon_texture: Texture2D, not_pressable_texture: Texture2D = null):
	$CenterContainer/IconDisabled.texture = disabled_icon_texture
	$CenterContainer/IconEnabled.texture = enabled_icon_texture
	if not_pressable_texture != null:
		$CenterContainer/Unpressable.texture = not_pressable_texture


func set_on_press(function: Callable):
	_on_press = Callable(function)


func set_pressable(is_pressable: bool):
	self.disabled = not is_pressable
	if $CenterContainer/Unpressable.texture != null:
		$CenterContainer/Unpressable.visible = self.disabled


