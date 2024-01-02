class_name BattleManager
extends Node

signal coins_reduced
signal battle_ended(is_victory: bool)

@export var battle_scene: BattleScene
var turn_bar: TurnBar
var battle_animator: BattleAnimator
var hud_manager: BattleHUDManager

var is_player_turn: bool = true
var current_battler_index: int
var target_battler_index: int
var current_action_type: Battler.ActionTypes = Battler.ActionTypes.NONE


func _ready() -> void:
	assert(battle_scene)
	turn_bar = battle_scene.turn_bar
	battle_animator = battle_scene.battle_animator
	hud_manager = battle_scene.hud_manager


func init_turn():
	for b in battle_scene.battlers:
		b.set_area_inputable(false)
	
	current_action_type = Battler.ActionTypes.NONE
	current_battler_index = turn_bar.get_current_battler_index()
	
	battle_scene.battlers[current_battler_index].check_tokens(Token.ApplyMoments.ON_TURN_START)
	if not battle_scene.battlers[current_battler_index].is_alive:
		await get_tree().create_timer(1.0).timeout
		init_turn()
	
	else:
		if battle_scene.get_alive_players().size() > 0 and battle_scene.get_alive_enemies().size() > 0:
			
			is_player_turn = current_battler_index in _get_player_indexes()
			if is_player_turn:
				hud_manager.appear(battle_scene.battlers[current_battler_index])
				for b in battle_scene.battlers:
					if b.is_alive:
						if b.index == current_battler_index:
							b.selection.modulate = Global.TargetColors.CURRENT_BATTLER
							b.selection_hover.modulate = Global.TargetColors.CURRENT_BATTLER
						elif b.index in _get_player_indexes():
							b.selection.modulate = Global.TargetColors.ALLY_BATTLER
							b.selection_hover.modulate = Global.TargetColors.ALLY_BATTLER
						else:
							b.selection.modulate = Global.TargetColors.FOE_BATTLER
							b.selection_hover.modulate = Global.TargetColors.FOE_BATTLER
					
						b.selection_hover.hide()
						b.selection.show()
						b.set_area_inputable(true)
			
			else:
				for b in battle_scene.battlers:
					b.selection.hide()
					b.selection_hover.hide()
				
				# Some enemy AI stuff here
				set_target_and_action(battle_scene.get_alive_players().pick_random().index)
				var enemy_stats := battle_scene.battlers[current_battler_index].stats as EnemyBattlerStats
				enemy_stats.reduce_reward()
				coins_reduced.emit()
				
				var group: Array[Battler] = []
				if enemy_stats.is_attack_action_group:
					group = battle_scene.get_alive_players()
				
				battle_animator.animate_enemy_prepare_completed.connect(
						func():
							proceed_turn()
				, CONNECT_ONE_SHOT)
				battle_animator.animate_enemy_prepare(group)
		
		else:
			for b in battle_scene.battlers:
				b.selection.hide()
				b.selection_hover.hide()
			var is_victory := not battle_scene.get_alive_players().is_empty()
			battle_animator.animate_battle_end(is_victory)
			battle_ended.emit(is_victory)


func proceed_turn(spell: Spell = null):
	for b in battle_scene.battlers:
		b.set_area_inputable(false)
	
	var current_battler := battle_scene.battlers[current_battler_index]
	var target_battler := battle_scene.battlers[target_battler_index]
	var group: Array[Battler] = []
	
	if current_action_type == Battler.ActionTypes.ATTACK:
		if current_battler.stats.is_attack_action_group:
			group = battle_scene.get_alive_enemies() if is_player_turn else battle_scene.get_alive_players()
			current_battler.do_attack_action(target_battler, group)
		else:
			current_battler.do_attack_action(target_battler)
			
	elif current_action_type == Battler.ActionTypes.ALLY:
		if current_battler.stats.is_ally_action_group:
			group = battle_scene.player_battlers if is_player_turn else battle_scene.get_alive_enemies()
			current_battler.do_ally_action(target_battler, group)
		else:
			current_battler.do_ally_action(target_battler)
	
	if spell:
		spell.apply_effects(target_battler, group)
		spell.free()
	
	current_battler.update_token_labels()
	if current_battler_index != target_battler_index:
		if group.is_empty():
			target_battler.update_token_labels()
		else:
			for b in group:
				b.update_token_labels()
	
	battle_animator.animate_turn(group)
	await battle_animator.animate_turn_completed
	
	turn_bar.shift_battler()
	init_turn()


func set_target_and_action(index: int):
	assert(index in range(0, battle_scene.battlers.size()))
	target_battler_index = index
	if current_battler_index in _get_player_indexes():
		current_action_type = Battler.ActionTypes.ALLY if target_battler_index in _get_player_indexes() else Battler.ActionTypes.ATTACK
	else:
		current_action_type = Battler.ActionTypes.ATTACK if target_battler_index in _get_player_indexes() else Battler.ActionTypes.ALLY


func _get_player_indexes() -> Array[int]:
	return [0, 1, 2]
