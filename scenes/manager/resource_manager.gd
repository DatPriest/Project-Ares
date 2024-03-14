extends Node

var player_resources = {}

func _ready():
	GameEvents.resource_collected.connect(on_resource_collected)

func on_resource_collected(resource: DropResource):
	var resource_id = resource.id
	if resource_id in player_resources:
		player_resources[resource_id] += 1
		print(player_resources[resource_id])
	else:
		player_resources[resource_id] = 1
		print(player_resources[resource_id])

# Example function to use a resource
func use_resource(resource_id: String, amount: int = 1) -> bool:
	if resource_id not in player_resources or player_resources[resource_id] < amount:
		return false  # Not enough resources
	player_resources[resource_id] -= amount
	return true  # Resource used successfully
