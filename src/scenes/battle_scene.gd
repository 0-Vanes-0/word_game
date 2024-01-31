class_name BattleScene
extends Node2D

signal proceed_turn_ended

@export_group("Children")
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

var battlers_positions: Array[Vector2]
var battlers: Array[Battler]
var player_battlers: Array[Battler]
var enemy_battlers: Array[Battler]


func _ready() -> void:
	assert(hud_manager and battlers_node and black_screen and effect_sprite and battle_animator 
			and battler_info and battle_manager and victory_defeat_container
			and back_button and handbook_button and handbook and turn_manager 
			and preview_color_rect and wtf_label)
	
	if Global.settings.get("AUDIO").get("MUSIC") == true:
		SoundManager.play_music(Preloader.battle_musics.pick_random())
	
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
		battler.clicked.connect(func(): _on_battler_clicked(battler))
		battler.hold_started.connect(func(): battler_info.appear(battler.stats))
		battler.hold_stopped.connect(battler_info.disappear)
		battler.set_area_inputable(true)
		
		if battler.stats is PlayerBattlerStats:
			player_battlers.append(battler)
			battler.died.connect(
					func():
						turn_manager.remove_battler(index)
			)
			battler.name = "Player" + str(index)
		else:
			enemy_battlers.append(battler)
			battler.died.connect(
					func():
						turn_manager.remove_battler(index)
			)
			battler.name = "Enemy" + str(index)
		
		battlers_node.add_child(battler)
		battlers.append(battler)
	
	black_screen.move_to_front()
	battlers_node.move_child(effect_sprite, -1) # To remove
	$"-----TEST-----".hide()
	
	back_button.pressed.connect(
			func():
				back_confirm.show()
				get_tree().paused = true
	)
	_update_coins_label()
	handbook_button.pressed.connect(
			func():
				handbook.show()
	)
	
	preview_color_rect.show()
	turn_manager.queue_ready.connect(
			func():
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
							battle_manager.coins_reduced.connect(_update_coins_label)
							battle_manager.battle_ended.connect(_on_battle_ended)
				)
	)
	turn_manager.setup()
	
	battler_info.hide()
	
	hud_manager.to_proceed_turn.connect( 
			func(spell: Spell):
				battle_manager.proceed_turn(spell)
	)
	hud_manager.disappear()


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
	
	hud_manager.on_battler_clicked(battler)
	current_battler.anim_handler.anim_prepare(battle_manager.current_action_type)


func _update_coins_label():
	var coins: int = 0
	#for b in enemy_battlers:
		#var stats := b.stats as EnemyBattlerStats
		#coins += stats.reward
	#coins_counter.set_text(coins)


func _on_battle_ended(is_victory: bool):
	var coins: int = 0
	for b in enemy_battlers:
		var enemy_stats := b.stats as EnemyBattlerStats
		coins += enemy_stats.reward
	var player_coins := int(Global.get_player_coins())
	var penalty: int = coins * (1 - float(get_alive_players().size()) / player_battlers.size())
	
	victory_defeat_container.victory_defeat_label.text = "ПОБЕДА" if is_victory else "ПОРАЖЕНИЕ"
	if is_victory:
		if Global.get_player_last_enemy_level_reached() == GameInfo.current_enemy_level:
			Global.set_player_last_enemy_level_reached( mini(GameInfo.current_enemy_level + 1, GameInfo.enemy_levels.size()) )
		Global.set_player_coins(player_coins + coins - penalty)
		
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
	if get_alive_players().size() < 3:
		victory_defeat_container.result_label.text += "\n" + "Погибшие герои будут возрождены в городе."


#func _process(delta: float) -> void:
	#$Background/ParallaxBackground/ParallaxLayer2.motion_offset += Vector2.RIGHT * 20 * delta


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
