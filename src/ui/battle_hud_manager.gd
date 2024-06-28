class_name BattleHUDManager
extends CenterContainer

signal need_to_proceed_turn(spell: Spell)

@export var _battle_scene: BattleScene
@export_group("Required Children")
@export var _status_label: RichTextLabel
@export var _spell_label: Label
@export var _reset_spell_button: TextureButton
@export var _rune_buttons: HBoxContainer
@export var _proceed_button: IconButton

var _runes: Array[Rune] = []


func _ready() -> void:
	assert(_battle_scene and _spell_label and _reset_spell_button and _rune_buttons and _proceed_button)
	
	_proceed_button.set_pressable(false)
	_proceed_button.set_on_press(
			func():
				_proceed_button.set_pressable(false)
				_proceed_button.button_pressed = false
				disappear()
				need_to_proceed_turn.emit(Spell.create(_battle_scene.battle_manager.get_current_battler(), _runes))
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


func show_action_info(battler: Battler):
	var current_battler := _battle_scene.battle_manager.get_current_battler()
	current_battler.action_value = 0
	current_battler.damage_modifier = 0
	current_battler.is_stimed = false
	current_battler.miss_chance = 0
	var target_battler := battler
	target_battler.defense_modifier = 0
	target_battler.mirror_modifier = 0
	target_battler.dodge_chance = 0
	target_battler.mirror_modifier = 0
	var action_type := _battle_scene.battle_manager.current_action_type
	if action_type == Battler.ActionTypes.ATTACK:
		current_battler.token_handler.apply_tokens(Token.ApplyMoments.BEFORE_ATTACKING, false)
		current_battler.token_handler.apply_tokens(Token.ApplyMoments.ON_ATTACKING, false)
		if current_battler.index != target_battler.index:
			target_battler.token_handler.apply_tokens(Token.ApplyMoments.BEFORE_GET_ATTACKED, false)
			target_battler.token_handler.apply_tokens(Token.ApplyMoments.ON_GET_ATTACKED, false)
	
	
	_status_label.text = (
		"[center]"
		+ current_battler.stats.battler_name
		+ "\n"
		+ "Действие: " + current_battler.stats.get_action_name(action_type)
		+ "\n"
		+ "Шанс действия: " + str( roundi(current_battler.calc_hit_chance(target_battler) * 100.0) ) + "%"
		+ (
			(
				"\nУрон: " +
				(
					str( roundi(current_battler.calc_damage_value(current_battler.stats.max_damage, target_battler)) )
					if current_battler.is_stimed
					else 
					(
						str( roundi(current_battler.calc_damage_value(current_battler.stats.get_min_damage(), target_battler)) )
						+ "-"
						+ str( roundi(current_battler.calc_damage_value(current_battler.stats.max_damage, target_battler)) )
					)
				)
			)
			if action_type == Battler.ActionTypes.ATTACK
			else ""
		)
		+ "[/center]"
	)
	if _status_label.modulate.a == 0.0:
		create_tween().tween_property(
				_status_label, "modulate:a",
				1.0,
				0.25
		)
	
	_proceed_button.set_pressable(true)


func appear(current_battler: Battler):
	_spell_label.text = ""
	_runes.clear()
	_status_label.modulate.a = 0.0
	
	var player_stats := current_battler.stats as PlayerBattlerStats
	var battler_runes: Array[Rune] = player_stats.runes
	for i in battler_runes.size():
		var rune_button := _rune_buttons.get_child(i) as RuneButton
		rune_button.set_rune(battler_runes[i])
		rune_button.show()
	
	self.show()
	print_debug("showing hud for hero: ", current_battler.index)


func disappear():
	self.hide()
	for button: RuneButton in _rune_buttons.get_children():
		button.hide()
