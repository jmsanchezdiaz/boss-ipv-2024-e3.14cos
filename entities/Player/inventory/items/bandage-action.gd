extends Node

static func heal_player(player: Player):
	if player:
		player.health += 10.0
