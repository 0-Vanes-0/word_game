class_name AI
extends Object


static func pick_target(current_battler: Battler, all_battlers: Array[Battler]) -> int:
	assert(current_battler.type in Battler.ENEMIES)
	var heroes: Array[Battler] = all_battlers.filter(func(b: Battler): return b.type in Battler.HEROES and b.is_alive)
	var enemies: Array[Battler] = all_battlers.filter(func(b: Battler): return b.type in Battler.ENEMIES and b.is_alive)
	
	match current_battler.type:
		Battler.Types.ENEMY_GOBLIN:
			# Strategy: Attack priority on hero with lowest hp
			var chances: Array[int] = []
			chances.resize(heroes.size())
			
			var lowest := _get_lowest_health(heroes)
			for i in heroes.size():
				if heroes[i].token_handler.get_first_token(Token.Types.TAUNT) != null:
					return heroes[i].index
				if heroes[i].stats.health == lowest:
					chances[i] = 100
				else:
					chances[i] = 10
			
			return (RouletteWheel.spin(heroes, chances) as Battler).index
		
		Battler.Types.ENEMY_FIRE_IMP:
			# Strategy: Attack priority on hero with highest hp
			var chances: Array[int] = []
			chances.resize(heroes.size())
			
			var highest := _get_highest_health(heroes)
			for i in heroes.size():
				if heroes[i].token_handler.get_first_token(Token.Types.TAUNT) != null:
					return heroes[i].index
				if heroes[i].stats.health == highest:
					chances[i] = 100
				else:
					chances[i] = 10
			
			return (RouletteWheel.spin(heroes, chances) as Battler).index
		
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
				pass
	
	(current_battler.stats as EnemyBattlerStats).reduce_reward()


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
