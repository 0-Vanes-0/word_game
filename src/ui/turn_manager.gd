class_name TurnManager
extends MarginContainer

signal need_to_show_text(text: String, time: float)

const OFFSET := Vector2(4, 4)
const ELEMENT_SIZE := Vector2(72, 72)
const AVAS_SETUP_OFFSET := Vector2(400, 120)
const AVAS_GAP := 160

const PREVIEW_TIME := 2.0
const AVA_MOVE_TIME := 0.25

@export_group("Required Children")
@export var _ava_template: TextureRect
@export var _label_template: Label

var current_queue_index: int = 0
var _battler_queue: Array[Battler] = []
var _avas: Array[TextureRect] = []
var _labels: Array[Label] = []


func _ready() -> void:
	assert(_ava_template and _label_template)


func setup(battlers: Array[Battler]): # TODO: add re-setup???
	var battlers_copy: Array[Battler] = battlers.duplicate()
	
	for i in battlers_copy.size():
		var ava := _create_ava()
		ava.texture = battlers_copy[i].stats.icon
		ava.position = AVAS_SETUP_OFFSET + Vector2.LEFT * AVAS_GAP * battlers_copy.size() / 2.0 + Vector2.RIGHT * AVAS_GAP * i
		_avas.append(ava)
		$Avas.add_child(ava)
		
		var label := _label_template.duplicate() as Label
		label.text = str(battlers_copy[i].stats.initiative)
		label.update_minimum_size()
		label.position = ava.position + Vector2.DOWN * ava.size.y
		label.custom_minimum_size.x = ava.size.x
		_labels.append(label)
		$Avas.add_child(label)
	
	_ava_template.hide()
	_label_template.hide()
	$Avas.z_index = 999
	
	var size := int(battlers_copy.size())
	_battler_queue.resize(size)

	print_debug("battlers ready: ", battlers_copy.size())
	need_to_show_text.emit("Распределение по скорости", PREVIEW_TIME)
	await get_tree().create_timer(PREVIEW_TIME).timeout
	$Avas.z_index = 0
	for i in size:
		var max_initiative: int = 0
		var next_battler: int = -1
		for j in battlers_copy.size():
			if battlers_copy[j].stats.initiative > max_initiative:
				next_battler = j
				max_initiative = battlers_copy[j].stats.initiative
		_battler_queue[i] = battlers_copy[next_battler]
		_reposition(battlers_copy[next_battler].index, i)
		battlers_copy.remove_at(next_battler)
		create_tween().tween_property(
				_labels[i], "modulate:a",
				0.0,
				AVA_MOVE_TIME
		)
		
		await get_tree().create_timer(0.15).timeout


#func shift_battler(ticks: int = 1):
#	if _battler_queue[0] != null:
#		for i in range(1, _battler_queue.size()):
#			if _battler_queue[i] != null:
#				continue
#			else:
#				ticks -= 1
#				await _reposition(_battler_queue[0].index, i, 2.0)
#				if ticks == 0:
#					_battler_queue[i] = _battler_queue[0]
#					break
#		_battler_queue[0] = null
#	else:
#		print_debug("_battler_queue[0] == null!!!")
#
#	move_battlers()
#	await get_tree().create_timer(AVA_MOVE_TIME).timeout


func get_current_battler_index() -> int:
	return _battler_queue[current_queue_index].index


func next_battler():
	if _battler_queue.any(func(b: Battler): return b.is_alive):
		current_queue_index = (current_queue_index + 1) % _battler_queue.size()
		print_debug("current_queue_index: ", current_queue_index)
		await get_tree().create_timer(0.01).timeout # Animation here
		if not _battler_queue[current_queue_index].is_alive:
			next_battler()
	#else: notify somehow?


#func move_battlers():
#	for i in _battler_queue.size():
#		if _battler_queue[i] == null:
#			if i < _battler_queue.size() - 1:
#				_battler_queue[i] = _battler_queue[i+1]
#				_battler_queue[i+1] = null
#			else:
#				_battler_queue[i] = null
#
#			if _battler_queue[i] != null:
#				_reposition(_battler_queue[i].index, i)


func toggle_aliveness(battler_index: int, is_alive: bool):
	for i in _battler_queue.size():
		if _battler_queue[i] != null and _battler_queue[i].index == battler_index:
			_avas[battler_index].modulate.s = 1.0 if is_alive else 0.0
			break


func _reposition(slidable_index: int, i: int, time_scale := 1.0):
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
