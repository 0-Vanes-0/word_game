class_name LevelUpContainer
extends Control

@export var coins_icon_label: IconLabel
@export var knight_button: Button
@export var knight_level_label: Label
@export var knight_health: IconLabel
@export var knight_damage: IconLabel
@export var robber_button: Button
@export var robber_level_label: Label
@export var robber_health: IconLabel
@export var robber_damage: IconLabel
@export var mage_button: Button
@export var mage_level_label: Label
@export var mage_health: IconLabel
@export var mage_damage: IconLabel



func _ready() -> void:
	assert(coins_icon_label and knight_button and robber_button and mage_button
			and knight_health and knight_damage and robber_health and robber_damage
			and mage_health and mage_damage)
	
	self.visibility_changed.connect(
			func():
				if self.visible:
					update_content()
	)
	knight_button.pressed.connect(func(): _on_upgrade_button_pressed(Battler.Types.HERO_KNIGHT))
	robber_button.pressed.connect(func(): _on_upgrade_button_pressed(Battler.Types.HERO_ROBBER))
	mage_button.pressed.connect(func(): _on_upgrade_button_pressed(Battler.Types.HERO_MAGE))


func update_content():
	var knight := Preloader.stats_knight as PlayerBattlerStats
	var robber := Preloader.stats_robber as PlayerBattlerStats
	var mage := Preloader.stats_mage as PlayerBattlerStats
	var knight_level: int = Global.get_player_level(Battler.Types.HERO_KNIGHT)
	var robber_level: int = Global.get_player_level(Battler.Types.HERO_ROBBER)
	var mage_level: int = Global.get_player_level(Battler.Types.HERO_MAGE)
	var next_knight_payment: int = GameInfo.get_coins_by_level(knight_level + 1)
	var next_robber_payment: int = GameInfo.get_coins_by_level(robber_level + 1)
	var next_mage_payment: int = GameInfo.get_coins_by_level(mage_level + 1)
	
	coins_icon_label.set_text(str( Global.get_player_coins() ))
	
	knight_button.text = _get_text(knight_level + 1, next_knight_payment)
	knight_button.disabled = not GameInfo.has_coins(next_knight_payment)
	knight_level_label.text = str(knight_level) + " ур."
	knight_health.set_text(knight.base_health + knight.get_health_addition(knight_level))
	var knight_max_dmg: int = knight.base_max_damage + knight.get_damage_addition(knight_level)
	var knight_min_dmg: int = ceili(knight_max_dmg * knight.base_min_damage_fraction.x / knight.base_min_damage_fraction.y)
	knight_damage.set_text(str(knight_min_dmg) + "-" + str(knight_max_dmg))
	
	robber_button.text = _get_text(robber_level + 1, next_robber_payment)
	robber_button.disabled = not GameInfo.has_coins(next_robber_payment)
	robber_level_label.text = str(robber_level) + " ур."
	robber_health.set_text(robber.base_health + robber.get_health_addition(robber_level))
	var robber_max_dmg: int = robber.base_max_damage + robber.get_damage_addition(robber_level)
	var robber_min_dmg: int = ceili(robber_max_dmg * robber.base_min_damage_fraction.x / robber.base_min_damage_fraction.y)
	robber_damage.set_text(str(robber_min_dmg) + "-" + str(robber_max_dmg))
	
	mage_button.disabled = not GameInfo.has_coins(next_mage_payment)
	mage_button.text = _get_text(mage_level + 1, next_mage_payment)
	mage_level_label.text = str(mage_level) + " ур."
	mage_health.set_text(mage.base_health + mage.get_health_addition(mage_level))
	var mage_max_dmg: int = mage.base_max_damage + mage.get_damage_addition(mage_level)
	var mage_min_dmg: int = ceili(mage_max_dmg * mage.base_min_damage_fraction.x / mage.base_min_damage_fraction.y)
	mage_damage.set_text(str(mage_min_dmg) + "-" + str(mage_max_dmg))


func _on_upgrade_button_pressed(hero_type: Battler.Types):
	var hero_level: int = Global.get_player_level(hero_type)
	var coins_to_spent: int = GameInfo.get_coins_by_level(hero_level + 1)
	if GameInfo.pay_coins(coins_to_spent):
		Global.set_player_level(hero_type, hero_level + 1)
		update_content()


func _get_text(level: int, coins: int) -> String:
	return " Улучшить до " + str(level) + " ур: " + str(coins) + " "


func _on_back_button_pressed() -> void:
	self.hide()
