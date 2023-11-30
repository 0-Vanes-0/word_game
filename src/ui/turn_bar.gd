class_name TurnBar
extends Control

@export var battle_scene: BattleScene
var _battler_queue: Array[Battler] = []
var _sliders: Array[HSlider] = []


func _ready() -> void:
	assert(battle_scene)


func setup():
	var battlers: Array[Battler] = battle_scene.battlers.duplicate()
	
	_sliders.resize(battlers.size())
	for i in battlers.size():
		var slider: HSlider
		if i > 0:
			slider = self.get_child(0).duplicate()
			self.add_child(slider)
		else:
			slider = self.get_child(0)
			
		slider.add_theme_icon_override("grabber", battlers[i].stats.icon)
		slider.add_theme_icon_override("grabber_highlight", battlers[i].stats.icon)
		slider.add_theme_icon_override("grabber_disabled", battlers[i].stats.icon)
		_sliders[battle_scene.battlers[i].index] = slider
	
	_battler_queue.resize(12)
	var size := int(battlers.size())
	for i in size:
		var max_initiative: int = 0
		var next_battler: int = -1
		for j in battlers.size():
			if battlers[j].stats.initiative > max_initiative:
				next_battler = j
				max_initiative = battlers[j].stats.initiative
		
		_battler_queue[i] = battlers[next_battler]
		_sliders[battlers[next_battler].index].value = i
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
					_sliders[_battler_queue[i].index].value = i
					break
		_battler_queue[0] = null
	else:
		print_debug("_battler_queue[0] == null!!!")
	
	move_battlers()


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
				_sliders[_battler_queue[i].index].value = i


func remove_battler(battler_index: int):
	for i in _battler_queue.size():
		if _battler_queue[i] != null and _battler_queue[i].index == battler_index:
			_battler_queue[i] = null
			_sliders[battler_index].hide()
			move_battlers()
			break
