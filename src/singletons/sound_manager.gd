extends Node

var _music_player: AudioStreamPlayer
var _tween: Tween


func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	self.add_child(_music_player)
	self.process_mode = Node.PROCESS_MODE_ALWAYS


func play_sound(sound: AudioStreamOggVorbis):
	assert(sound)
	var asp := AudioStreamPlayer.new()
	asp.stream = sound
	asp.volume_db = -10
	self.add_child(asp)
	asp.finished.connect(
			func():
				asp.queue_free()
	)
	asp.play()


func play_music(music: AudioStreamOggVorbis, ):
	assert(music)
	_music_player.stop()
	_music_player.stream = music
	_music_player.volume_db = -80
	_music_player.play()
	_tween = _new_tween()
	_tween.tween_property(
			_music_player, "volume_db",
			-10,
			1.0
	)


func stop_music():
	if _music_player.playing:
		_tween = _new_tween()
		_tween.tween_property(
				_music_player, "volume_db",
				-80,
				1.0
		)
		_tween.tween_callback(
				func():
					_music_player.stop()
		)
		await _tween.finished


func _new_tween() -> Tween:
	if _tween:
		_tween.kill()
	return create_tween()
