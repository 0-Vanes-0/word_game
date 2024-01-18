class_name BattlerInfoContainer
extends MarginContainer

@export var fade_color_rect: ColorRect
@export_group("Children")
@export var ava: BackgroundedIcon
@export var health_bar: MyProgressBar
@export var health_label: Label
@export var coins_label: IconLabel
@export var foe_action_icon: TextureRect
@export var foe_action_label: RichTextLabel
@export var ally_action_icon: TextureRect
@export var ally_action_label: RichTextLabel
@export var resists_vbox: VBoxContainer
@export var resists_grid: GridContainer
const ICON_IN_LABEL_SIZE := Vector2.ONE * 24
const TWEEN_TIME := 0.5
var _tween: Tween


func _ready() -> void:
	assert(ava and health_bar and health_label and foe_action_icon and foe_action_label and ally_action_icon 
			and ally_action_label and coins_label and resists_vbox and resists_grid)
	await Global.get_current_scene().ready
	self.pivot_offset = self.size / 2


func appear(stats: BattlerStats):
	if stats is PlayerBattlerStats:
		self.size_flags_horizontal = Control.SIZE_SHRINK_END
	elif stats is EnemyBattlerStats:
		self.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	
	ava.set_icon(stats.icon)
	health_bar.min_value = 0
	health_bar.max_value = stats.max_health
	health_bar.value = stats.health
	health_label.text = str(stats.health) + "/" + str(stats.max_health)
	
	if stats is PlayerBattlerStats:
		coins_label.hide()
	elif stats is EnemyBattlerStats:
		coins_label.show()
		coins_label.set_icon(Preloader.texture_coin, IconLabel.Sizes.x24)
		coins_label.set_text(stats.reward)
	
	foe_action_label.queue_free()
	foe_action_label = stats.get_foe_action_text_as_label()
	foe_action_icon.add_sibling(foe_action_label)
	foe_action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foe_action_label.fit_content = true
	foe_action_label.scroll_active = false
	
	ally_action_label.queue_free()
	ally_action_label = stats.get_ally_action_text_as_label()
	ally_action_icon.add_sibling(ally_action_label)
	ally_action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ally_action_label.fit_content = true
	ally_action_label.scroll_active = false
	
	resists_vbox.hide()
	for child in resists_grid.get_children():
		child.queue_free()
	for resist in stats.resists:
		var resist_label := IconLabel.create()
		resist_label.set_icon(Resist.get_resist_icon(resist.type), IconLabel.Sizes.x24)
		resist_label.set_text(str(resist.value) + "%")
		resists_grid.add_child(resist_label)
	if not stats.resists.is_empty():
		resists_vbox.show()
	
	fade_color_rect.show()
	self.show()
	_tween = _new_tween()
	_tween.tween_property(
			self, "scale",
			Vector2.ONE,
			TWEEN_TIME
	).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT).from(Vector2.ZERO)
	_tween.parallel().tween_property(
			fade_color_rect, "color:a",
			0.5,
			TWEEN_TIME
	)


func disappear():
	_tween = _new_tween()
	_tween.tween_property(
			self, "scale",
			Vector2.ZERO,
			TWEEN_TIME / 2
	).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	_tween.parallel().tween_property(
			fade_color_rect, "color:a",
			0.0,
			TWEEN_TIME
	)
	_tween.tween_callback(
			func():
				self.hide()
				fade_color_rect.hide()
	)


func _new_tween() -> Tween:
	if _tween:
		_tween.kill()
	return create_tween()
