class_name GameScene
extends Node2D

@export var coins_label: Label
@export var game_info_box: HBoxContainer
var op_buttons: Array[OptionButton]
var hero_level_boxes: Array[LevelSpinBox]
var enemy_level_spinbox: SpinBox

var chosen_heroes_types: Array
var heroes_levels := {
	Battler.Types.HERO_KNIGHT: 1,
	Battler.Types.HERO_ROBBER: 1,
	Battler.Types.HERO_MAGE: 1,
}



func _ready() -> void:
	assert(game_info_box and coins_label)
	
	chosen_heroes_types = Global.get_player_last_hero_choice()
	heroes_levels[Battler.Types.HERO_KNIGHT] = Global.get_player_level(Battler.Types.HERO_KNIGHT)
	heroes_levels[Battler.Types.HERO_ROBBER] = Global.get_player_level(Battler.Types.HERO_ROBBER)
	heroes_levels[Battler.Types.HERO_MAGE] = Global.get_player_level(Battler.Types.HERO_MAGE)
	
	for i in game_info_box.get_child_count():
		if game_info_box.get_child(i) is VBoxContainer:
			var button := game_info_box.get_child(i).get_child(0) as OptionButton
			var level_box := game_info_box.get_child(i).get_child(1) as LevelSpinBox
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
			
			level_box.index = i
			level_box.can_emit_value_changed = false
			level_box.custom_minimum_size.y = button.size.y / 2
			hero_level_boxes.append(level_box)
			level_box.value_changed.connect(
					func(value: float):
						if level_box.can_emit_value_changed:
							_on_level_box_value_changed(level_box.index, int(value))
			)
		
		elif game_info_box.get_child(i) is SpinBox:
			enemy_level_spinbox = game_info_box.get_child(i) as SpinBox
			enemy_level_spinbox.min_value = 1
			enemy_level_spinbox.max_value = GameInfo.enemy_levels.size()
	
	_update_coins_label()
	_update_hero_level_boxes()


func _on_enter_battle_button_pressed() -> void:
	var arr := op_buttons.map( func(button: OptionButton): return button.get_item_id(button.selected) ) # get_selected_id()
	for i in arr.size():
		GameInfo.battlers_types[i] = arr[i]
	GameInfo.add_enemies(enemy_level_spinbox.value)
	
	Global.switch_to_scene(Preloader.battle_scene)


func _update_coins_label():
	coins_label.text = "Кол-во монет: "
	coins_label.text += str(Global.get_player_coins())


func _update_hero_level_boxes():
	for i in hero_level_boxes.size():
		hero_level_boxes[i].can_emit_value_changed = false
		
		var hero_type: Battler.Types = op_buttons[i].get_item_id(op_buttons[i].selected) # get_selected_id()
		hero_level_boxes[i].min_value = heroes_levels[hero_type]
		if GameInfo.get_coins_by_level(heroes_levels[hero_type] + 1) <= Global.get_player_coins():
			hero_level_boxes[i].max_value = heroes_levels[hero_type] + 1
		else:
			hero_level_boxes[i].max_value = heroes_levels[hero_type]
		
		hero_level_boxes[i].can_emit_value_changed = true


func _on_option_button_item_selected(_index: int): # _index is intended to be not used
	for i in op_buttons.size():
		chosen_heroes_types[i] = op_buttons[i].get_item_id(op_buttons[i].selected) # get_selected_id()
	Global.set_player_last_hero_choice(chosen_heroes_types)
	_update_hero_level_boxes()


func _on_level_box_value_changed(level_box_index: int, value: int):
	var coins_to_spent: int = GameInfo.get_coins_by_level(value)
	if GameInfo.pay_coins(coins_to_spent):
		var hero_type: Battler.Types = chosen_heroes_types[level_box_index]
		heroes_levels[hero_type] = value
		Global.set_player_level(hero_type, value)
		_update_coins_label()
		_update_hero_level_boxes()
