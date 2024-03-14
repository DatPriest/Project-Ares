extends Node

signal experience_vial_collected(number: float)
signal ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary)
signal enemy_killed(experience_amount: float)
signal player_damaged
signal resource_collected(resource: DropResource)

func emit_experience_vial_collected(number: float):
	experience_vial_collected.emit(number)
	
func emit_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	ability_upgrade_added.emit(upgrade, current_upgrades)

func emit_enemy_killed(experience_amount: float):
	enemy_killed.emit(experience_amount)

func emit_resource_collected(resource: DropResource):
	resource_collected.emit(resource)

func emit_player_damaged():
	player_damaged.emit()
