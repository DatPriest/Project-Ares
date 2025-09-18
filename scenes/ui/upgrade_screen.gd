extends CanvasLayer

signal upgrade_selected(upgrade)

@export var upgrade_card_scene: PackedScene
@onready var card_container: HBoxContainer = $%CardContainer
@onready var animation_player = $AnimationPlayer

func _ready():
	get_tree().paused = true

func set_ability_upgrades(upgrades: Array[AbilityUpgrade]):
	if upgrades.size() == 0:
		push_warning("UpgradeScreen: No upgrades provided, closing screen")
		_close_screen()
		return
		
	var delay = 0
	for upgrade in upgrades:
		if upgrade == null:
			push_warning("UpgradeScreen: Null upgrade found, skipping")
			continue
			
		var card_instance = upgrade_card_scene.instantiate()
		card_container.add_child(card_instance)
		card_instance.set_ability_upgrade(upgrade)
		card_instance.play_in(delay)
		card_instance.selected.connect(on_upgrade_selected.bind(upgrade))
		delay += .4

func _close_screen():
	get_tree().paused = false
	queue_free()
func on_upgrade_selected(upgrade: AbilityUpgrade):
	upgrade_selected.emit(upgrade)
	animation_player.play("out")
	await animation_player.animation_finished
	get_tree().paused = false
	queue_free()
