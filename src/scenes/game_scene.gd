class_name GameScene
extends Node2D

@export var game_info_box: HBoxContainer
@export var level_up_container: LevelUpContainer
var op_buttons: Array[OptionButton]
var enemy_level_spinbox: SpinBox

var chosen_heroes_types: Array
var heroes_levels := {
	Battler.Types.HERO_KNIGHT: 1,
	Battler.Types.HERO_ROBBER: 1,
	Battler.Types.HERO_MAGE: 1,
}


func _ready() -> void:
	assert(game_info_box and level_up_container)
	
	if Global.get_player_last_seen_version() < Global.VERSION:
		print("SHOW UPDATE INFO TO PLAYER!!!")
		Global.set_player_last_seen_version(Global.VERSION)
	
	level_up_container.hide()
	
	chosen_heroes_types = Global.get_player_last_hero_choice()
	heroes_levels[Battler.Types.HERO_KNIGHT] = Global.get_player_level(Battler.Types.HERO_KNIGHT)
	heroes_levels[Battler.Types.HERO_ROBBER] = Global.get_player_level(Battler.Types.HERO_ROBBER)
	heroes_levels[Battler.Types.HERO_MAGE] = Global.get_player_level(Battler.Types.HERO_MAGE)
	
	for i in game_info_box.get_child_count():
		if game_info_box.get_child(i) is OptionButton:
			var button := game_info_box.get_child(i) as OptionButton
			button.remove_item(0)
			button.add_item(Battler.get_type_as_string(Battler.HEROES[0]), Battler.HEROES[0])
			button.add_item(Battler.get_type_as_string(Battler.HEROES[1]), Battler.HEROES[1])
			button.add_item(Battler.get_type_as_string(Battler.HEROES[2]), Battler.HEROES[2])
			for j in heroes_levels.keys().size():
				if heroes_levels.keys()[j] == chosen_heroes_types[i]:
					button.selected = j
			
			button.custom_minimum_size.x = Global.SCREEN_WIDTH / 6 - 20
			op_buttons.append(button)
			button.item_selected.connect(_on_option_button_item_selected)
		
		elif game_info_box.get_child(i) is SpinBox:
			enemy_level_spinbox = game_info_box.get_child(i) as SpinBox
			enemy_level_spinbox.min_value = 1
			enemy_level_spinbox.max_value = mini(Global.get_player_last_enemy_level_reached(), GameInfo.enemy_levels.size())
			enemy_level_spinbox.value = GameInfo.current_enemy_level if GameInfo.current_enemy_level > 0 else enemy_level_spinbox.max_value


func _on_enter_battle_button_pressed() -> void:
	var arr := op_buttons.map( func(button: OptionButton): return button.get_selected_id() )
	for i in arr.size():
		GameInfo.battlers_types[i] = arr[i]
	GameInfo.add_enemies(enemy_level_spinbox.value)
	
	Global.switch_to_scene(Preloader.battle_scene)


func _on_upgrade_button_pressed() -> void:
	level_up_container.show()


func _on_option_button_item_selected(_index: int): # _index is intended to be not used
	for i in op_buttons.size():
		chosen_heroes_types[i] = op_buttons[i].get_selected_id()
	Global.set_player_last_hero_choice(chosen_heroes_types)
