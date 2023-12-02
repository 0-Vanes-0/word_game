class_name BattleHUDManager
extends CenterContainer

signal to_select_enemies
signal to_select_allies
signal to_proceed_turn

@export var _battle_scene: BattleScene
@export var _enemy_target_button: IconButton
@export var _ally_target_button: IconButton
@export var _spell_label: Label
@export var _reset_spell_button: TextureButton
@export var _runes: HBoxContainer
@export var _proceed_button: IconButton

var spell: Array[Rune] = []


func _ready() -> void:
	assert(_battle_scene and _enemy_target_button and _ally_target_button and _spell_label and _reset_spell_button and _runes and _proceed_button)
	
	_proceed_button.set_enabled(false)
	
	_enemy_target_button.set_icons(Preloader.texture_sword_yellow_icon, Preloader.texture_sword_black_icon)
	_ally_target_button.set_icons(Preloader.texture_person_yellow_icon, Preloader.texture_person_black_icon)
	_proceed_button.set_icons(Preloader.texture_arrow_right_black_icon, Preloader.texture_arrow_right_yellow_icon, Preloader.texture_arrow_right_black_icon)
	
	_enemy_target_button.set_on_press(
			func():
				_ally_target_button.button_pressed = false
				to_select_enemies.emit()
	)
	_ally_target_button.set_on_press(
			func():
				_enemy_target_button.button_pressed = false
				to_select_allies.emit()
	)
	_proceed_button.set_on_press(
			func():
				_spell_label.text = ""
				_proceed_button.set_enabled(false)
				_proceed_button.button_pressed = false
				_enemy_target_button.button_pressed = false
				_ally_target_button.button_pressed = false
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


func appear():
	self.show()
	_enemy_target_button.button_pressed = true
	var tween := create_tween()
	tween.tween_property(
			self, "modulate:a",
			1.0,
			0.5
	)
	
	var current_battler := _battle_scene.player_battlers[_battle_scene.current_battler_number]
	var battler_runes: Array[Rune] = (current_battler.stats as PlayerBattlerStats).runes
	for i in battler_runes.size():
		var rune_button := _runes.get_child(i)
		rune_button.set_rune(battler_runes[i])
		rune_button.show()


func disappear():
	self.modulate.a = 0.0
	self.hide()
	for button: RuneButton in _runes.get_children():
		button.hide()
