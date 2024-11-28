extends Node

static func select(player: Player):
	if player:
		player.selected_weapon = "crowbar"
		player.selected_weapon_damage = 30.0

static func deselect(player:Player):
	if "crowbar" == player.selected_weapon:
		player.selected_weapon = null;
