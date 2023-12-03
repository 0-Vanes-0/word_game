class_name BattleAnimator
extends Node

signal animate_turn_completed
signal animate_enemy_prepare_completed

@export var battle_scene: BattleScene
const ACTION_TIME := 1.0
var _tween: Tween


func _ready() -> void:
	assert(battle_scene)


func animate_turn(some_number: int = -1, effect_type: Rune.Types = Rune.Types.NONE):
	var current_action_type: Battler.ActionTypes = battle_scene.current_action_type
	
	var current_battler: Battler = battle_scene.battlers[battle_scene.current_battler_number]
	var current_battler_index := int(current_battler.index)
	var current_battler_position := Vector2(current_battler.position)
	var current_battler_scale := Vector2(current_battler.scale)
	var current_battler_offset := Vector2(current_battler.sprite.offset)
	
	var target_battler: Battler = battle_scene.battlers[battle_scene.target_battler_number]
	var target_battler_index := int(target_battler.index)
	var target_battler_position := Vector2(target_battler.position)
	var target_battler_scale := Vector2(target_battler.scale)
	var target_battler_offset := Vector2(target_battler.sprite.offset)
	
	if current_battler_index != target_battler_index:
		battle_scene.battlers_node.move_child(target_battler, -1)
		target_battler.scale *= 2.0
	battle_scene.battlers_node.move_child(current_battler, -1)
	current_battler.scale *= 2.0
	
	var left_position := Vector2.RIGHT * Global.SCREEN_WIDTH / 3
	var right_position := Vector2.RIGHT * Global.SCREEN_WIDTH * 2 / 3
	var center_position := Vector2.RIGHT * Global.SCREEN_WIDTH / 2
	
	var black := battle_scene.black_screen
	black.self_modulate.a = 0.5
	
	# ----- ACTION ANIMATION START -----
	
	current_battler.health_bar.hide()
	target_battler.health_bar.hide()
	current_battler.anim_action(current_action_type)
	if current_battler_index != target_battler_index:
		target_battler.anim_reaction(current_action_type)
	
	if effect_type > 0:
		battle_scene.effect_sprite.offset = (battle_scene.effect_sprite.sprite_frames as MySpriteFrames).separate_offsets[Rune.get_type_string(effect_type)]
		battle_scene.effect_sprite.position = (
				(right_position if current_battler_index < target_battler_index 
				else center_position if current_battler_index == target_battler_index
				else left_position)
				+ Vector2.UP * Global.CHARACTER_SIZE.y
		)
		battle_scene.battlers_node.move_child(battle_scene.effect_sprite, -1)
		battle_scene.effect_sprite.show()
		battle_scene.effect_sprite.play(Rune.get_type_string(effect_type))
	
	
	_tween = _new_tween()
	if current_battler_index != target_battler_index:
		_tween.tween_property(
				current_battler, "position",
				left_position if current_battler_index < target_battler_index else right_position,
				0.0
		)
		_tween.tween_property(
				target_battler, "position",
				right_position if current_battler_index < target_battler_index else left_position,
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
	
	if some_number >= 0:
		battle_scene.action_number_label.text = str(some_number)
		battle_scene.action_number_label.show()
		battle_scene.action_number_label.position = (
				(right_position if current_battler_index < target_battler_index 
				else center_position if current_battler_index == target_battler_index
				else left_position)
				+ Vector2.UP * Global.CHARACTER_SIZE.y
				- battle_scene.action_number_label.size / 2
		)
		battle_scene.action_number_label.modulate = (
				Global.TargetColors.FOE_BATTLER if current_action_type == Battler.ActionTypes.ATTACK
				else Global.TargetColors.ALLY_SELF_BATTLER
		)
		battle_scene.battlers_node.move_child(battle_scene.action_number_label, -1)
		_tween.parallel().tween_property(
				battle_scene.action_number_label, "position",
				battle_scene.action_number_label.position + Vector2.UP * Global.CHARACTER_SIZE.y,
				ACTION_TIME
		).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
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
				battle_scene.effect_sprite.hide()
				battle_scene.action_number_label.hide()
	)
	if current_battler_index != target_battler_index:
		_tween.parallel().tween_property(
				target_battler, "position",
				target_battler_position,
				0.25
		)
		_tween.parallel().tween_property(
				target_battler, "scale",
				target_battler_scale,
				0.25
		)
		_tween.parallel().tween_callback(
				func():
					target_battler.sprite.offset = target_battler_offset
					if target_battler.is_alive:
						target_battler.anim_idle()
					else:
						target_battler.anim_die()
		)
	_tween.tween_callback(
			func():
				battle_scene.battlers_node.move_child(black, -1)
	)
	
	await _tween.finished
	
	# ----- ALL ANIMATIONS ENDED -----
	
	animate_turn_completed.emit()


func animate_enemy_prepare():
	var current_battler: Battler = battle_scene.battlers[battle_scene.current_battler_number]
	var target_battler: Battler = battle_scene.battlers[battle_scene.target_battler_number]
	
	_tween = _new_tween()
	_tween.tween_interval(0.5)
	_tween.tween_callback(
			func():
				battle_scene.hud_manager.to_select_enemies.emit()
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
