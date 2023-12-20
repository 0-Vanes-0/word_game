class_name GameScene
extends Node2D

@export var level_up_container: LevelUpContainer
@export var op_button1: OptionButton
@export var op_button2: OptionButton
@export var op_button3: OptionButton
@export var enemy_level_label: Label
@export var enemy_level_up_button: TextureButton
@export var enemy_level_down_button: TextureButton
var op_buttons: Array[OptionButton]

var chosen_heroes_types: Array
var heroes_levels := {
	Battler.Types.HERO_KNIGHT: 1,
	Battler.Types.HERO_ROBBER: 1,
	Battler.Types.HERO_MAGE: 1,
}
var enemy_level_min: int
var enemy_level_max: int
var enemy_level_value: int


func _ready() -> void:
	assert(level_up_container and op_button1 and op_button2 and op_button3 and enemy_level_label and enemy_level_up_button and enemy_level_down_button)
	
	SoundManager.play_music(Preloader.game_scene_musics.pick_random())
	
	if Global.get_player_last_seen_version() < Global.VERSION:
		print("SHOW UPDATE INFO TO PLAYER!!!")
		Global.set_player_last_seen_version(Global.VERSION)
	
	level_up_container.hide()
	
	chosen_heroes_types = Global.get_player_last_hero_choice()
	heroes_levels[Battler.Types.HERO_KNIGHT] = Global.get_player_level(Battler.Types.HERO_KNIGHT)
	heroes_levels[Battler.Types.HERO_ROBBER] = Global.get_player_level(Battler.Types.HERO_ROBBER)
	heroes_levels[Battler.Types.HERO_MAGE] = Global.get_player_level(Battler.Types.HERO_MAGE)
	
	op_buttons = [op_button1, op_button2, op_button3] as Array[OptionButton]
	for i in op_buttons.size():
		op_buttons[i].remove_item(0)
		op_buttons[i].add_icon_item(Preloader.sprite_frames_knight.get_placeholder_texture(), "", Battler.HEROES[0])
		op_buttons[i].add_icon_item(Preloader.sprite_frames_robber.get_placeholder_texture(), "", Battler.HEROES[1])
		op_buttons[i].add_icon_item(Preloader.sprite_frames_mage.get_placeholder_texture(), "", Battler.HEROES[2])
		for j in heroes_levels.keys().size():
			if heroes_levels.keys()[j] == chosen_heroes_types[i]:
				op_buttons[i].selected = j
		op_buttons[i].item_selected.connect(_on_option_button_item_selected)
	
	enemy_level_min = 1
	enemy_level_max = mini(Global.get_player_last_enemy_level_reached(), GameInfo.enemy_levels.size())
	enemy_level_value = GameInfo.current_enemy_level if GameInfo.current_enemy_level > 0 else enemy_level_max
	enemy_level_label.text = "Уровень противников: " + str(enemy_level_value)
	enemy_level_up_button.disabled = enemy_level_value == enemy_level_max
	enemy_level_down_button.disabled = enemy_level_value == enemy_level_min


func _on_option_button_item_selected(_index: int): # _index is intended to be not used
	for i in op_buttons.size():
		chosen_heroes_types[i] = op_buttons[i].get_selected_id()
	Global.set_player_last_hero_choice(chosen_heroes_types)


func _on_lvl_down_button_pressed() -> void:
	enemy_level_value = clampi(enemy_level_value - 1, enemy_level_min, enemy_level_max)
	enemy_level_label.text = "Уровень противников: " + str(enemy_level_value)
	enemy_level_up_button.disabled = enemy_level_value == enemy_level_max
	enemy_level_down_button.disabled = enemy_level_value == enemy_level_min


func _on_lvl_up_button_pressed() -> void:
	enemy_level_value = clampi(enemy_level_value + 1, enemy_level_min, enemy_level_max)
	enemy_level_label.text = "Уровень противников: " + str(enemy_level_value)
	enemy_level_up_button.disabled = enemy_level_value == enemy_level_max
	enemy_level_down_button.disabled = enemy_level_value == enemy_level_min


func _on_upgrade_button_pressed() -> void:
	level_up_container.show()


func _on_enter_battle_button_pressed() -> void:
	var arr := op_buttons.map( func(button: OptionButton): return button.get_selected_id() )
	for i in arr.size():
		GameInfo.battlers_types[i] = arr[i]
	GameInfo.add_enemies(enemy_level_value)
	
	Global.switch_to_scene(Preloader.battle_scene)


#func _process(delta: float) -> void:
	#$Background/ParallaxBackground/ParallaxLayer2.motion_offset += Vector2.LEFT * 20 * delta


