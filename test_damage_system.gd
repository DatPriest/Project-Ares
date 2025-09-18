extends Node

# Simple test script to validate the DamageComponent system
# This script can be run in the Godot editor to test the damage system

func _ready():
	print("Testing DamageComponent system...")
	test_damage_component()
	test_hurtbox_component()
	test_drop_components()
	print("All tests completed!")

func test_damage_component():
	print("Testing DamageComponent...")
	
	# Create test nodes
	var health_component = HealthComponent.new()
	health_component.max_health = 10.0
	add_child(health_component)
	
	var damage_component = DamageComponent.new()
	damage_component.health_component = health_component
	damage_component.experience_reward = 5.0
	add_child(damage_component)
	
	# Connect to GameEvents to verify signal emission
	var signal_received = false
	var experience_amount = 0.0
	
	GameEvents.enemy_killed.connect(func(exp): 
		signal_received = true
		experience_amount = exp
	)
	
	# Test damage application
	damage_component.apply_damage(5.0)
	assert(health_component.current_health == 5.0, "Damage not applied correctly")
	
	# Test death
	damage_component.apply_damage(5.0)
	assert(health_component.current_health == 0.0, "Health not reduced to zero")
	
	# Verify GameEvents signal was emitted
	await get_tree().process_frame
	assert(signal_received, "GameEvents.enemy_killed not emitted")
	assert(experience_amount == 5.0, "Incorrect experience amount")
	
	print("✓ DamageComponent tests passed")

func test_hurtbox_component():
	print("Testing HurtboxComponent integration...")
	
	# Create test nodes  
	var health_component = HealthComponent.new()
	health_component.max_health = 10.0
	add_child(health_component)
	
	var damage_component = DamageComponent.new()
	damage_component.health_component = health_component
	add_child(damage_component)
	
	var hurtbox = HurtboxComponent.new()
	hurtbox.health_component = health_component
	hurtbox.damage_component = damage_component
	add_child(hurtbox)
	
	var hitbox = HitboxComponent.new()
	hitbox.damage = 3.0
	add_child(hitbox)
	
	# Simulate area entered
	hurtbox.on_area_entered(hitbox)
	
	assert(health_component.current_health == 7.0, "HurtboxComponent damage not applied correctly")
	
	print("✓ HurtboxComponent tests passed")

func test_drop_components():
	print("Testing drop component integration...")
	
	# Create test nodes
	var health_component = HealthComponent.new()
	health_component.max_health = 1.0
	add_child(health_component)
	
	var damage_component = DamageComponent.new()
	damage_component.health_component = health_component
	add_child(damage_component)
	
	var vial_drop = VialDropComponent.new()
	vial_drop.damage_component = damage_component
	vial_drop.drop_percent = 1.0  # Guarantee drop for testing
	add_child(vial_drop)
	
	# Test that died signal is connected
	var died_signal_received = false
	damage_component.died.connect(func(): died_signal_received = true)
	
	# Trigger death
	damage_component.apply_damage(1.0)
	
	await get_tree().process_frame
	assert(died_signal_received, "Died signal not emitted")
	
	print("✓ Drop component tests passed")