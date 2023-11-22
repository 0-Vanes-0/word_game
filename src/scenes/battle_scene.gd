class_name BattleScene
extends Node2D

enum TargetTypes {
	NONE = 0, ENEMY = 1, SELF = 2, ALLY = 3
}

@export_group("Children")
@export var battlers_node: Marker2D
@export var enemy_target_button: IconButton
@export var self_target_button: IconButton
@export var ally_target_button: IconButton
@export var proceed_button: IconButton

var battlers_positions: Array[Vector2]
var battlers: Array[Battler]
var player_battlers: Array[Battler]
var enemy_battlers: Array[Battler]
var current_battler_number: int


func _ready() -> void:
	assert(battlers_node and enemy_target_button and self_target_button and ally_target_button and proceed_button)
	
	battlers_positions.resize(GameInfo.MAX_BATTLERS_COUNT)
	battlers_positions[0] = Vector2.RIGHT * Global.SCREEN_WIDTH * 2 / 16
	battlers_positions[1] = Vector2.RIGHT * Global.SCREEN_WIDTH * 4 / 16
	battlers_positions[2] = Vector2.RIGHT * Global.SCREEN_WIDTH * 6 / 16
	battlers_positions[3] = Vector2.RIGHT * Global.SCREEN_WIDTH * 10 / 16
	battlers_positions[4] = Vector2.RIGHT * Global.SCREEN_WIDTH * 12 / 16
	battlers_positions[5] = Vector2.RIGHT * Global.SCREEN_WIDTH * 14 / 16
	
	for i in GameInfo.MAX_BATTLERS_COUNT:
		var battler_type: Battler.Types = GameInfo.battlers_types[i]
		var battler := Battler.create(battler_type, Battler.get_start_stats(battler_type))
		battler.position = battlers_positions[i]
		battlers_node.add_child(battler)
		
		battler.clicked.connect(
				func():
					hide_selection_hovers()
					battler.selection_hover.show()
					proceed_button.set_enabled(true)
		)
		
		battlers.append(battler)
		if i < 3:
			player_battlers.append(battlers[i])
		else:
			enemy_battlers.append(battlers[i])
	
	enemy_target_button.set_icons(Preloader.texture_sword_yellow_icon, Preloader.texture_sword_black_icon)
	self_target_button.set_icons(Preloader.texture_shield_yellow_icon, Preloader.texture_shield_black_icon)
	ally_target_button.set_icons(Preloader.texture_person_yellow_icon, Preloader.texture_person_black_icon)
	proceed_button.set_icons(Preloader.texture_arrow_right_black_icon, Preloader.texture_arrow_right_yellow_icon, Preloader.texture_arrow_right_black_icon)
	proceed_button.set_enabled(false)
	
	enemy_target_button.set_on_press(
			func():
				reset_all_selections()
				for eb in enemy_battlers:
					eb.selection.show()
					eb.selection.modulate = Global.TargetColors.FOE_BATTLER
					eb.selection_hover.modulate = Global.TargetColors.FOE_BATTLER
					eb.set_area_clickable(true)
	)
	self_target_button.set_on_press(
			func():
				reset_all_selections()
				var cb := player_battlers[current_battler_number]
				cb.selection.show()
				cb.selection.modulate = Global.TargetColors.ALLY_SELF_BATTLER
				cb.selection_hover.modulate = Global.TargetColors.ALLY_SELF_BATTLER
				cb.set_area_clickable(true)
	)
	ally_target_button.set_on_press(
			func():
				reset_all_selections()
				for i in player_battlers.size():
					var ab := player_battlers[i]
					if i != current_battler_number:
						ab.selection.show()
						ab.selection.modulate = Global.TargetColors.ALLY_SELF_BATTLER
						ab.selection_hover.modulate = Global.TargetColors.ALLY_SELF_BATTLER
						ab.set_area_clickable(true)
	)
	proceed_button.set_on_press(
			func():
				proceed_button.set_enabled(false)
				proceed_button.button_pressed = false
				current_battler_number = randi_range(0, 2) # For showcase
				player_battlers[current_battler_number].selection.show()
				player_battlers[current_battler_number].selection.modulate = Global.TargetColors.CURRENT_BATTLER
				reset_all_selections()
				enemy_target_button.button_pressed = true
	)
	
	
	
	
	
	
	enemy_target_button.button_pressed = true
	current_battler_number = randi_range(0, 2) # For showcase
	player_battlers[current_battler_number].selection.show()
	player_battlers[current_battler_number].selection.modulate = Global.TargetColors.CURRENT_BATTLER


func _process(delta: float) -> void:
	$Background/ParallaxBackground/ParallaxLayer2.motion_offset += Vector2.RIGHT * 20 * delta


func _on_back_button_pressed() -> void:
	Global.switch_to_scene(Preloader.game_scene)


func reset_all_selections():
	proceed_button.set_enabled(false)
	for i in battlers.size():
		battlers[i].set_area_clickable(false)
		if i != current_battler_number:
			battlers[i].selection.hide()
			battlers[i].selection_hover.hide()
			battlers[i].selection.modulate = Color.WHITE
			battlers[i].selection_hover.modulate = Color.WHITE
		else:
			battlers[i].selection_hover.hide()
			battlers[i].selection_hover.modulate = Color.WHITE
			battlers[i].selection.modulate = Global.TargetColors.CURRENT_BATTLER


func hide_selection_hovers():
	for b in battlers:
		b.selection_hover.hide()
