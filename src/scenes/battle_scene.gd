class_name BattleScene
extends Node2D

signal proceed_turn_ended

@export var battlers_node: Marker2D
@export var black_screen: MeshInstance2D
@export var effect_sprite: AnimatedSprite2D
@export var turn_bar: TurnBar
@export var battler_info: BattlerInfoContainer
@export var hud_manager: BattleHUDManager
@export var battle_animator: BattleAnimator

var battlers_positions: Array[Vector2]
var battlers: Array[Battler]
var player_battlers: Array[Battler]
var enemy_battlers: Array[Battler]

var current_battler_number: int = -1
var target_battler_number: int = -1
var current_action_type: Battler.ActionTypes = Battler.ActionTypes.NONE
var is_players_turn: bool = true
var is_progressing_enemy_turn: bool = false


func _ready() -> void:
	assert(hud_manager and battlers_node and black_screen and effect_sprite and battle_animator and battler_info)
	
	hud_manager.hide()
	
	battlers_positions.resize(GameInfo.MAX_BATTLERS_COUNT)
	battlers_positions[0] = Vector2.RIGHT * Global.SCREEN_WIDTH * 2 / 16
	battlers_positions[1] = Vector2.RIGHT * Global.SCREEN_WIDTH * 4 / 16
	battlers_positions[2] = Vector2.RIGHT * Global.SCREEN_WIDTH * 6 / 16
	battlers_positions[3] = Vector2.RIGHT * Global.SCREEN_WIDTH * 10 / 16
	battlers_positions[4] = Vector2.RIGHT * Global.SCREEN_WIDTH * 12 / 16
	battlers_positions[5] = Vector2.RIGHT * Global.SCREEN_WIDTH * 14 / 16
	
	for index in GameInfo.MAX_BATTLERS_COUNT:
		var battler_type: Battler.Types = GameInfo.battlers_types[index]
		var battler := Battler.create(battler_type, Battler.get_start_stats(battler_type), index)
		battler.position = battlers_positions[index]
		battler.clicked.connect(_on_battler_clicked.bind(battler))
		battler.hold_started.connect(battler_info.appear.bind(battler.stats))
		battler.hold_stopped.connect(battler_info.disappear)
		battler.set_area_inputable(true)
		
		if index < 3:
			player_battlers.append(battler)
			battler.died.connect(
					func():
						turn_bar.remove_battler(index)
			)
			battler.name = "Player" + str(index)
		else:
			enemy_battlers.append(battler)
			battler.died.connect(
					func():
						turn_bar.remove_battler(index)
			)
			battler.name = "Enemy" + str(index)
		battlers_node.add_child(battler)
		battlers.append(battler)
	
	battlers_node.move_child(black_screen, -1)
	battlers_node.move_child(effect_sprite, -1)
	
	hud_manager.to_select_enemies.connect(
			func():
				reset_all_selections()
				show_current_selection()
				if is_players_turn:
					for eb in enemy_battlers:
						if eb.is_alive:
							eb.selection.show()
							eb.selection.modulate = Global.TargetColors.FOE_BATTLER
							eb.selection_hover.modulate = Global.TargetColors.FOE_BATTLER
							eb.is_clickable = true
				
				current_action_type = Battler.ActionTypes.ATTACK
	)
	hud_manager.to_select_allies.connect(
			func():
				reset_all_selections()
				show_current_selection()
				for i in player_battlers.size():
					if current_battler_number != i:
						var ab := player_battlers[i]
						ab.selection.show()
						ab.selection.modulate = Global.TargetColors.ALLY_SELF_BATTLER
						ab.selection_hover.modulate = Global.TargetColors.ALLY_SELF_BATTLER
					player_battlers[i].is_clickable = true
				
				current_action_type = Battler.ActionTypes.ALLY
	)
	hud_manager.to_proceed_turn.connect(
			func():
				for b in battlers:
					b.set_area_inputable(false)
				reset_all_selections()
				
				var spell: Array[Rune] = hud_manager.spell
				var runes_counter := {}

				for rune in spell:
					if runes_counter.has(rune.type):
						runes_counter[rune.type] += 1
					else:
						runes_counter[rune.type] = 1
				
				var most_common_rune_type := 0
				var max_count := 0
				for key in runes_counter.keys():
					if runes_counter.get(key) > max_count:
						most_common_rune_type = key
						max_count = runes_counter.get(key)
				
				
				
				var current_battler := battlers[current_battler_number]
				var target_battler := battlers[target_battler_number]
				var action_values: Array[int] = []
				if current_action_type == Battler.ActionTypes.ATTACK:
					var damage := int(current_battler.stats.get_damage_value())
					
					var shield_token: Token = target_battler.get_first_token(Token.Types.SHIELD)
					if shield_token != null:
						action_values.resize(2)
						action_values[0] = damage
						action_values[1] = shield_token.apply_token_effect(damage)
						target_battler.stats.adjust_health(- action_values[1])
					else:
						action_values.resize(1)
						action_values[0] = damage
						target_battler.stats.adjust_health(- action_values[0])
					
					if most_common_rune_type == Rune.Types.FIRE:
						target_battler.add_token(Token.Types.FIRE)
				
				elif current_action_type == Battler.ActionTypes.ALLY:
					#if current_battler.type == Battler.Types.KNIGHT:
						target_battler.add_token(Token.Types.SHIELD)
				
				hud_manager.spell.clear()
				
				
				
				battle_animator.animate_turn(most_common_rune_type, action_values)
				await battle_animator.animate_turn_completed
				
				turn_bar.shift_battler()
				current_battler_number = turn_bar.get_current_battler_index()
				
				is_players_turn = current_battler_number in [0, 1, 2]
				if is_players_turn:
					for b in battlers:
						b.set_area_inputable(true)
					hud_manager.appear()
				
				proceed_turn_ended.emit()
	)
	hud_manager.appear()
	battler_info.scale = Vector2.ZERO
	
	turn_bar.setup()
	turn_bar.battlers_moved_by_one_tick.connect(_on_battlers_moved_by_one_tick)
	current_battler_number = turn_bar.get_current_battler_index()
	
	hud_manager.to_select_enemies.emit()


func _on_battler_clicked(battler: Battler):
	hide_selection_hovers()
	battler.selection_hover.show() # TODO: check selection
	target_battler_number = battler.index # TODO: check selection
	hud_manager.set_proceed_button_enabled(true)
	battlers[current_battler_number].anim_prepare(current_action_type)


func _on_battlers_moved_by_one_tick():
	for b in battlers:
		b.check_tokens(Token.ApplyMoments.ON_TICK)
		b.adjust_all_tokens()


func _process(delta: float) -> void:
	$Background/ParallaxBackground/ParallaxLayer2.motion_offset += Vector2.RIGHT * 20 * delta


func _physics_process(delta: float) -> void:
	if not is_players_turn and not is_progressing_enemy_turn:
		if not get_alive_enemies().is_empty() and not get_alive_players().is_empty():
			is_progressing_enemy_turn = true
			
			target_battler_number = get_alive_players().pick_random().index
			
			battle_animator.animate_enemy_prepare_completed.connect(
					func():
						hud_manager.to_proceed_turn.emit()
						await proceed_turn_ended
						is_progressing_enemy_turn = false
			, CONNECT_ONE_SHOT)
			battle_animator.animate_enemy_prepare()
		else:
			Global.switch_to_scene(Preloader.game_scene) # TODO: bad code here


func reset_all_selections():
	for i in battlers.size():
		battlers[i].is_clickable = false
		if battlers[i].is_alive:
			battlers[i].anim_idle()
		battlers[i].selection.hide()
		battlers[i].selection_hover.hide()
		battlers[i].selection.modulate = Color.WHITE
		battlers[i].selection_hover.modulate = Color.WHITE


func show_current_selection():
	battlers[current_battler_number].selection_hover.hide()
	battlers[current_battler_number].selection_hover.modulate = Global.TargetColors.CURRENT_BATTLER
	battlers[current_battler_number].selection.show()
	battlers[current_battler_number].selection.modulate = Global.TargetColors.CURRENT_BATTLER


func hide_selection_hovers():
	for b in battlers:
		b.selection_hover.hide()


func get_alive_players() -> Array[Battler]:
	return player_battlers.filter(
			func(battler: Battler):
				return battler.is_alive 
	)

	
func get_alive_enemies() -> Array[Battler]:
	return enemy_battlers.filter(
			func(battler: Battler):
				return battler.is_alive 
	)


func _on_back_button_pressed() -> void:
	Global.switch_to_scene(Preloader.game_scene)
