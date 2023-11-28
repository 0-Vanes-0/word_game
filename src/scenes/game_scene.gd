extends Node2D

@export var op_button1: OptionButton
@export var op_button2: OptionButton
@export var op_button3: OptionButton
@export var op_button4: OptionButton
@export var op_button5: OptionButton
@export var op_button6: OptionButton


func _ready() -> void:
	assert(op_button1 and op_button2 and op_button3 and op_button4 and op_button5 and op_button6)
	
	for i in $CanvasLayer/Control/CenterContainer/VBoxContainer/HBoxContainer.get_child_count():
		var button := $CanvasLayer/Control/CenterContainer/VBoxContainer/HBoxContainer.get_child(i) as OptionButton
		button.remove_item(0)
		if i <= 2:
			button.add_item(Battler.Types.keys()[ Battler.Types.values().find(Battler.HEROES[0]) ], Battler.HEROES[0]) # ОЧЕНЬ ПЛОХОЙ КОД!!! (если что)
			button.add_item(Battler.Types.keys()[ Battler.Types.values().find(Battler.HEROES[1]) ], Battler.HEROES[1])
			button.add_item(Battler.Types.keys()[ Battler.Types.values().find(Battler.HEROES[2]) ], Battler.HEROES[2])
			button.selected = 2 - i
		else:
			button.add_item(Battler.Types.keys()[ Battler.Types.values().find(Battler.MOBS[0]) ], Battler.MOBS[0])
			button.selected = 0
		button.custom_minimum_size.x = Global.SCREEN_WIDTH / 6 - 20


func _on_enter_battle_button_pressed() -> void:
	var arr: Array[Battler.Types] = [
		op_button1.get_item_id(op_button1.selected) as Battler.Types,
		op_button2.get_item_id(op_button2.selected) as Battler.Types,
		op_button3.get_item_id(op_button3.selected) as Battler.Types,
		op_button4.get_item_id(op_button4.selected) as Battler.Types,
		op_button5.get_item_id(op_button5.selected) as Battler.Types,
		op_button6.get_item_id(op_button6.selected) as Battler.Types,
	]
	GameInfo.battlers_types = arr
	Global.switch_to_scene(Preloader.battle_scene)
