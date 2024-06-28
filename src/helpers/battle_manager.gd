class_name BattleManager
extends Node

signal battle_ended(is_victory: bool)

@export var _battle_scene: BattleScene
var turn_manager: TurnManager
var battle_animator: BattleAnimator
var hud_manager: BattleHUDManager

var is_player_turn: bool = true
var current_battler_index: int
var target_battler_index: int
var current_action_type: Battler.ActionTypes = Battler.ActionTypes.NONE


func _ready() -> void:
	assert(_battle_scene)
	turn_manager = _battle_scene.turn_manager
	battle_animator = _battle_scene.battle_animator
	hud_manager = _battle_scene.hud_manager


func init_turn():
	for b in _battle_scene.battlers:
		b.set_area_inputable(false)
		b.selection.hide()
		b.selection_hover.hide()
	
	current_battler_index = turn_manager.get_current_battler_index()
	current_action_type = Battler.ActionTypes.NONE
	var current_battler := _battle_scene.battlers[current_battler_index]
	
	if current_battler.stun_turns > 0:
		current_battler.token_handler.check_tokens(Token.ApplyMoments.ON_TURN_START)
		await turn_manager.next_battler()
		init_turn()
	
	else:
		current_battler.token_handler.check_tokens(Token.ApplyMoments.ON_TURN_START)
		if not current_battler.is_alive:
			await turn_manager.next_battler()
			init_turn()
		
		else:
			if _battle_scene.get_alive_players().size() > 0 and _battle_scene.get_alive_enemies().size() > 0: # TODO: need to check if there are more enemies in level
				print_debug("there are alive battlers")
				is_player_turn = current_battler_index in _get_player_indexes()
				if is_player_turn:
					_prepare_player_turn(current_battler)
				else:
					_prepare_enemy_turn(current_battler)
			
			else:
				_proceed_end_battle()


func proceed_turn(spell: Spell = null):
	for b in _battle_scene.battlers:
		b.set_area_inputable(false)
	
	var target_group: Array[Battler] = []
	if target_battler_index != -1:
		var current_battler := _battle_scene.battlers[current_battler_index]
		var target_battler :=  _battle_scene.battlers[target_battler_index]
		print_debug("current_battler_index: ", current_battler_index, " target_battler_index: ", target_battler_index)
		
		if current_battler.stats.is_attack_action_group and current_action_type == Battler.ActionTypes.ATTACK:
			target_group = _battle_scene.get_alive_enemies() if is_player_turn else _battle_scene.get_alive_players()
		elif current_battler.stats.is_ally_action_group and current_action_type == Battler.ActionTypes.ALLY:
			target_group = _battle_scene.get_alive_players() if is_player_turn else _battle_scene.get_alive_enemies()
		else:
			target_group.append(target_battler)
		
		if is_player_turn:
			if current_action_type == Battler.ActionTypes.ATTACK:
				current_battler.do_attack_action(target_group)
			elif current_action_type == Battler.ActionTypes.ALLY:
				current_battler.do_ally_action(target_group)
			
			if spell:
				spell.apply_effects(target_group, current_action_type)
		
		else:
			AI.do_action(current_battler, target_group, current_action_type)
	
	print_debug("action done")
	
	for b in _battle_scene.battlers:
		if b.is_alive:
			b.token_handler.update_token_labels()
	
	await battle_animator.animate_turn(target_group)
	for b in target_group:
		await b.resist_handler.sum_up_resists()
	
	print_debug("animations ended")
	
	if spell:
		spell.free()
	
	await turn_manager.next_battler()
	init_turn()


func set_target_and_action(index: int):
	assert(index in range(-1, _battle_scene.battlers.size()))
	target_battler_index = index
	if current_battler_index in _get_player_indexes():
		current_action_type = Battler.ActionTypes.ALLY if target_battler_index in _get_player_indexes() else Battler.ActionTypes.ATTACK
	else:
		current_action_type = Battler.ActionTypes.ATTACK if target_battler_index in _get_player_indexes() else Battler.ActionTypes.ALLY


func get_current_battler() -> Battler:
	return _battle_scene.battlers[current_battler_index]


func get_target_battler() -> Battler:
	return _battle_scene.battlers[target_battler_index]


func _prepare_player_turn(current_battler: Battler):
	print_debug("preparing hero ", current_battler_index)
	hud_manager.appear(current_battler)
	
	var taunters_indexes: Array[int] = []
	for b in _battle_scene.enemy_battlers:
		if b.token_handler.get_first_token(Token.Types.TAUNT) != null:
			taunters_indexes.append(b.index)
	
	for b in _battle_scene.battlers:
		if b.is_alive:
			if b.index in _get_player_indexes():
				if b.index == current_battler_index:
					b.selection.modulate = Global.TargetColors.CURRENT_BATTLER
					b.selection_hover.modulate = Global.TargetColors.CURRENT_BATTLER
				else:
					b.selection.modulate = Global.TargetColors.ALLY_BATTLER
					b.selection_hover.modulate = Global.TargetColors.ALLY_BATTLER
				b.selection.show()
				b.set_area_inputable(true)
			elif taunters_indexes.is_empty() or b.index in taunters_indexes:
				b.selection.modulate = Global.TargetColors.FOE_BATTLER
				b.selection_hover.modulate = Global.TargetColors.FOE_BATTLER
				b.selection.show()
				b.set_area_inputable(true)


func _prepare_enemy_turn(current_battler: Battler):
	print_debug("preparing enemy ", current_battler_index)
	set_target_and_action( AI.pick_target(current_battler, _battle_scene.battlers) )
	
	if target_battler_index == -1:
		await turn_manager.next_battler()
		init_turn()
		return
	
	var target_group: Array[Battler] = []
	if current_battler.stats.is_attack_action_group and current_action_type == Battler.ActionTypes.ATTACK:
		target_group = _battle_scene.get_alive_players()
	elif current_battler.stats.is_ally_action_group and current_action_type == Battler.ActionTypes.ALLY:
		target_group = _battle_scene.get_alive_enemies()
	else:
		target_group.append(current_battler)
	
	await battle_animator.animate_enemy_prepare(current_action_type, target_group)
	proceed_turn()


func _proceed_end_battle():
	for b in _battle_scene.battlers:
		b.selection.hide()
		b.selection_hover.hide()
	var is_victory := not _battle_scene.get_alive_players().is_empty()
	battle_animator.animate_battle_end(is_victory)
	battle_ended.emit(is_victory)


func _get_player_indexes() -> Array[int]:
	return [0, 1, 2]
