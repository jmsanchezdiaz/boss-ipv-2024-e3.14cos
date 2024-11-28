extends Node

static func select(player: Player):
	if player:
		player.has_flashlight = true;

static func deselect(player: Player):
	if player:
		player.has_flashlight = false;
	
