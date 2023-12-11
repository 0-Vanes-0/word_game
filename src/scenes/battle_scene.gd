class_name BattleScene
extends Node2D

signal proceed_turn_ended

@export var battlers_node: Marker2D
@export var black_screen: MeshInstance2D
@export var effect_sprite: AnimatedSprite2D#
@export var turn_bar: TurnBar
@export var battler_info: BattlerInfoContainer
@export var hud_manager: BattleHUDManager
@export var victory_defeat_container: MarginContainer
@export var battle_animator: BattleAnimator
@export var battle_manager: BattleManager

var battlers_positions: Array[Vector2]
var battlers: Array[Battler]
var player_battlers: Array[Battler]
var enemy_battlers: Array[Battler]

var current_battler_number: int = -1 # to remove
var target_battler_number: int = -1 # to remove
var current_action_type: Battler.ActionTypes = Battler.ActionTypes.NONE # to remove
var is_players_turn: bool = true # to remove
var is_progressing_enemy_turn: bool = false # to remove


func _ready() -> void:
	assert(hud_manager and battlers_node and black_screen and effect_sprite and battle_animator and battler_info and battle_manager and victory_defeat_container)
	
	hud_manager.disappear()
	
	battlers_positions.resize(GameInfo.MAX_BATTLERS_COUNT)
	battlers_positions[0] = Vector2.RIGHT * Global.SCREEN_WIDTH * 2 / 16
	battlers_positions[1] = Vector2.RIGHT * Global.SCREEN_WIDTH * 4 / 16
	battlers_positions[2] = Vector2.RIGHT * Global.SCREEN_WIDTH * 6 / 16
	battlers_positions[3] = Vector2.RIGHT * Global.SCREEN_WIDTH * 10 / 16
	battlers_positions[4] = Vector2.RIGHT * Global.SCREEN_WIDTH * 12 / 16
	battlers_positions[5] = Vector2.RIGHT * Global.SCREEN_WIDTH * 14 / 16
	
	for index in GameInfo.MAX_BATTLERS_COUNT:
		var battler_type: Battler.Types = GameInfo.battlers_types[index]
		if battler_type == Battler.Types.NONE:
			continue
		
		var battler := Battler.create(battler_type, Battler.get_start_stats(battler_type), index)
		battler.position = battlers_positions[index]
		battler.clicked.connect(_on_battler_clicked.bind(battler))
		battler.hold_started.connect(battler_info.appear.bind(battler.stats))
		battler.hold_stopped.connect(battler_info.disappear)
		battler.set_area_inputable(true)
		
		if index <= 2:
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
	battlers_node.move_child(effect_sprite, -1) # To remove
	
	hud_manager.to_proceed_turn.connect( 
			func():
				battle_manager.proceed_turn()
	)
	battler_info.scale = Vector2.ZERO
	
	turn_bar.setup()
	
	battle_manager.init_turn()
	battle_manager.battle_ended.connect(_on_battle_ended)


func _on_battler_clicked(battler: Battler):
	battle_manager.set_target_and_action(battler.index)
	
	for b in battlers:
		b.selection_hover.hide()
	var current_battler := battlers[battle_manager.current_battler_index]
	if battle_manager.current_action_type == Battler.ActionTypes.ATTACK and current_battler.stats.is_attack_action_group:
		for b in get_alive_enemies():
			b.selection_hover.show()
	elif battle_manager.current_action_type == Battler.ActionTypes.ALLY and current_battler.stats.is_ally_action_group:
		for b in get_alive_players():
			b.selection_hover.show()
	else:
		battler.selection_hover.show()
	
	hud_manager.set_proceed_button_enabled(true)
	current_battler.anim_prepare(battle_manager.current_action_type)


func _on_battle_ended():
	var coins: int = 0
	for b in enemy_battlers:
		var enemy_stats := b.stats as EnemyBattlerStats
		coins += enemy_stats.reward
	
	GameInfo.coins += coins


func _process(delta: float) -> void:
	$Background/ParallaxBackground/ParallaxLayer2.motion_offset += Vector2.RIGHT * 20 * delta


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
