class_name GameScene
extends Node2D

@export var settings_button: IconButton
@export var handbook_button: IconButton
@export var hero_grid_container: GridContainer
@export var upgrade_button: Button
@export var play_button: Button
@export var level_up_container: LevelUpContainer
@export var handbook: Handbook
@export var settings: Settings
var heroes_icons: Array[BackgroundedIcon]
var heroes_options: Array[HBoxContainer]
var heroes: Array[Battler.HeroTypes]

var chosen_heroes_types: Array
var heroes_levels := {
	Battler.HeroTypes.KNIGHT: 1,
	Battler.HeroTypes.ROBBER: 1,
	Battler.HeroTypes.MAGE: 1,
}
var hero_icon_textures := {
	Battler.HeroTypes.KNIGHT: Preloader.stats_knight.icon,
	Battler.HeroTypes.ROBBER: Preloader.stats_robber.icon,
	Battler.HeroTypes.MAGE: Preloader.stats_mage.icon,
}


func _ready() -> void:
	assert(level_up_container and handbook_button and handbook and settings_button and hero_grid_container and upgrade_button and play_button and settings)
	level_up_container.hide(); handbook.hide(); settings.hide()
	
	if Global.get_player_last_seen_version() < float(ProjectSettings.get_setting("application/config/version", "99.9")):
		var stars: Array = Global.player_data["enemy_level_stars"]
		if stars.back() != 0 and Global.get_player_last_enemy_level_reached() < GameInfo.enemy_levels.size():
			Global.set_player_last_enemy_level_reached(Global.get_player_last_enemy_level_reached() + 1)
		Global.set_player_last_seen_version(float(ProjectSettings.get_setting("application/config/version", "0.0")))
	
	settings_button.set_on_press( func(): settings.show() )
	handbook_button.set_on_press( func(): handbook.show() )
	
	for child in hero_grid_container.get_children():
		if child is BackgroundedIcon:
			heroes_icons.append(child)
		elif child is HBoxContainer:
			heroes_options.append(child)
	
#region Grid Container
	chosen_heroes_types = Global.get_player_last_hero_choice()
	heroes_levels[Battler.HeroTypes.KNIGHT] = Global.get_player_level(Battler.HeroTypes.KNIGHT)
	heroes_levels[Battler.HeroTypes.ROBBER] = Global.get_player_level(Battler.HeroTypes.ROBBER)
	heroes_levels[Battler.HeroTypes.MAGE] = Global.get_player_level(Battler.HeroTypes.MAGE)
	
	assert(heroes_icons.size() == chosen_heroes_types.size())
	for i in heroes_icons.size():
		heroes_icons[i].set_icon(hero_icon_textures.get(chosen_heroes_types[i] as Battler.HeroTypes))
		heroes_icons[i].gui_input.connect(
				func(event: InputEvent):
					if event is InputEventMouseButton and event.is_pressed():
						for option in heroes_options:
							option.modulate.a = 0.0
							for button: TextureButton in option.get_children():
								button.disabled = true
						
						heroes_options[i].modulate.a = 1.0
						for button: TextureButton in heroes_options[i].get_children():
							button.disabled = false
		)
	
	for i in heroes_options.size():
		heroes_options[i].modulate.a = 0.0
		for j in heroes_options[i].get_child_count():
			var button := heroes_options[i].get_child(j) as TextureButton
			button.texture_normal = hero_icon_textures.values()[j]
			button.pressed.connect(
					func():
						chosen_heroes_types[i] = hero_icon_textures.keys()[j]
						heroes_icons[i].set_icon(hero_icon_textures.get(chosen_heroes_types[i] as Battler.HeroTypes))
						heroes_options[i].modulate.a = 0.0
						for b: TextureButton in heroes_options[i].get_children():
							b.disabled = false
						Global.set_player_last_hero_choice(chosen_heroes_types)
			)
			button.disabled = true
#endregion
	
	upgrade_button.pressed.connect( func(): level_up_container.show() )
	play_button.pressed.connect(
			func():
				var arr := Global.get_player_last_hero_choice()
				for i in arr.size():
					GameInfo.battlers_types[i] = arr[i] as Battler.HeroTypes
				Global.switch_to_scene(Preloader.level_scene)
	)


#func _process(delta: float) -> void:
	#$Background/ParallaxBackground/ParallaxLayer2.motion_offset += Vector2.LEFT * 20 * delta
