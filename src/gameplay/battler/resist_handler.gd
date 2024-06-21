class_name ResistHandler
extends Node

var battler: Battler
var resisted_queue: Array[Resist]


func _ready() -> void:
	assert(get_parent().get_parent() != null and get_parent().get_parent() is Battler)
	battler = get_parent().get_parent() as Battler


func get_resist(type: Resist.Types) -> Resist:
	var resists := battler.stats.resists
	for resist in resists:
		if resist.type == type:
			return resist
	return null


func provoke_resist(type: Resist.Types) -> bool:
	var resists := battler.stats.resists
	for resist in resists:
		if resist.type == type:
			var has_resisted := resist.try_to_resist()
			if has_resisted:
				resisted_queue.append(resist)
			return has_resisted
	return false


func sum_up_resists():
	if not resisted_queue.is_empty() and battler.is_alive:
		for resist in resisted_queue:
			battler.anim_handler.anim_value_label(BattlerAnimHandler.TextTypes.RESIST, "СОПРОТИВЛЕНИЕ", resist.get_resist_icon())
			await get_tree().create_timer(0.6).timeout
	resisted_queue.clear()
