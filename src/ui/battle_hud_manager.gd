class_name BattleHUDManager
extends CenterContainer

signal to_select_enemies
signal to_select_allies
signal to_proceed_turn

@export var _spell_label: Label
@export var _reset_spell_button: TextureButton
@export var _runes: HBoxContainer
@export var _proceed_button: IconButton

var spell: Array[Rune] = []


func _ready() -> void:
	assert(_spell_label and _reset_spell_button and _runes and _proceed_button)
	
	_proceed_button.set_enabled(false)
	
	_proceed_button.set_icons(Preloader.texture_arrow_right_black_icon, Preloader.texture_arrow_right_yellow_icon, Preloader.texture_arrow_right_black_icon)
	
	_proceed_button.set_on_press(
			func():
				_spell_label.text = ""
				_proceed_button.set_enabled(false)
				_proceed_button.button_pressed = false
				disappear()
				to_proceed_turn.emit()
	)
	_reset_spell_button.pressed.connect(
			func():
				_spell_label.text = ""
				spell.clear()
	)
	
	for rune_button: RuneButton in _runes.get_children():
		rune_button.pressed.connect(
				func():
					if rune_button.rune.type != Rune.Types.NONE:
						const MAX_CHARS := 25
						var word: String = Rune.WORDS[rune_button.rune.type]
						var text := _spell_label.text
						if text.length() == 0:
							_spell_label.text = word.capitalize()
							spell.append(rune_button.rune)
						elif text.length() + word.length() < MAX_CHARS:
							_spell_label.text += "-" + word
							spell.append(rune_button.rune)
		)
	_spell_label.text = ""


func set_proceed_button_enabled(is_enabled: bool):
	_proceed_button.set_enabled(is_enabled)


func appear(current_battler: Battler):
	self.show()
	var tween := create_tween()
	tween.tween_property(
			self, "modulate:a",
			1.0,
			0.5
	)
	var player_stats := current_battler.stats as PlayerBattlerStats
	var battler_runes: Array[Rune] = player_stats.runes
	for i in battler_runes.size():
		var rune_button := _runes.get_child(i) as RuneButton
		rune_button.set_rune(battler_runes[i])
		rune_button.show()


func disappear():
	self.modulate.a = 0.0
	self.hide()
	for button: RuneButton in _runes.get_children():
		button.hide()
