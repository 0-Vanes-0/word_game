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
	if battle_manager.target_battler_index == -1:
		animate_turn_completed.emit()
		return
	
	# ----- HIDING EVERYTHING -----
	
	battle_scene.hide_all_hud()
	
	# ----- PREPARE ANIMATION -----
	
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
	var target_battler_indexes: Array[int] = []
	var target_battler_positions: Array[Vector2] = []
	var target_battler_scales: Array[Vector2] = []
	var target_battler_offsets: Array[Vector2] = []
	
	target_battler_indexes.resize(target_battlers.size())
	target_battler_positions.resize(target_battlers.size())
	target_battler_scales.resize(target_battlers.size())
	target_battler_offsets.resize(target_battlers.size())
	for i in target_battlers.size():
		target_battler_indexes[i] = target_battlers[i].index
		target_battler_positions[i] = target_battlers[i].position
		target_battler_scales[i] = target_battlers[i].scale
		target_battler_offsets[i] = target_battlers[i].sprite.offset
	
	var left_position := Vector2.RIGHT * Global.SCREEN_WIDTH / 3
	var right_position := Vector2.RIGHT * Global.SCREEN_WIDTH * 2 / 3
	var center_position := Vector2.RIGHT * Global.SCREEN_WIDTH / 2
	var group_gap := Vector2.RIGHT * Global.SCREEN_WIDTH * 1 / 8
	
	# ----- ACTION ANIMATION START -----
	
	battle_scene.show_wtf_label(current_battler.stats.get_action_name(current_action_type), ACTION_TIME)
	
	var black := battle_scene.black_screen
	black.self_modulate.a = 0.5
	
	current_battler.health_bar.hide()
	current_battler.tokens_container.hide()
	current_battler.selection.hide()
	current_battler.selection_hover.hide()
	current_battler.coin_counter.hide()
	for b in target_battlers:
		b.health_bar.hide()
		b.tokens_container.hide()
		b.selection.hide()
		b.selection_hover.hide()
		b.coin_counter.hide()
	
	current_battler.anim_handler.anim_action(current_action_type)
	if current_battler_index != target_battler_indexes[0]:
		for b in target_battlers:
			if b.is_alive:
				b.anim_handler.anim_reaction(current_action_type)
			b.move_to_front()
			b.scale *= 2.0
	
	current_battler.move_to_front()
	current_battler.scale *= 2.0
									# to remove:
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
		_tween.tween_callback(
				func():
					current_battler.position = left_position if current_battler_index < target_battler_indexes[0] else right_position
		)
		for i in target_battlers.size():
			_tween.tween_callback(
					func():
						if current_battler_index < target_battlers[i].index:
							target_battlers[i].position = right_position + group_gap * i if target_battlers.size() > 1 else right_position
						else: 
							target_battlers[i].position = left_position - group_gap * (2 - i) if target_battlers.size() > 1 else left_position
			)
		if current_action_type == Battler.ActionTypes.ATTACK and not _is_attack_ranged(current_battler.type, current_battler.anim_handler.action_anim_number):
			_tween.tween_property(
					current_battler, "position",
					center_position,
					ACTION_TIME
			)
		else:
			_tween.tween_interval(ACTION_TIME)
	else:
		_tween.tween_callback(
				func():
					current_battler.position = center_position
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
					current_battler.anim_handler.anim_idle()
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
							target_battlers[i].anim_handler.anim_idle()
			)
	
	_tween.tween_callback(
			func():
				var battlers := battle_scene.battlers
				for i in range(battlers.size()-1, -1, -1):
					if not battlers[i].is_alive:
						battlers[i].move_to_front()
				for i in battlers.size():
					if battlers[i].is_alive:
						battlers[i].move_to_front()
						battlers[i].health_bar.show()
						battlers[i].tokens_container.show()
					if i in [3,4,5]:
						battlers[i].coin_counter.show()
						
					
				black.move_to_front()
				battle_scene.show_all_hud()
	)
	
	await _tween.finished
	
	# ----- ALL ANIMATIONS ENDED -----
	
	animate_turn_completed.emit()


func animate_enemy_prepare(action_type: Battler.ActionTypes, target_group: Array[Battler] = []):
	var current_battler: Battler = battle_manager.get_current_battler()
	var one: Array[Battler] = [ battle_manager.get_target_battler() ]
	var target_battlers: Array[Battler] = (
			target_group if not target_group.is_empty()
			else one
	)
	
	_tween = _new_tween()
	_tween.tween_interval(0.5)
	_tween.tween_callback(
			func():
				current_battler.selection.show()
				current_battler.selection_hover.show()
				current_battler.selection.modulate = Global.TargetColors.CURRENT_BATTLER
				current_battler.selection_hover.modulate = Global.TargetColors.CURRENT_BATTLER
				
				for b in target_battlers:
					b.selection.show()
					b.selection_hover.show()
					b.selection.modulate = Global.TargetColors.FOE_BATTLER
					b.selection_hover.modulate = Global.TargetColors.FOE_BATTLER
				
				current_battler.anim_handler.anim_prepare(action_type)
	)
	_tween.tween_interval(1.0)
	
	await _tween.finished
	
	animate_enemy_prepare_completed.emit()


func animate_battle_end(is_victory: bool):
	var battlers := battle_scene.get_alive_players() if is_victory else battle_scene.get_alive_enemies()
	for b in battlers:
		b.anim_handler.anim_reaction(Battler.ActionTypes.ALLY)
	
	battle_scene.victory_defeat_container.modulate.a = 0.0
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


func _is_attack_ranged(type: Battler.Types, action_anim_number := 0) -> bool:
	var rangers: Array[Battler.Types] = [
			Battler.Types.HERO_MAGE,
			Battler.Types.ENEMY_FIRE_IMP,
			Battler.Types.ENEMY_JINN,
			Battler.Types.BOSS_ONE,
	]
	return rangers.has(type)
