class_name BattleManager
extends Node

signal coins_reduced
signal battle_ended(is_victory: bool)

@export var battle_scene: BattleScene
var turn_manager: TurnManager
var battle_animator: BattleAnimator
var hud_manager: BattleHUDManager

var is_player_turn: bool = true
var current_battler_index: int
var target_battler_index: int
var current_action_type: Battler.ActionTypes = Battler.ActionTypes.NONE


func _ready() -> void:
	assert(battle_scene)
	turn_manager = battle_scene.turn_manager
	battle_animator = battle_scene.battle_animator
	hud_manager = battle_scene.hud_manager


func init_turn():
	for b in battle_scene.battlers:
		b.set_area_inputable(false)
	
	current_action_type = Battler.ActionTypes.NONE
	current_battler_index = turn_manager.get_current_battler_index()
	if current_battler_index == -1:
		_proceed_end_battle()
		return
	
	var current_battler := battle_scene.battlers[current_battler_index]
	
	current_battler.token_handler.check_tokens(Token.ApplyMoments.ON_TURN_START)
	if not current_battler.is_alive or current_battler.stun_turns > 0:
		if current_battler.stun_turns > 0:
			turn_manager.shift_battler(current_battler.stun_turns)
		await get_tree().create_timer(1.0).timeout
		init_turn()
	
	else:
		if battle_scene.get_alive_players().size() > 0 and battle_scene.get_alive_enemies().size() > 0:
			
			is_player_turn = current_battler_index in _get_player_indexes()
			if is_player_turn:
				hud_manager.appear(current_battler)
				
				var taunters_indexes: Array[int] = []
				for b in battle_scene.enemy_battlers:
					if b.token_handler.get_first_token(Token.Types.TAUNT) != null:
						taunters_indexes.append(b.index)
				
				for b in battle_scene.battlers:
					if b.is_alive:
						if b.index in _get_player_indexes():
							if b.index == current_battler_index:
								b.selection.modulate = Global.TargetColors.CURRENT_BATTLER
								b.selection_hover.modulate = Global.TargetColors.CURRENT_BATTLER
							else:
								b.selection.modulate = Global.TargetColors.ALLY_BATTLER
								b.selection_hover.modulate = Global.TargetColors.ALLY_BATTLER
							b.selection_hover.hide()
							b.selection.show()
							b.set_area_inputable(true)
						elif taunters_indexes.is_empty() or taunters_indexes.has(b.index):
							b.selection.modulate = Global.TargetColors.FOE_BATTLER
							b.selection_hover.modulate = Global.TargetColors.FOE_BATTLER
							b.selection_hover.hide()
							b.selection.show()
							b.set_area_inputable(true)
						else:
							b.selection.hide() # For some reason it's not hidden
					else:
						b.selection.hide() # For some reason it's not hidden
			else:
				for b in battle_scene.battlers:
					b.selection.hide()
					b.selection_hover.hide()
				
				set_target_and_action(AI.pick_target(current_battler, battle_scene.battlers))
				#coins_reduced.emit()
				
				var group: Array[Battler] = []
				if current_battler.stats.is_attack_action_group:
					group = battle_scene.get_alive_players()
				
				battle_animator.animate_enemy_prepare_completed.connect(
						func():
							proceed_turn()
				, CONNECT_ONE_SHOT)
				battle_animator.animate_enemy_prepare(Battler.ActionTypes.ATTACK, group)
		
		else:
			_proceed_end_battle()


func proceed_turn(spell: Spell = null):
	for b in battle_scene.battlers:
		b.set_area_inputable(false)
	
	var current_battler := battle_scene.battlers[current_battler_index]
	var target_battler := battle_scene.battlers[target_battler_index]
	var group: Array[Battler] = []
	
	if is_player_turn:
		if current_action_type == Battler.ActionTypes.ATTACK:
			if current_battler.stats.is_attack_action_group:
				group = battle_scene.get_alive_enemies()
			current_battler.do_attack_action(target_battler, group)
				
		elif current_action_type == Battler.ActionTypes.ALLY:
			if current_battler.stats.is_ally_action_group:
				group = battle_scene.get_alive_players()
			current_battler.do_ally_action(target_battler, group)
		
		if spell:
			spell.apply_effects(current_action_type, target_battler, group)
	
	else:
		if current_action_type == Battler.ActionTypes.ATTACK and current_battler.stats.is_attack_action_group:
			group = battle_scene.get_alive_players()
		elif current_action_type == Battler.ActionTypes.ALLY and current_battler.stats.is_ally_action_group:
			group = battle_scene.get_alive_enemies()
		AI.do_action(current_battler, target_battler, group)
	
	for b in battle_scene.battlers:
		if b.is_alive:
			b.token_handler.update_token_labels()
	
	battle_animator.animate_turn(group)
	await battle_animator.animate_turn_completed
	
	if spell:
		turn_manager.shift_battler(spell.shifted_turns)
		spell.free()
	else:
		turn_manager.shift_battler()
	
	turn_manager.battlers_moved_by_one_tick.connect(init_turn, CONNECT_ONE_SHOT)


func set_target_and_action(index: int):
	assert(index in range(0, battle_scene.battlers.size()))
	target_battler_index = index
	if current_battler_index in _get_player_indexes():
		current_action_type = Battler.ActionTypes.ALLY if target_battler_index in _get_player_indexes() else Battler.ActionTypes.ATTACK
	else:
		current_action_type = Battler.ActionTypes.ATTACK if target_battler_index in _get_player_indexes() else Battler.ActionTypes.ALLY


func get_current_battler() -> Battler:
	return battle_scene.battlers[current_battler_index]


func get_target_battler() -> Battler:
	return battle_scene.battlers[target_battler_index]


func _proceed_end_battle():
	for b in battle_scene.battlers:
		b.selection.hide()
		b.selection_hover.hide()
	var is_victory := not battle_scene.get_alive_players().is_empty()
	battle_animator.animate_battle_end(is_victory)
	battle_ended.emit(is_victory)


func _get_player_indexes() -> Array[int]:
	return [0, 1, 2]
