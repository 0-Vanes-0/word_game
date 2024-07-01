class_name LevelInfo
extends ColorRect

@export var _close_button: TextureButton
@export var _level_label: Label
@export var _enemies_vbox: VBoxContainer
@export var _enemy_icon_template: BackgroundedIcon
@export var _play_button: Button


func _ready() -> void:
	assert(_close_button and _level_label and _enemies_vbox and _enemy_icon_template and _play_button)
	(_enemies_vbox.get_child(0) as HBoxContainer).hide()
	_close_button.pressed.connect(
			func():
				self.hide()
				_clear_icons()
	)
	_play_button.pressed.connect(
			func():
				_clear_icons()
				GameInfo.add_enemies(GameInfo.current_enemy_level)
				Global.switch_to_scene(Preloader.battle_scene)
	)


func appear(level: int):
	_level_label.text = "Уровень противников: " + str(level)
	
	var enemy_level: EnemyLevel = GameInfo.get_enemy_level(level)
	for i in enemy_level.get_size():
		var enemy_icon := _enemy_icon_template.duplicate() as BackgroundedIcon
		if i % EnemyLevelStage.STAGE_MAX_SIZE == 0:
			var hbox := HBoxContainer.new()
			hbox.name = "HBox" + str(i/EnemyLevelStage.STAGE_MAX_SIZE + 1)
			_enemies_vbox.add_child(hbox)
		
		_enemies_vbox.get_child(-1).add_child(enemy_icon)
		var enemy_type := enemy_level.get_enemy_type(i)
		if enemy_type == Battler.EnemyTypes.NONE:
			enemy_icon.modulate.a = 0.0
		else:
			enemy_icon.set_icon(Battler.get_start_stats(enemy_type).icon)
		enemy_icon.show()
	
	GameInfo.current_enemy_level = level
	self.show()


func _clear_icons():
	for i in range(1, _enemies_vbox.get_child_count()):
		_enemies_vbox.get_child(i).queue_free()
