class_name BattleScene
extends Node2D

signal proceed_turn_ended

@export_group("Required Children")
@export var battlers_node: Marker2D
@export var black_screen: MeshInstance2D
@export var effect_sprite: AnimatedSprite2D#
@export var back_button: IconButton
@export var turn_manager: TurnManager
@export var handbook_button: IconButton
@export var hud_manager: BattleHUDManager
@export var wtf_label: RichTextLabel
@export var battler_info: BattlerInfoContainer
@export var preview_color_rect: ColorRect
@export var handbook: Handbook
@export var victory_defeat_container: VictoryDefeatContainer
@export var back_confirm: BackConfirm
@export var battle_animator: BattleAnimator
@export var battle_manager: BattleManager

var _battlers_positions: Array[Vector2]
var battlers: Array[Battler]
var enemy_level_stage_number: int = -1


func _ready() -> void:
	assert(hud_manager and battlers_node and black_screen and effect_sprite and battle_animator 
			and battler_info and battle_manager and victory_defeat_container
			and back_button and handbook_button and handbook and turn_manager 
			and preview_color_rect and wtf_label)
	
	if Global.settings.get("AUDIO").get("MUSIC") == true:
		SoundManager.play_music(Preloader.battle_musics.pick_random())
	
	battlers.resize(GameInfo.MAX_BATTLERS_COUNT)
	_battlers_positions.resize(GameInfo.MAX_BATTLERS_COUNT)
	_battlers_positions[0] = Vector2.RIGHT * Global.SCREEN_WIDTH * 2 / 16
	_battlers_positions[1] = Vector2.RIGHT * Global.SCREEN_WIDTH * 4 / 16
	_battlers_positions[2] = Vector2.RIGHT * Global.SCREEN_WIDTH * 6 / 16
	_battlers_positions[3] = Vector2.RIGHT * Global.SCREEN_WIDTH * 10 / 16
	_battlers_positions[4] = Vector2.RIGHT * Global.SCREEN_WIDTH * 12 / 16
	_battlers_positions[5] = Vector2.RIGHT * Global.SCREEN_WIDTH * 14 / 16
	
	var types: Array[int] = Array(GameInfo.heroes_types + GameInfo.enemies_types, TYPE_INT, &"", null)
	for index in GameInfo.MAX_BATTLERS_COUNT:
		create_battler(index, types[index])
	
	black_screen.move_to_front()
	$"-----TEST-----".hide()
	
	back_button.set_on_press(
			func():
				back_confirm.show()
				get_tree().paused = true
	)
	handbook_button.set_on_press(
			func():
				handbook.show()
	)
	
	preview_color_rect.show()
	
	battler_info.hide()
	
	hud_manager.need_to_proceed_turn.connect(
			func(spell: Spell):
				battle_manager.proceed_turn(spell)
	)
	hud_manager.disappear()
	
	turn_manager.need_to_show_text.connect(show_wtf_label)
	await turn_manager.setup(battlers)
	var tween := create_tween()
	tween.tween_property(
			preview_color_rect, "modulate:a",
			0.0,
			0.5
	)
	tween.tween_callback(
			func():
				preview_color_rect.hide()
				battle_manager.init_turn()
				battle_manager.battle_ended.connect(_on_battle_ended)
	)


func create_battler(index: int, battler_type: int):
	if battler_type == -1 or not (index in range(0, GameInfo.MAX_BATTLERS_COUNT)):
		return
	
	var battler := Battler.create(battler_type, index)
	battler.position = _battlers_positions[index]
	battler.clicked.connect( func(): _on_battler_clicked(battler) )
	battler.hold_started.connect( func(): battler_info.appear(battler.stats) )
	battler.hold_stopped.connect( func(): battler_info.disappear() )
	battler.set_area_inputable(true)
	
	if battler.stats is PlayerBattlerStats:
		battler.name = "Player" + str(index)
	elif battler.stats is EnemyBattlerStats:
		battler.name = "Enemy" + str(index)
	
	battlers_node.add_child(battler)
	battlers[index] = battler


func _on_battler_clicked(battler: Battler):
	battle_manager.set_target_and_action(battler.index)
	
	for b in battlers:
		b.selection_hover.hide()
	
	var current_battler := battle_manager.get_current_battler()
	if current_battler.stats.is_attack_action_group and battle_manager.current_action_type == Battler.ActionTypes.ATTACK:
		for b in get_alive_enemies():
			b.selection_hover.show()
	elif current_battler.stats.is_ally_action_group and battle_manager.current_action_type == Battler.ActionTypes.ALLY:
		for b in get_alive_players():
			b.selection_hover.show()
	else:
		battler.selection_hover.show()
	
	hud_manager.show_action_info(battler)
	current_battler.anim_handler.anim_prepare(battle_manager.current_action_type)


func _on_battle_ended(is_victory: bool):
	var coins: int = 0
	for b in get_enemies():
		var enemy_stats := b.stats as EnemyBattlerStats
		coins += enemy_stats.reward
	var player_coins := int(Global.get_player_coins())
	var penalty: int = coins * (1 - float(get_alive_players().size()) / get_players().size())
	
	victory_defeat_container.victory_defeat_label.text = "ПОБЕДА" if is_victory else "ПОРАЖЕНИЕ"
	if is_victory:
		if Global.get_player_last_enemy_level_reached() == GameInfo.current_enemy_level:
			Global.set_player_last_enemy_level_reached( mini(GameInfo.current_enemy_level + 1, GameInfo.enemy_levels.size()) )
		Global.set_player_coins(player_coins + coins - penalty)
		Global.set_player_enemy_level_stars(
				GameInfo.current_enemy_level,
				maxi( Global.get_player_enemy_level_stars(GameInfo.current_enemy_level), get_alive_players().size() )
		)
		
		victory_defeat_container.result_label.text = (
			"Ваша добыча: " + str(coins) + " монет"
			+ "\n" + ((" (-" + str(penalty) + " за смерть героев)") if penalty > 0 else "")
		)
		SoundManager.stop_music()
		SoundManager.play_sound(Preloader.audio_sfx_victory)
	
	else:
		coins = 3
		Global.set_player_coins(player_coins + coins)
		victory_defeat_container.result_label.text = (
			"Утешительный приз: " + str(coins) + " монет"
		)
		SoundManager.stop_music()
		SoundManager.play_sound(Preloader.audio_sfx_defeat)
	
	var total_coins := Global.get_player_total_coins()
	Global.set_player_total_coins(total_coins + coins)
	
	victory_defeat_container.result_label.text += "\n"


#func _process(delta: float) -> void:
	#$Background/ParallaxBackground/ParallaxLayer2.motion_offset += Vector2.RIGHT * 20 * delta


func get_players() -> Array[Battler]:
	return battlers.filter(
			func(battler: Battler):
				return battler.index < GameInfo.MAX_BATTLERS_COUNT / 2
	)


func get_enemies() -> Array[Battler]:
	return battlers.filter(
		func(battler: Battler):
			return battler.index < GameInfo.MAX_BATTLERS_COUNT / 2
	)


func get_alive_players(is_current_battler_included := true) -> Array[Battler]:
	return get_players().filter(
			func(battler: Battler):
				return battler.is_alive
	)


func get_alive_enemies(is_current_battler_included := true) -> Array[Battler]:
	return get_enemies().filter(
			func(battler: Battler):
				return battler.is_alive and (is_current_battler_included or battler.index != battle_manager.current_battler_index)
	)


func show_all_hud():
	$CanvasLayer/Control/VBox.show()
	var tween := create_tween()
	tween.tween_property(
			$CanvasLayer/Control/VBox, "modulate:a",
			1.0,
			0.25
	)


func hide_all_hud():
	$CanvasLayer/Control/VBox.hide()
	$CanvasLayer/Control/VBox.modulate.a = 0.0
	hud_manager.disappear()


func show_wtf_label(text: String, time: float):
	wtf_label.text = "\n\n[center]" + text + "[/center]"
	wtf_label.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(time)
	tween.tween_property(
			wtf_label, "modulate:a",
			0.0,
			0.5
	)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and not get_tree().paused:
		back_confirm.show()
		get_tree().paused = true
