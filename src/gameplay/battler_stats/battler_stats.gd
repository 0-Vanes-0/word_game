class_name BattlerStats
extends Resource

signal health_changed(value: int, delta: int)
signal health_depleted

@export var icon: Texture2D
@export var battler_name: String
@export var base_min_initiative: int
@export var base_max_initiative: int
@export var base_health: int
@export var base_min_damage_fraction := Vector2.ONE
@export var base_max_damage: int
@export var base_ally_action_value: int
@export var is_attack_action_group: bool
@export var is_ally_action_group: bool
@export var foe_action_name: String
@export_multiline var foe_action_text: String
@export var ally_action_name: String
@export_multiline var ally_action_text: String
@export var base_resist_array: Array[Resist]

var initiative: int
var health: int
var max_health: int
var min_damage_fraction: Vector2
var max_damage: int
var ally_action_value: int
var resists: Array[Resist]


func _is_stats_valid() -> bool:
	return (
			icon
			and base_min_initiative > 0
			and base_max_initiative > 0
			and base_health > 0 
			and base_min_damage_fraction.x <= base_min_damage_fraction.y and base_min_damage_fraction >= Vector2.ZERO
			and base_max_damage >= 0
	)


func get_resource() -> BattlerStats:
	var resoure_copy: BattlerStats = self.duplicate()
	assert(_is_stats_valid())
	resoure_copy.initiative = randi_range(base_min_initiative, base_max_initiative)
	resoure_copy.health = base_health
	resoure_copy.max_health = base_health
	resoure_copy.min_damage_fraction = base_min_damage_fraction
	resoure_copy.max_damage = base_max_damage
	resoure_copy.ally_action_value = base_ally_action_value
	for base_resist in base_resist_array:
		resoure_copy.resists.append(base_resist.get_resource())
	return resoure_copy


func adjust_health(delta: int):
	health = clampi(health + delta, 0, max_health)
	health_changed.emit(health, delta)
	if health == 0:
		health_depleted.emit()


func get_deaths_door_resist() -> Resist:
	for resist in resists:
		if resist.type == Resist.Types.DEATHS_DOOR:
			return resist
	return null


func generate_damage_value():
	return randi_range(get_min_damage(), max_damage)


func get_min_damage() -> int:
	return ceili(max_damage * min_damage_fraction.x / min_damage_fraction.y)


func get_foe_action_text_as_label() -> RichTextLabel:
	var text := String(foe_action_name) + ": " + String(foe_action_text)
	var label := _get_label_with_info(text)
	label.name = "FoeActionLabel"
	return label


func get_ally_action_text_as_label() -> RichTextLabel:
	var text := String(ally_action_name) + ": " + String(ally_action_text)
	var label := _get_label_with_info(text)
	label.name = "AllyActionLabel"
	return label


func _get_label_with_info(text: String) -> RichTextLabel:
	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	var tags := {
		"$aav": {
			"append_text": [str(ally_action_value)]
		},
		"$dmg": {
			"append_text": [str(get_min_damage()) + "-" + str(max_damage)]
		},
		"$shield": {
			"add_image": [Preloader.token_shield.icon_texture, 24, 24]
		},
		"$attack": {
			"add_image": [Preloader.token_attack.icon_texture, 24, 24]
		},
		"$antishield": {
			"add_image": [Preloader.token_antishield.icon_texture, 24, 24]
		},
		"$fire": {
			"add_image": [Preloader.token_fire.icon_texture, 24, 24]
		},
		"$blind": {
			"add_image": [Preloader.token_blind.icon_texture, 24, 24]
		},
		"$antiattack": {
			"add_image": [Preloader.token_antiattack.icon_texture, 24, 24]
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


func get_action_name(action_type: Battler.ActionTypes) -> String:
	if action_type == Battler.ActionTypes.ATTACK:
		return "[color=#" + Global.TargetColors.FOE_BATTLER.to_html(false) + "]" + foe_action_name + "[/color]"
	else:
		return "[color=#" + Global.TargetColors.ALLY_BATTLER.to_html(false) + "]" + ally_action_name + "[/color]"
