class_name BattlerInfoContainer
extends MarginContainer

@export var ava: TextureRect
@export var health_bar: MyProgressBar
@export var health_label: Label
@export var foe_action_icon: TextureRect
@export var foe_action_label: RichTextLabel
@export var ally_action_icon: TextureRect
@export var ally_action_label: RichTextLabel
const ICON_IN_LABEL_SIZE := Vector2.ONE * 24
const TWEEN_TIME := 0.5
var _tween


func _ready() -> void:
	assert(ava and health_bar and health_label and foe_action_icon and foe_action_label and ally_action_icon and ally_action_label)
	await Global.get_current_scene().ready
	self.pivot_offset = self.size / 2


func appear(stats: BattlerStats):
	ava.texture = stats.icon
	health_bar.min_value = 0
	health_bar.max_value = stats.max_health
	health_bar.value = stats.health
	health_label.text = str(stats.health) + "/" + str(stats.max_health)
	
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
	
	self.show()
	_tween = _new_tween()
	_tween.tween_property(
			self, "scale",
			Vector2.ONE,
			TWEEN_TIME
	).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)


func disappear():
	_tween = _new_tween()
	_tween.tween_property(
			self, "scale",
			Vector2.ZERO,
			TWEEN_TIME / 2
	).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	_tween.tween_callback(
			func():
				self.hide()
	)


func _new_tween() -> Tween:
	if _tween:
		_tween.kill()
	return create_tween()
