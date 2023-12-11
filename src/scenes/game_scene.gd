class_name GameScene
extends Node2D

@export var coins_label: Label
@export var game_info_box: HBoxContainer
var op_buttons: Array[OptionButton]
var hero_level_boxes: Array[LevelSpinBox]
var enemy_level_spinbox: SpinBox


func _ready() -> void:
	assert(game_info_box and coins_label)
	
	for i in game_info_box.get_child_count():
		if game_info_box.get_child(i) is VBoxContainer:
			var button := game_info_box.get_child(i).get_child(0) as OptionButton
			var level_box := game_info_box.get_child(i).get_child(1) as LevelSpinBox
			button.remove_item(0)
			button.add_item(Battler.get_type_as_string(Battler.HEROES[0]), Battler.HEROES[0])
			button.add_item(Battler.get_type_as_string(Battler.HEROES[1]), Battler.HEROES[1])
			button.add_item(Battler.get_type_as_string(Battler.HEROES[2]), Battler.HEROES[2])
			button.selected = 2 - i
			button.custom_minimum_size.x = Global.SCREEN_WIDTH / 6 - 20
			level_box.custom_minimum_size.y = button.size.y / 2
			
			op_buttons.append(button)
			hero_level_boxes.append(level_box)
		
		elif game_info_box.get_child(i) is SpinBox:
			enemy_level_spinbox = game_info_box.get_child(i) as SpinBox
			enemy_level_spinbox.min_value = 1
			enemy_level_spinbox.max_value = GameInfo.enemy_levels.size()
	
	_update_coins_label()


func _on_enter_battle_button_pressed() -> void:
	var arr := op_buttons.map( func(button: OptionButton): return button.get_item_id(button.selected) ) # get_selected_id()
	for i in arr.size():
		GameInfo.battlers_types[i] = arr[i]
	GameInfo.add_enemies(enemy_level_spinbox.value)
	
	Global.switch_to_scene(Preloader.battle_scene)


func _update_coins_label():
	coins_label.text = "Кол-во монет: "
	coins_label.text += str(GameInfo.coins)
