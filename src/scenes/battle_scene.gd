class_name BattleScene
extends Node2D

enum ActionTypes {
	NONE = 0, ATTACK = 1, ALLY = 2
}

signal action_animation_ended

@export_group("Children")
@export var battlers_node: Marker2D
@export var enemy_target_button: IconButton
@export var ally_target_button: IconButton
@export var proceed_button: IconButton
@export var black_screen: MeshInstance2D
@export var hud: Control

var battlers_positions: Array[Vector2]
var battlers: Array[Battler]
var player_battlers: Array[Battler]
var enemy_battlers: Array[Battler]

var current_battler_number: int = -1
var target_battler_number: int = -1
var current_action_type: ActionTypes = ActionTypes.NONE
var is_players_turn: bool = true
var is_progressing_enemy_turn: bool = false


func _ready() -> void:
	assert(battlers_node and enemy_target_button and ally_target_button and proceed_button and black_screen and hud)
	
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
		
		battlers_node.add_child(battler)
		battlers.append(battler)
		if index < 3:
			player_battlers.append(battlers[index])
		else:
			enemy_battlers.append(battlers[index])
	battlers_node.move_child(black_screen, -1)
	
	enemy_target_button.set_icons(Preloader.texture_sword_yellow_icon, Preloader.texture_sword_black_icon)
	ally_target_button.set_icons(Preloader.texture_person_yellow_icon, Preloader.texture_person_black_icon)
	proceed_button.set_icons(Preloader.texture_arrow_right_black_icon, Preloader.texture_arrow_right_yellow_icon, Preloader.texture_arrow_right_black_icon)
	proceed_button.set_enabled(false)
	
	enemy_target_button.set_on_press(
			func():
				reset_all_selections()
				show_current_selection()
				if is_players_turn:
					for eb in enemy_battlers:
						eb.selection.show()
						eb.selection.modulate = Global.TargetColors.FOE_BATTLER
						eb.selection_hover.modulate = Global.TargetColors.FOE_BATTLER
						eb.set_area_clickable(true)
				
				current_action_type = ActionTypes.ATTACK
	)
	ally_target_button.set_on_press(
			func():
				reset_all_selections()
				show_current_selection()
				for i in player_battlers.size():
					var ab := player_battlers[i]
					ab.selection.show()
					ab.selection.modulate = Global.TargetColors.ALLY_SELF_BATTLER
					ab.selection_hover.modulate = Global.TargetColors.ALLY_SELF_BATTLER
					ab.set_area_clickable(true)
				
				current_action_type = ActionTypes.ALLY
	)
	proceed_button.set_on_press(
			func():
				proceed_button.set_enabled(false)
				proceed_button.button_pressed = false
				enemy_target_button.button_pressed = false
				ally_target_button.button_pressed = false
				reset_all_selections()
				
				battlers[current_battler_number].anim_action(current_action_type)
				
				var current_battler_orig_index := battlers[current_battler_number].index
				var current_battler_orig_position := battlers[current_battler_number].position
				var current_battler_orig_scale := battlers[current_battler_number].scale
				battlers_node.move_child(battlers[current_battler_number], -1)
				battlers[current_battler_number].scale *= 2.0
				
				var target_battler_orig_index: int
				var target_battler_orig_position: Vector2
				var target_battler_orig_scale: Vector2
				if current_battler_number != target_battler_number:
					target_battler_orig_index = battlers[target_battler_number].index
					target_battler_orig_position = battlers[target_battler_number].position
					target_battler_orig_scale = battlers[target_battler_number].scale
					battlers_node.move_child(battlers[target_battler_number], -2)
					battlers[target_battler_number].scale *= 2.0
				
				var left_position := Vector2.RIGHT * Global.SCREEN_WIDTH / 3
				var right_position := Vector2.RIGHT * Global.SCREEN_WIDTH * 2 / 3
				var center_position := Vector2.RIGHT * Global.SCREEN_WIDTH / 2
				
				hud.hide()
				black_screen.self_modulate.a = 0.5
				
				var anon_tween := create_tween()
				if current_battler_number != target_battler_number:
					anon_tween.tween_property(
							battlers[current_battler_number], "position",
							left_position if current_battler_number < target_battler_number else right_position,
							0.0
					)
					anon_tween.tween_property(
							battlers[target_battler_number], "position",
							right_position if current_battler_number < target_battler_number else left_position,
							0.0
					)
					if current_action_type == ActionTypes.ATTACK:
						anon_tween.tween_property(
								battlers[current_battler_number], "position",
								center_position,
								1.0
						)
					else:
						anon_tween.tween_interval(1.0)
				else:
					anon_tween.tween_property(
							battlers[current_battler_number], "position",
							center_position,
							0.0
					)
					anon_tween.tween_interval(1.0)
				anon_tween.tween_property(
						black_screen, "self_modulate:a",
						0.0,
						0.25
				)
				anon_tween.parallel().tween_property(
						battlers[current_battler_number], "position",
						current_battler_orig_position,
						0.25
				)
				anon_tween.parallel().tween_property(
						battlers[current_battler_number], "scale",
						current_battler_orig_scale,
						0.25
				)
				if current_battler_number != target_battler_number:
					anon_tween.parallel().tween_property(
							battlers[target_battler_number], "position",
							target_battler_orig_position,
							0.25
					)
					anon_tween.parallel().tween_property(
							battlers[target_battler_number], "scale",
							target_battler_orig_scale,
							0.25
					)
				
				await anon_tween.finished
				hud.show()
				battlers_node.move_child(black_screen, -1)
				
				is_players_turn = not is_players_turn
				current_battler_number = randi_range(0, 2) if is_players_turn else randi_range(3, 5) # For showcase
				enemy_target_button.button_pressed = true
				
				action_animation_ended.emit()
	)
	
	
	
	
	
	
	current_battler_number = randi_range(0, 2) # For showcase
	enemy_target_button.button_pressed = true


func _on_battler_clicked(battler: Battler):
	hide_selection_hovers()
	battler.selection_hover.show()
	target_battler_number = battler.index
	proceed_button.set_enabled(true)
	battlers[current_battler_number].anim_prepare(current_action_type)


func _process(delta: float) -> void:
	$Background/ParallaxBackground/ParallaxLayer2.motion_offset += Vector2.RIGHT * 20 * delta


func _physics_process(delta: float) -> void:
	if not is_players_turn and not is_progressing_enemy_turn:
		is_progressing_enemy_turn = true
		
		target_battler_number = randi_range(0, 2)
		var enemy_tween := create_tween()
		enemy_tween.tween_interval(0.5)
		enemy_tween.tween_callback(
				func():
					enemy_target_button.button_pressed = true
					battlers[current_battler_number].selection.show()
					battlers[current_battler_number].selection_hover.show()
					battlers[current_battler_number].selection.modulate = Global.TargetColors.CURRENT_BATTLER
					battlers[current_battler_number].selection_hover.modulate = Global.TargetColors.CURRENT_BATTLER
					battlers[current_battler_number].anim_prepare(ActionTypes.ATTACK)
					battlers[target_battler_number].selection.show()
					battlers[target_battler_number].selection_hover.show()
					battlers[target_battler_number].selection.modulate = Global.TargetColors.FOE_BATTLER
					battlers[target_battler_number].selection_hover.modulate = Global.TargetColors.FOE_BATTLER
		)
		enemy_tween.tween_interval(1.0)
		enemy_tween.tween_callback(
				func():
					proceed_button.button_pressed = true
					await action_animation_ended
					is_progressing_enemy_turn = false
		)


func _on_back_button_pressed() -> void:
	Global.switch_to_scene(Preloader.game_scene)


func reset_all_selections():
	proceed_button.set_enabled(false)
	for i in battlers.size():
		battlers[i].set_area_clickable(false)
		battlers[i].anim_idle()
		battlers[i].selection.hide()
		battlers[i].selection_hover.hide()
		battlers[i].selection.modulate = Color.WHITE
		battlers[i].selection_hover.modulate = Color.WHITE


func show_current_selection():
	battlers[current_battler_number].selection_hover.hide()
	battlers[current_battler_number].selection_hover.modulate = Color.WHITE
	battlers[current_battler_number].selection.show()
	battlers[current_battler_number].selection.modulate = Global.TargetColors.CURRENT_BATTLER


func hide_selection_hovers():
	for b in battlers:
		b.selection_hover.hide()
