class_name BattleHUDManager
extends CenterContainer

signal to_proceed_turn(spell: Spell)

@export var _spell_label: Label
@export var _reset_spell_button: TextureButton
@export var _rune_buttons: HBoxContainer
@export var _proceed_button: IconButton
@export var _old_proceed_button: Button

var _runes: Array[Rune] = []


func _ready() -> void:
	assert(_spell_label and _reset_spell_button and _rune_buttons and _proceed_button and _old_proceed_button)
	
	# TODO: remove this after adding runes and spells v
	#set_proceed_button_pressable(false)
	#_old_proceed_button.toggled.connect(
			#func(toggled_on: bool):
				#if toggled_on:
					#set_proceed_button_pressable(false)
					#_old_proceed_button.set_pressed_no_signal(false)
					#disappear()
					#to_proceed_turn.emit(null)
	#)
	# TODO: remove this after adding runes and spells ^
	
	_proceed_button.set_pressable(false)
	_proceed_button.set_on_press(
			func():
				_proceed_button.set_pressable(false)
				_proceed_button.button_pressed = false
				disappear()
				to_proceed_turn.emit(Spell.create(_runes))
	)
	_reset_spell_button.pressed.connect(
			func():
				_spell_label.text = ""
				_runes.clear()
	)
	
	for rune_button: RuneButton in _rune_buttons.get_children():
		rune_button.pressed.connect(
				func():
					if rune_button.rune.type != Rune.Types.NONE:
						const MAX_CHARS := 25
						var word: String = Rune.WORDS[rune_button.rune.type]
						var text := _spell_label.text
						if text.length() == 0:
							_spell_label.text = word.capitalize()
							_runes.append(rune_button.rune)
						elif text.length() + word.length() < MAX_CHARS:
							_spell_label.text += "-" + word
							_runes.append(rune_button.rune)
		)
	_spell_label.text = ""


func set_proceed_button_pressable(is_pressable: bool):
	_proceed_button.set_pressable(is_pressable)
	# TODO: remove this after adding runes and spells v
	#_old_proceed_button.disabled = not is_pressable
	#_old_proceed_button.text = "Начать ход" if is_pressable else "Выберите цель"
	# TODO: remove this after adding runes and spells ^


func appear(current_battler: Battler):
	_spell_label.text = ""
	_runes.clear()
	
	var player_stats := current_battler.stats as PlayerBattlerStats
	var battler_runes: Array[Rune] = player_stats.runes
	for i in battler_runes.size():
		var rune_button := _rune_buttons.get_child(i) as RuneButton
		rune_button.set_rune(battler_runes[i])
		rune_button.show()
	
	self.show()


func disappear():
	self.hide()
	for button: RuneButton in _rune_buttons.get_children():
		button.hide()
