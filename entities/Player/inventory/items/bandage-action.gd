extends Node

static func select(player: Player):
	if player:
		player.recover_health(25.0)
