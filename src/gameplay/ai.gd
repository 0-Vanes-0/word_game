class_name AI
extends Object

const NOT_ATTACKING_MOBS: Array[Battler.Types] = []


static func pick_target(current_battler: Battler, all_battlers: Array[Battler]) -> int:
	assert(current_battler.type in Battler.ENEMIES)
	var heroes: Array[Battler] = all_battlers.filter(func(b: Battler): return b.type in Battler.HEROES and b.is_alive)
	var enemies: Array[Battler] = all_battlers.filter(func(b: Battler): return b.type in Battler.ENEMIES and b.is_alive and b.index != current_battler.index)
	
	if not current_battler.type in NOT_ATTACKING_MOBS:
		for i in range(heroes.size()-1,-1,-1):
			if heroes[i].token_handler.get_first_token(Token.Types.TAUNT) != null:
				return heroes[i].index
			if heroes[i].token_handler.get_first_token(Token.Types.REACHLESS) != null:
				heroes.remove_at(i)
	
	if heroes.is_empty():
		return -1
	
	match current_battler.type:
		Battler.Types.ENEMY_GOBLIN:
			# Strategy: Attack priority on hero with lowest hp
			var chances: Array[int] = []
			
			var lowest := _get_lowest_health(heroes)
			for i in heroes.size():
				if heroes[i].stats.health == lowest:
					chances.append(100)
				else:
					chances.append(10)
			
			return (RouletteWheel.spin(heroes, chances) as Battler).index
		
		Battler.Types.ENEMY_FIRE_IMP:
			# Strategy: Attack priority on hero with highest hp
			var chances: Array[int] = []
			
			var highest := _get_highest_health(heroes)
			for i in heroes.size():
				if heroes[i].token_handler.get_first_token(Token.Types.TAUNT) != null:
					return heroes[i].index
				if heroes[i].stats.health == highest:
					chances.append(100)
				else:
					chances.append(10)
			
			return (RouletteWheel.spin(heroes, chances) as Battler).index
		
		Battler.Types.ENEMY_BEAR:
			# Strategy: Random attack and defends if someone has hp <50% and is without SHIELD
			var chances: Array[int] = []
			
			for i in heroes.size():
				chances.append(100)
			for i in enemies.size():
				if enemies[i].stats.health < enemies[i].stats.base_health * 0.5 and enemies[i].token_handler.get_first_token(Token.Types.SHIELD) == null:
					chances.append(500)
				else:
					chances.append(10)
			
			print_debug("BEAR CHANCES:", chances)
			var all_alive: Array[Battler] = heroes.duplicate(); all_alive.append_array(enemies)
			return (RouletteWheel.spin(all_alive, chances) as Battler).index
		
		Battler.Types.ENEMY_SNAKE:
			# Strategy: 50/50 attacks hero or defends
			var chances: Array[int] = []
			
			for i in heroes.size():
				chances.append(100 / heroes.size())
			chances.append(100) # itself
			
			print_debug("SNAKE CHANCES:", chances)
			heroes.append(current_battler)
			return (RouletteWheel.spin(heroes, chances) as Battler).index
		
		Battler.Types.ENEMY_ORC:
			# Strategy: buff himself until gets 3+ positive tokens, then share them with his ally
			var chances: Array[int] = []
			
			var pos_tokens_count: int = 0
			for t in current_battler.tokens:
				if t.type in Token.POSITIVE_TYPES:
					pos_tokens_count += 1
			
			for i in heroes.size():
				if pos_tokens_count >= 3 and enemies.size() > 0:
					chances.append(5)
				else:
					chances.append(100 / heroes.size())
			for i in enemies.size():
				if pos_tokens_count >= 3:
					chances.append(100 / enemies.size())
				else:
					chances.append(0)
			
			print_debug("ORC CHANCES:", chances)
			var all_alive: Array[Battler] = heroes.duplicate(); all_alive.append_array(enemies)
			return (RouletteWheel.spin(all_alive, chances) as Battler).index
		
		Battler.Types.ENEMY_JINN:
			# Strategy: adds antiattack to hero OR heals 15% + removes neg token (higher chances of this if neg tokens >= 2)
			var chances: Array[int] = []
			
			for i in heroes.size():
				chances.append(100 / heroes.size())
			for i in enemies.size():
				var neg_tokens_count: int = 0
				for t in enemies[i].tokens:
					if t.type in Token.NEGATIVE_TYPES:
						neg_tokens_count += 1
				if neg_tokens_count >= 2:
					chances.append(300 / enemies.size())
				else:
					chances.append(100 / enemies.size())
			
			print_debug("JINN CHANCES:", chances)
			var all_alive: Array[Battler] = heroes.duplicate(); all_alive.append_array(enemies)
			return (RouletteWheel.spin(all_alive, chances) as Battler).index
		
		_:
			return (heroes.pick_random() as Battler).index


static func do_action(current_battler: Battler, target_battler: Battler, target_group: Array[Battler] = []):
	assert(current_battler.type in Battler.ENEMIES)
	var action_type := Battler.ActionTypes.ATTACK if target_battler.type in Battler.HEROES else Battler.ActionTypes.ALLY
	
	if action_type == Battler.ActionTypes.ATTACK:
		current_battler.do_attack_action(target_battler, target_group)
		
		match current_battler.type:
			Battler.Types.ENEMY_FIRE_IMP:
				target_battler.token_handler.add_token(Token.Types.FIRE, 2)
			Battler.Types.ENEMY_SNAKE:
				target_battler.token_handler.add_token(Token.Types.BLIND, 1)
				target_battler.token_handler.add_token(Token.Types.ANTIATTACK, 1)
			Battler.Types.ENEMY_ORC:
				var token_type: Token.Types = [Token.Types.SHIELD, Token.Types.ATTACK, Token.Types.STIM].pick_random()
				current_battler.token_handler.add_token(token_type, 2)
			Battler.Types.ENEMY_JINN:
				target_battler.token_handler.add_token(Token.Types.ANTIATTACK, 1)
	
	elif action_type == Battler.ActionTypes.ALLY:
		match current_battler.type:
			Battler.Types.ENEMY_BEAR:
				target_battler.token_handler.add_token(Token.Types.SHIELD, 2)
				current_battler.token_handler.add_token(Token.Types.ANTISHIELD, 2)
			Battler.Types.ENEMY_SNAKE:
				current_battler.token_handler.add_token(Token.Types.DODGE, 2)
			Battler.Types.ENEMY_ORC:
				for t in current_battler.tokens:
					if t.type in Token.POSITIVE_TYPES:
						target_battler.token_handler.add_token(t.type, 1)
						t.queue_outofturns()
			Battler.Types.ENEMY_JINN:
				var heal := ceili(target_battler.stats.base_health * (0.1 * current_battler.stats.ally_action_value))
				target_battler.stats.adjust_health(heal)
				var neg_tokens: Array[Token] = []
				for t in target_battler.tokens:
					if t.type in Token.NEGATIVE_TYPES:
						neg_tokens.append(t)
				(neg_tokens.pick_random() as Token).queue_outofturns()
	
	(current_battler.stats as EnemyBattlerStats).reduce_reward()
	current_battler.set_coin_counter( (current_battler.stats as EnemyBattlerStats).reward )


static func _get_lowest_health(battlers: Array[Battler]) -> int:
	var lowest := -1
	for i in battlers.size():
		if lowest == -1 or battlers[i].stats.health < lowest:
			lowest = battlers[i].stats.health
	return lowest


static func _get_highest_health(battlers: Array[Battler]) -> int:
	var highest := -1
	for i in battlers.size():
		if highest == -1 or battlers[i].stats.health > highest:
			highest = battlers[i].stats.health
	return highest
