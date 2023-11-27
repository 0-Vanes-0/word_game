class_name BattleScene
extends Node2D

enum ActionTypes {
	NONE = 0, ATTACK = 1, ALLY = 2
}

signal proceed_turn_ended

@export var hud_manager: BattleHUDManager
@export var battlers_node: Marker2D
@export var black_screen: MeshInstance2D
@export var effect_sprite: AnimatedSprite2D
@export var battle_animator: BattleAnimator

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
	assert(hud_manager and battlers_node and black_screen and effect_sprite and battle_animator)
	
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
		
		battlers_node.add_child(battler)
		battlers.append(battler)
		if index < 3:
			player_battlers.append(battlers[index])
		else:
			enemy_battlers.append(battlers[index])
	
	battlers_node.move_child(black_screen, -1)
	battlers_node.move_child(effect_sprite, -1)
	
	hud_manager.to_select_enemies.connect(
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
					player_battlers[i].set_area_clickable(true)
				
				current_action_type = ActionTypes.ALLY
	)
	hud_manager.to_proceed_turn.connect(
			func():
				reset_all_selections()
				
				var spell: Array[Rune] = hud_manager.spell
				var runes_counter := {}

				for rune in spell:
					if runes_counter.has(rune.type):
						runes_counter[rune.type] += 1
					else:
						runes_counter[rune.type] = 1
				
				var most_common_type := -1
				var max_count := -1
				for key in runes_counter.keys():
					if runes_counter.get(key) > max_count:
						most_common_type = key
						max_count = runes_counter.get(key)
				
				battle_animator.animate_turn(most_common_type)
				await battle_animator.animate_turn_completed
				
				hud_manager.spell.clear()
				
				is_players_turn = not is_players_turn
				if is_players_turn:
					current_battler_number = randi_range(0, 2) # For showcase
					hud_manager.appear()
				else:
					current_battler_number = randi_range(3, 5) # For showcase
				
				proceed_turn_ended.emit()
	)
	hud_manager.appear()
	
	
	
	current_battler_number = randi_range(0, 2) # For showcase
	hud_manager.to_select_enemies.emit()


func _on_battler_clicked(battler: Battler):
	hide_selection_hovers()
	battler.selection_hover.show()
	target_battler_number = battler.index
	hud_manager.set_proceed_button_enabled(true)
	battlers[current_battler_number].anim_prepare(current_action_type)


func _process(delta: float) -> void:
	$Background/ParallaxBackground/ParallaxLayer2.motion_offset += Vector2.RIGHT * 20 * delta


func _physics_process(delta: float) -> void:
	if not is_players_turn and not is_progressing_enemy_turn:
		is_progressing_enemy_turn = true
		
		target_battler_number = randi_range(0, 2)
		
		battle_animator.animate_enemy_prepare_completed.connect(
				func():
					hud_manager.to_proceed_turn.emit()
					await proceed_turn_ended
					is_progressing_enemy_turn = false
		, CONNECT_ONE_SHOT)
		battle_animator.animate_enemy_prepare()


func _on_back_button_pressed() -> void:
	Global.switch_to_scene(Preloader.game_scene)


func reset_all_selections():
	for i in battlers.size():
		battlers[i].set_area_clickable(false)
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
