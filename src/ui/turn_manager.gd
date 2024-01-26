class_name TurnManager
extends MarginContainer

signal battlers_moved_by_one_tick
signal queue_ready

const OFFSET := Vector2(4, 4)
const ELEMENT_SIZE := Vector2(72, 72)
const AVAS_SETUP_OFFSET := Vector2(400, 120)
const AVAS_GAP := 160

const PREVIEW_TIME := 2.0
const AVA_MOVE_TIME := 0.25

@export var _battle_scene: BattleScene
@export_group("Children")
@export var _ava_template: TextureRect
@export var _label_template: Label
@export var _wtf_label: Label

var _battler_queue: Array[Battler] = []
var _avas: Array[TextureRect] = []
var _labels: Array[Label] = []


func _ready() -> void:
	assert(_battle_scene and _ava_template and _label_template and _wtf_label)


func setup():
	var battlers: Array[Battler] = _battle_scene.battlers.duplicate()
	for i in battlers.size():
		var ava := _create_ava()
		ava.texture = battlers[i].stats.icon
		ava.position = AVAS_SETUP_OFFSET + Vector2.LEFT * AVAS_GAP * battlers.size() / 2.0 + Vector2.RIGHT * AVAS_GAP * i
		_avas.append(ava)
		$Avas.add_child(ava)
		
		var label := _label_template.duplicate() as Label
		label.text = str(battlers[i].stats.initiative)
		label.update_minimum_size()
		label.position = ava.position + Vector2.DOWN * ava.size.y
		label.custom_minimum_size.x = ava.size.x
		_labels.append(label)
		$Avas.add_child(label)
	
	_ava_template.hide()
	_label_template.hide()
	$Avas.z_index = 999
	
	_battler_queue.resize(10)
	var size := int(battlers.size())
	
	await get_tree().create_timer(PREVIEW_TIME).timeout
	$Avas.z_index = 0
	for i in size:
		var max_initiative: int = 0
		var next_battler: int = -1
		for j in battlers.size():
			if battlers[j].stats.initiative > max_initiative:
				next_battler = j
				max_initiative = battlers[j].stats.initiative
		_battler_queue[i] = battlers[next_battler]
		_reposition_slidable(battlers[next_battler].index, i)
		battlers.remove_at(next_battler)
		create_tween().tween_property(
			_labels[i], "modulate:a",
			0.0,
			AVA_MOVE_TIME
		)
		
		await get_tree().create_timer(0.15).timeout
	
	create_tween().tween_property(
			_wtf_label, "modulate:a",
			0.0,
			1.0
	)
	queue_ready.emit()


func shift_battler(ticks: int = 1):
	if _battler_queue[0] != null:
		for i in range(1, _battler_queue.size()):
			if _battler_queue[i] != null:
				continue
			else:
				ticks -= 1
				await _reposition_slidable(_battler_queue[0].index, i, 2.0)
				if ticks == 0:
					_battler_queue[i] = _battler_queue[0]
					break
		_battler_queue[0] = null
	else:
		print_debug("_battler_queue[0] == null!!!")
	
	move_battlers()
	battlers_moved_by_one_tick.emit()


func get_current_battler_index() -> int:
	return _battler_queue[0].index


func move_battlers():
	for i in _battler_queue.size():
		if _battler_queue[i] == null:
			if i < _battler_queue.size() - 1:
				_battler_queue[i] = _battler_queue[i+1]
				_battler_queue[i+1] = null
			else:
				_battler_queue[i] = null
			
			if _battler_queue[i] != null:
				_reposition_slidable(_battler_queue[i].index, i)


func remove_battler(battler_index: int):
	for i in _battler_queue.size():
		if _battler_queue[i] != null and _battler_queue[i].index == battler_index:
			_battler_queue[i] = null
			_avas[battler_index].hide()
			move_battlers()
			break


func _reposition_slidable(slidable_index: int, i: int, time_scale := 1.0):
	var tween := create_tween()
	tween.tween_property(
		_avas[slidable_index], "position",
		OFFSET + i * Vector2.RIGHT * ELEMENT_SIZE.x,
		AVA_MOVE_TIME * time_scale
	)
	await tween.finished


func _create_ava() -> TextureRect:
	var ava := _ava_template.duplicate() as TextureRect
	ava.size = ELEMENT_SIZE
	return ava
