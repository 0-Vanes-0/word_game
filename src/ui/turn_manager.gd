class_name TurnManager
extends MarginContainer

signal need_to_show_text(text: String, time: float)

const OFFSET := Vector2(4, 4)
const ELEMENT_SIZE := Vector2(72, 72)
const AVAS_SETUP_OFFSET := Vector2(400, 120)
const AVAS_GAP := 160

const PREVIEW_TIME := 2.0
const AVA_MOVE_TIME := 0.25
const ARROW_MOVE_TIME := 0.5

@export_group("Required Children")
@export var _ava_template: TextureRect
@export var _label_template: Label
@export var _arrow: TextureRect

var current_queue_index: int = 0
var _battler_queue: Array[Battler] = []
var _avas: Array[TextureRect] = []
var _labels: Array[Label] = []
var _arrow_positions: Array[Vector2] = []


func _ready() -> void:
	assert(_ava_template and _label_template and _arrow)
	_arrow.hide()


func setup(battlers: Array[Battler]): # TODO: add re-setup???
	var battlers_copy: Array[Battler] = battlers.duplicate()
	
	for i in battlers_copy.size():
		var ava := _create_ava()
		ava.texture = battlers_copy[i].stats.icon
		ava.position = AVAS_SETUP_OFFSET + Vector2.LEFT * AVAS_GAP * battlers_copy.size() / 2.0 + Vector2.RIGHT * AVAS_GAP * i
		_avas.append(ava)
		$Avas.add_child(ava)
		
		ava.update_minimum_size()
		_arrow_positions.append(Vector2(ava.size.x / 2 - _arrow.pivot_offset.x + i * ava.size.x, self.size.y))
		
		var label := _label_template.duplicate() as Label
		label.text = str(battlers_copy[i].stats.initiative)
		label.update_minimum_size()
		label.position = ava.position + Vector2.DOWN * ava.size.y
		label.custom_minimum_size.x = ava.size.x
		_labels.append(label)
		$Avas.add_child(label)
		
		battlers[i].stats.health_depleted.connect(
				func():
					_toggle_aliveness(ava, battlers[i].is_alive)
		)
	
	_ava_template.hide()
	_label_template.hide()
	$Avas.z_index = 999
	
	var size := int(battlers_copy.size())
	_battler_queue.resize(size)
	
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
	
	_arrow.position = _arrow_positions[0]
	_arrow.modulate.a = 0.0
	_arrow.show()
	create_tween().tween_property(
			_arrow, "modulate:a",
			1.0,
			ARROW_MOVE_TIME
	)


func get_current_battler_index() -> int:
	return _battler_queue[current_queue_index].index


func next_battler():
	if _battler_queue.any(func(b: Battler): return b.is_alive):
		current_queue_index = (current_queue_index + 1) % _battler_queue.size()
		var tween := create_tween().tween_property(
				_arrow, "position",
				_arrow_positions[current_queue_index],
				ARROW_MOVE_TIME
		)
		await tween.finished
		if not _battler_queue[current_queue_index].is_alive:
			next_battler()
	else:
		assert(false, "No alive battlers!")


func _toggle_aliveness(ava: TextureRect, is_alive: bool):
	ava.modulate.v = 1.0 if is_alive else 0.5


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
