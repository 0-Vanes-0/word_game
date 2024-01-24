class_name TurnManager
extends MarginContainer

signal battlers_moved_by_one_tick

const OFFSET := Vector2(4, 4)
const ELEMENT_SIZE := Vector2(72, 72)

@export var battle_scene: BattleScene
var _battler_queue: Array[Battler] = []
var _avas: Array[TextureRect] = []
@export_group("Children")
@export var ava_template: TextureRect


func _ready() -> void:
	assert(battle_scene and ava_template)


func setup():
	var battlers: Array[Battler] = battle_scene.battlers.duplicate()
	_avas.resize(battlers.size())
	for i in battlers.size():
		var ava := _create_ava()
		ava.texture = battlers[i].stats.icon
		_avas[battle_scene.battlers[i].index] = ava
		$Avas.add_child(ava)
	
	ava_template.hide()
	
	_battler_queue.resize(10)
	var size := int(battlers.size())
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


func shift_battler(ticks: int = 1):
	if _battler_queue[0] != null:
		for i in range(1, _battler_queue.size()):
			if _battler_queue[i] != null:
				continue
			else:
				ticks -= 1
				if ticks == 0:
					_battler_queue[i] = _battler_queue[0]
					_reposition_slidable(_battler_queue[i].index, i)
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


func _reposition_slidable(slidable_index: int, i: int):
	_avas[slidable_index].position = OFFSET + i * Vector2.RIGHT * ELEMENT_SIZE.x


func _create_ava() -> TextureRect:
	var ava := ava_template.duplicate() as TextureRect
	ava.size = TurnManager.ELEMENT_SIZE
	return ava
