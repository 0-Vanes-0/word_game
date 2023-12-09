class_name BattleAnimator
extends Node

signal animate_turn_completed
signal animate_enemy_prepare_completed

@export var battle_scene: BattleScene
var battle_manager: BattleManager

const ACTION_TIME := 1.0
var _tween: Tween


func _ready() -> void:
	assert(battle_scene)
	battle_manager = battle_scene.battle_manager


func animate_turn(target_group: Array[Battler] = []):
	var current_action_type: Battler.ActionTypes = battle_manager.current_action_type
	
	var current_battler: Battler = battle_scene.battlers[battle_manager.current_battler_index]
	var current_battler_index := int(current_battler.index)
	var current_battler_position := Vector2(current_battler.position)
	var current_battler_scale := Vector2(current_battler.scale)
	var current_battler_offset := Vector2(current_battler.sprite.offset)
	
	var one: Array[Battler] = [ battle_scene.battlers[battle_manager.target_battler_index] ]
	var target_battlers: Array[Battler] = (
			target_group if not target_group.is_empty()
			else one
	)
	var target_battler_indexes: Array[int]
	var target_battler_positions: Array[Vector2]
	var target_battler_scales: Array[Vector2]
	var target_battler_offsets: Array[Vector2]
	
	target_battler_indexes.resize(target_battlers.size())
	target_battler_positions.resize(target_battlers.size())
	target_battler_scales.resize(target_battlers.size())
	target_battler_offsets.resize(target_battlers.size())
	for i in target_battlers.size():
		target_battler_indexes[i] = target_battlers[i].index
		target_battler_positions[i] = target_battlers[i].position
		target_battler_scales[i] = target_battlers[i].scale
		target_battler_offsets[i] = target_battlers[i].sprite.offset
	
	if current_battler_index != target_battler_indexes[0]: # TODO: плохая проверка, надо проверять весь массив, но лучше отдельной функцией
		for b in target_battlers:
			battle_scene.battlers_node.move_child(b, -1)
			b.scale *= 2.0
	battle_scene.battlers_node.move_child(current_battler, -1)
	current_battler.scale *= 2.0
	
	var left_position := Vector2.RIGHT * Global.SCREEN_WIDTH / 3
	var right_position := Vector2.RIGHT * Global.SCREEN_WIDTH * 2 / 3
	var center_position := Vector2.RIGHT * Global.SCREEN_WIDTH / 2
	var group_gap := Vector2.RIGHT * Global.SCREEN_WIDTH * 1 / 8
	
	var black := battle_scene.black_screen
	black.self_modulate.a = 0.5
	
	# ----- ACTION ANIMATION START -----
	
	current_battler.health_bar.hide()
	current_battler.tokens_container.hide()
	current_battler.selection.hide()
	current_battler.selection_hover.hide()
	for b in target_battlers:
		b.health_bar.hide()
		b.tokens_container.hide()
		b.selection.hide()
		b.selection_hover.hide()
	
	current_battler.anim_action(current_action_type)
	if current_battler_index != target_battler_indexes[0]:
		for b in target_battlers:
			b.anim_reaction(current_action_type)
	
	#if effect_type > 0:
		#battle_scene.effect_sprite.offset = (battle_scene.effect_sprite.sprite_frames as MySpriteFrames).separate_offsets[Rune.get_type_string(effect_type)]
		#battle_scene.effect_sprite.position = (
				#(right_position if current_battler_index < target_battler_index 
				#else center_position if current_battler_index == target_battler_index
				#else left_position)
				#+ Vector2.UP * Global.CHARACTER_SIZE.y
		#)
		#battle_scene.battlers_node.move_child(battle_scene.effect_sprite, -1)
		#battle_scene.effect_sprite.show()
		#battle_scene.effect_sprite.play(Rune.get_type_string(effect_type))
	
	
	_tween = _new_tween()
	if current_battler_index != target_battler_indexes[0]:
		_tween.tween_property(
				current_battler, "position",
				left_position if current_battler_index < target_battler_indexes[0] else right_position,
				0.0
		)
		for i in target_battlers.size():
			_tween.tween_property(
					target_battlers[i], "position",
					right_position + group_gap * i if current_battler_index < target_battlers[i].index else left_position,
					0.0
			)
		if current_action_type == Battler.ActionTypes.ATTACK and not _is_attack_ranged(current_battler.type):
			_tween.tween_property(
					current_battler, "position",
					center_position,
					ACTION_TIME
			)
		else:
			_tween.tween_interval(ACTION_TIME)
	else:
		_tween.tween_property(
				current_battler, "position",
				center_position,
				0.0
		)
		_tween.tween_interval(ACTION_TIME)
	
	# ----- ACTION ANIMATION ENDED; RETURNING BATTLERS -----
	
	_tween.tween_property(
			black, "self_modulate:a",
			0.0,
			0.25
	)
	_tween.parallel().tween_property(
			current_battler, "position",
			current_battler_position,
			0.25
	)
	_tween.parallel().tween_property(
			current_battler, "scale",
			current_battler_scale,
			0.25
	)
	_tween.parallel().tween_callback(
			func():
				current_battler.sprite.offset = current_battler_offset
				if current_battler.is_alive:
					current_battler.anim_idle()
				else:
					current_battler.anim_die()
	)
	_tween.tween_callback(
			func():
				if current_battler.is_alive:
					current_battler.health_bar.show()
					current_battler.tokens_container.show()
	)
				
	if current_battler_index != target_battler_indexes[0]:
		for i in target_battlers.size():
			_tween.parallel().tween_property(
					target_battlers[i], "position",
					target_battler_positions[i],
					0.25
			)
			_tween.parallel().tween_property(
					target_battlers[i], "scale",
					target_battler_scales[i],
					0.25
			)
			_tween.parallel().tween_callback(
					func():
						target_battlers[i].sprite.offset = target_battler_offsets[i]
						if target_battlers[i].is_alive:
							target_battlers[i].anim_idle()
						else:
							target_battlers[i].anim_die()
			)
			_tween.tween_callback(
					func():
						if target_battlers[i].is_alive:
							target_battlers[i].health_bar.show()
							target_battlers[i].tokens_container.show()
			)
	
	_tween.tween_callback(
			func():
				battle_scene.battlers_node.move_child(black, -1)
	)
	
	await _tween.finished
	
	# ----- ALL ANIMATIONS ENDED -----
	
	animate_turn_completed.emit()


func animate_enemy_prepare():
	var current_battler: Battler = battle_scene.battlers[battle_manager.current_battler_index]
	var target_battler: Battler = battle_scene.battlers[battle_manager.target_battler_index]
	
	_tween = _new_tween()
	_tween.tween_interval(0.5)
	_tween.tween_callback(
			func():
				current_battler.selection.show()
				current_battler.selection_hover.show()
				current_battler.selection.modulate = Global.TargetColors.CURRENT_BATTLER
				current_battler.selection_hover.modulate = Global.TargetColors.CURRENT_BATTLER
				target_battler.selection.show()
				target_battler.selection_hover.show()
				target_battler.selection.modulate = Global.TargetColors.FOE_BATTLER
				target_battler.selection_hover.modulate = Global.TargetColors.FOE_BATTLER
				
				current_battler.anim_prepare(Battler.ActionTypes.ATTACK)
	)
	_tween.tween_interval(1.0)
	
	await _tween.finished
	
	animate_enemy_prepare_completed.emit()


func animate_battle_end(is_victory: bool):
	battle_scene.victory_defeat_container.modulate.a = 0.0
	var label := battle_scene.victory_defeat_container.get_node("VBox/CenterContainer/VictoryDefeatLabel")
	if label != null:
		label.text = "ПОБЕДА" if is_victory else "ПОРАЖЕНИЕ"
	_tween = _new_tween()
	_tween.tween_interval(2.0)
	_tween.tween_callback(battle_scene.victory_defeat_container.show)
	_tween.tween_property(
			battle_scene.victory_defeat_container, "modulate:a",
			1.0,
			0.5
	)


func _new_tween() -> Tween:
	if _tween:
		_tween.kill()
	return create_tween()


func _is_attack_ranged(type: Battler.Types) -> bool:
	var rangers: Array[Battler.Types] = [
			Battler.Types.MAGE,
			Battler.Types.FIRE_IMP,
	]
	return rangers.has(type)
