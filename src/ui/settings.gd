class_name Settings
extends ColorRect

@export var back_button: Button
@export var music_button: CheckButton
@export var credits: RichTextLabel


func _ready() -> void:
	assert(back_button and music_button and credits)
	
	back_button.pressed.connect( func(): self.hide() )
	music_button.toggled.connect(
			func(toggled_on: bool):
				if toggled_on:
					SoundManager.play_music(Preloader.game_scene_musics.pick_random())
				else:
					SoundManager.stop_music()
				Global.settings["AUDIO"]["MUSIC"] = toggled_on
				SaveLoad.save_settings()
	)
	music_button.button_pressed = Global.settings.get("AUDIO").get("MUSIC")
	credits.meta_clicked.connect( func(meta: Variant): Global.switch_to_scene(Preloader.credits_scene))
