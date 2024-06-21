class_name LevelInfo
extends ColorRect

@export var close_button: TextureButton
@export var level_label: Label
@export var enemies_icons: Array[BackgroundedIcon] = [null, null, null]
@export var coin_label: IconLabel
@export var play_button: Button


func _ready() -> void:
	assert(level_label and coin_label and play_button and enemies_icons.all(func(n): return n != null))
	close_button.pressed.connect( func(): self.hide() )
	play_button.pressed.connect( 
			func():
				GameInfo.add_enemies(GameInfo.current_enemy_level)
				Global.switch_to_scene(Preloader.battle_scene)
	)


func appear(level: int):
	level_label.text = "Уровень противников: " + str(level)
	var enemy_level := GameInfo.get_enemy_level(level) as EnemyLevel
	for i in enemies_icons.size():
		enemies_icons[i].show()
		if enemy_level.enemies[i] == Battler.EnemyTypes.NONE:
			enemies_icons[i].hide()
		else:
			enemies_icons[i].set_icon(Battler.get_start_stats(enemy_level.enemies[i]).icon)
	
	coin_label.set_text(enemy_level.coin_summ)
	GameInfo.current_enemy_level = level
	self.show()

