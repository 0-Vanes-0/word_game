class_name IconButton
extends TextureButton

var _on_press := Callable()


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


func set_enabled(is_enabled: bool):
	self.disabled = not is_enabled
	if $CenterContainer/Unpressable.texture != null:
		$CenterContainer/Unpressable.visible = self.disabled

