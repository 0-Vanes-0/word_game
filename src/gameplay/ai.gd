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
					chances.append(300)
				else:
					chances.append(10)
			
			print_debug(chances)
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
	
	elif action_type == Battler.ActionTypes.ALLY:
		match current_battler.type:
			Battler.Types.ENEMY_BEAR:
				target_battler.token_handler.add_token(Token.Types.SHIELD, 2)
				current_battler.token_handler.add_token(Token.Types.ANTISHIELD, 2)
	
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
