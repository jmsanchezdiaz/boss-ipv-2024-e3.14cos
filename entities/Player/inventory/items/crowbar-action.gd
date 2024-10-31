extends Node

static func select(player: Player):
	if player:
		player.selected_weapon = "crowbar"
		player.selected_weapon_damage = 30.0
