class_name TokenHandler
extends Node

var battler: Battler


func _ready() -> void:
	assert(get_parent() != null and get_parent() is Battler)
	battler = get_parent() as Battler


func add_token(token_type: Token.Types, amount: int = 1):
	if (token_type == Token.Types.LESS_DEATH_RESIST or token_type == Token.Types.MORE_DEATH_RESIST) and battler.stats.get_deaths_door_resist() == null:
		return
	
	var having_amount: int = 0
	for t in battler.tokens:
		if t.type == token_type:
			having_amount += 1
		if amount > 0 and (
				t.type == Token.Types.ANTIATTACK and token_type == Token.Types.ATTACK
				or 
				t.type == Token.Types.ATTACK and token_type == Token.Types.ANTIATTACK
				or
				t.type == Token.Types.ANTISHIELD and token_type == Token.Types.SHIELD
				or
				t.type == Token.Types.SHIELD and token_type == Token.Types.ANTISHIELD
			):
			amount -= 1
			t.queue_outofturns()
	
	var to_add: int
	if Token.get_max_amount(token_type) == 0:
		to_add = amount
	else:
		to_add = mini(Token.get_max_amount(token_type) - having_amount, amount)
	
	for i in to_add:
		var token := Token.create(token_type, battler)
		battler.tokens.append(token)


func apply_tokens(for_what_moment: Token.ApplyMoments, should_be_spent := true):
	var applied_types: Array[Token.Types] = []
	for t in battler.tokens:
		if t.apply_moment == for_what_moment and not applied_types.has(t.type):
			applied_types.append(t.type)
			t.apply_token_effect(should_be_spent)


func update_token_labels():
	for t_label: TokenLabel in battler.tokens_container.get_children():
		battler.tokens_container.remove_child(t_label) # For some reason we need this line, do not remove it
		t_label.queue_free()
	
	for token in battler.tokens:
		if not token.is_hidden and token.lifetime_turns > 0:
			var current_t_label: TokenLabel
			var found_label: bool = false
			for t_label: TokenLabel in battler.tokens_container.get_children():
				if t_label.token.type == token.type:
					found_label = true
					current_t_label = t_label
					break
			
			if not found_label:
				current_t_label = TokenLabel.create()
				current_t_label.token = token
				current_t_label.amount = 1
				current_t_label.duration = token.lifetime_turns
				battler.tokens_container.add_child(current_t_label)
				current_t_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			else:
				current_t_label.amount += 1
				current_t_label.duration = max(token.lifetime_turns, current_t_label.duration)
	
	for t_label: TokenLabel in battler.tokens_container.get_children():
		t_label.update_info()


func check_tokens(for_what_moment: Token.ApplyMoments = Token.ApplyMoments.NONE):
	battler.pre_damage = 0
	battler.pre_heal = 0
	battler.stun_turns = 0
	
	for t in battler.tokens:
		if t.apply_moment == for_what_moment and not t.is_need_delete():
			t.apply_token_effect()
		if for_what_moment == Token.ApplyMoments.ON_TURN_START:
			t.adjust_turn_count()
	
	if battler.pre_heal > 0:
		battler.stats.adjust_health(battler.pre_heal)
		await get_tree().create_timer(0.25).timeout
	if battler.pre_damage > 0:
		battler.stats.adjust_health(- battler.pre_damage)
	
	for i in range(battler.tokens.size()-1, -1, -1):
		if battler.tokens[i].is_need_delete():
			battler.tokens.remove_at(i)
	
	update_token_labels()


func get_first_token(type: Token.Types) -> Token:
	for t in battler.tokens:
		if t.type == type:
			return t
	return null
