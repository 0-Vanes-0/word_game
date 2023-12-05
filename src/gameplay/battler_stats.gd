class_name BattlerStats
extends Resource

signal health_changed(value: int)
signal health_depleted

@export var icon: Texture2D
@export var base_initiative: int
@export var base_health: int
@export var base_min_damage: int
@export var base_max_damage: int
@export_multiline var foe_action_text: String
@export_multiline var ally_action_text: String

var initiative: int
var health: int
var max_health: int
var min_damage: int
var max_damage: int


func _is_stats_valid() -> bool:
	return (
			icon
			and base_initiative > 0
			and base_health > 0 
			and base_min_damage <= base_max_damage and base_min_damage >= 0 and base_max_damage >= 0
			and not foe_action_text.is_empty()
			and not ally_action_text.is_empty()
	)


func get_resource() -> BattlerStats:
	var resoure_copy: BattlerStats = self.duplicate()
	assert(_is_stats_valid())
	resoure_copy.initiative = base_initiative
	resoure_copy.health = base_health
	resoure_copy.max_health = base_health
	resoure_copy.min_damage = base_min_damage
	resoure_copy.max_damage = base_max_damage
	return resoure_copy


func adjust_health(value: int):
	health = clampi(health + value, 0, max_health)
	health_changed.emit(health)
	if health == 0:
		health_depleted.emit()


func get_damage_value():
	return randi_range(min_damage, max_damage)


func get_foe_action_text_as_label() -> RichTextLabel:
	var text := String(foe_action_text)
	var label := _get_label_with_info(text)
	label.name = "FoeActionLabel"
	return label


func get_ally_action_text_as_label() -> RichTextLabel:
	var text := String(ally_action_text)
	var label := _get_label_with_info(text)
	label.name = "AllyActionLabel"
	return label


func _get_label_with_info(text: String) -> RichTextLabel:
	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	var tags := {
		"$dmg": { 
			"append_text": [str(min_damage) + "-" + str(max_damage)]
		},
	}
	
	var splited_text: Array[String] = []
	var regex := RegEx.new()
	regex.compile("\\$(\\w+)")
	var matches := regex.search_all(text)
	var i: int = 0
	for m in matches:
		splited_text.append(text.substr(i, m.get_start() - i))
		splited_text.append(m.get_string())
		i = m.get_end()
	if i < text.length():
		splited_text.append(text.substr(i, text.length() - i))
	
	var commands: Array[Dictionary] = []
	for split in splited_text:
		if tags.has(split):
			commands.append(tags.get(split))
		else:
			commands.append({ "add_text": [split] })
	
	for c in commands:
		var function: String = c.keys()[0]
		label.callv(function, c.get(function))
	
	return label
