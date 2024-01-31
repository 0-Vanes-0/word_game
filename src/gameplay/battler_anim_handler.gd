class_name BattlerAnimHandler
extends Node

const Animations := {
	IDLE = "idle",
	PREPARE_ATTACK = "prepare_attack",
	PREPARE_SELF = "prepare_self",
	PREPARE_ALLY = "prepare_ally",
	ACTION_ATTACK = "action_attack",
	ACTION_SELF = "action_self",
	ACTION_ALLY = "action_ally",
	HURT = "hurt",
	BUFF = "buff",
	DIE = "die",
}
var battler: Battler


func _ready() -> void:
	assert(get_parent() != null and get_parent() is Battler)
	battler = get_parent() as Battler


func anim_idle(start_frame: int = 0):
	battler.sprite.play(Animations.IDLE)
	var frames_count: int = battler.sprite.sprite_frames.get_frame_count(Animations.IDLE)
	battler.sprite.set_frame_and_progress(start_frame, float(start_frame) / frames_count)
	_check_offset(Animations.IDLE)


func anim_prepare(type: Battler.ActionTypes):
	match type:
		Battler.ActionTypes.ATTACK:
			battler.sprite.play(Animations.PREPARE_ATTACK)
			_check_offset(Animations.PREPARE_ATTACK)
		Battler.ActionTypes.ALLY:
			battler.sprite.play(Animations.PREPARE_ALLY)
			_check_offset(Animations.PREPARE_ALLY)
		_:
			battler.sprite.play(Animations.IDLE)
			_check_offset(Animations.IDLE)


func anim_action(type: Battler.ActionTypes):
	match type:
		Battler.ActionTypes.ATTACK:
			battler.sprite.play(Animations.ACTION_ATTACK)
			_check_offset(Animations.ACTION_ATTACK)
		Battler.ActionTypes.ALLY:
			battler.sprite.play(Animations.ACTION_ALLY)
			_check_offset(Animations.ACTION_ALLY)
		_:
			battler.sprite.play(Animations.IDLE)
			_check_offset(Animations.IDLE)


func anim_reaction(type: Battler.ActionTypes):
	var offsets := (battler.sprite.sprite_frames as MySpriteFrames).separate_offsets
	match type:
		Battler.ActionTypes.ATTACK:
			if offsets.has(Animations.HURT):
				battler.sprite.offset = offsets.get(Animations.HURT)
			battler.sprite.play(Animations.HURT)
			_check_offset(Animations.HURT)
		Battler.ActionTypes.ALLY:
			battler.sprite.play(Animations.BUFF)
			_check_offset(Animations.BUFF)
		_:
			battler.sprite.play(Animations.IDLE)
			_check_offset(Animations.IDLE)


func anim_die():
	battler.sprite.play(Animations.DIE)
	battler.health_bar.hide()
	_check_offset(Animations.DIE)


func _check_offset(anim: String):
	var offset_dict := (battler.sprite.sprite_frames as MySpriteFrames).separate_offsets
	if offset_dict.has(anim):
		battler.sprite.offset = offset_dict.get(anim)
	else:
		battler.sprite.offset = (battler.sprite.sprite_frames as MySpriteFrames).offset


func anim_value_label(current_action_type: Battler.ActionTypes, text: String):
	var value_label := RichTextLabel.new()
	value_label.theme = Preloader.default_theme
	value_label.bbcode_enabled = true
	value_label.scroll_active = false
	value_label.add_theme_color_override("default_color", Color.WHITE)
	value_label.add_theme_color_override("font_outline_color", Color.BLACK)
	value_label.add_theme_constant_override("outline_size", 8)
	value_label.add_theme_font_size_override("normal_font_size", 24)
	value_label.custom_minimum_size = Vector2(Global.CHARACTER_SIZE.x * 2, 30)
	value_label.name = "ValueLabel"
	value_label.z_index = 100
	battler.add_child(value_label)
	
	value_label.text = (
			"[center]"
			+ ("" if not text.is_valid_int() or text.begins_with("-") or text == "0" else "+")
			+ text
			+ "[/center]"
	)
	value_label.update_minimum_size()
	value_label.position = Vector2.UP * Global.CHARACTER_SIZE.y / 2 + Vector2.LEFT * value_label.size.x / 2
	value_label.modulate = (
				Global.TargetColors.FOE_BATTLER if current_action_type == Battler.ActionTypes.ATTACK
				else Global.TargetColors.ALLY_BATTLER
	)
	var tween := create_tween()
	tween.tween_property(
			value_label, "position:y",
			value_label.position.y - Global.CHARACTER_SIZE.y / 2,
			BattleAnimator.ACTION_TIME
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(
			value_label, "modulate:a",
			0.0,
			0.1
	)
	tween.tween_interval(0.1)
	tween.tween_callback(value_label.queue_free)


func anim_and_set_about_to_die(value: bool):
	battler.is_about_to_die = value
	if battler.is_about_to_die:
		if not battler.tween_dying:
			battler.tween_dying = create_tween().set_loops()
			battler.tween_dying.tween_property(
					battler.sprite, "self_modulate",
					Color.RED,
					0.5
			)
			battler.tween_dying.tween_property(
					battler.sprite, "self_modulate",
					Color.WHITE,
					0.5
			)
		else:
			battler.tween_dying.play()
	else:
		if battler.tween_dying and battler.tween_dying.is_running():
			battler.tween_dying.pause()
		battler.sprite.self_modulate = Color.WHITE
