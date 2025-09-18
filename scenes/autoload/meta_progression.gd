extends Node

const SAVE_FILE_PATH = "user://game.save"


var save_data: Dictionary = {
	"meta_upgrade_currency": 0,
	"meta_upgrades": {}
}

func _ready():
	GameEvents.experience_vial_collected.connect(on_experience_collected)
	load_save_file()
	validate_meta_upgrades()
	
	
func load_save_file():
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	save_data = file.get_var()
	
	
func save():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(save_data)
	
func add_meta_upgrade(upgrade: MetaUpgrade):
	if not save_data["meta_upgrades"].has(upgrade.id):
		save_data["meta_upgrades"][upgrade.id] = {
			"quantity": 0
		}
	save_data["meta_upgrades"][upgrade.id]["quantity"] += 1
	save()
	
func on_experience_collected(number: float):
	save_data["meta_upgrade_currency"] += number
	save()

func get_upgrade_count(upgrade_id: String):
	if save_data["meta_upgrades"].has(upgrade_id):
		return save_data["meta_upgrades"][upgrade_id]["quantity"]
	return 0


func validate_meta_upgrades():
	print("[MetaProgression] Starting MetaUpgrade validation...")
	
	var meta_upgrade_resources: Array[MetaUpgrade] = []
	var resource_paths: Array[String] = []
	var validation_errors: Array[String] = []
	var used_ids: Dictionary = {}
	
	# Find all MetaUpgrade resource files
	var dir = DirAccess.open("res://resources/meta_upgrades/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var resource_path = "res://resources/meta_upgrades/" + file_name
				resource_paths.append(resource_path)
			file_name = dir.get_next()
	
	# Load and validate each MetaUpgrade resource
	for path in resource_paths:
		var resource = load(path)
		if resource is MetaUpgrade:
			meta_upgrade_resources.append(resource)
			_validate_single_meta_upgrade(resource, path, validation_errors, used_ids)
	
	# Report validation results
	if validation_errors.size() == 0:
		print("[MetaProgression] ✓ All %d MetaUpgrade resources are valid" % meta_upgrade_resources.size())
	else:
		push_warning("[MetaProgression] Found %d validation issues in MetaUpgrade resources:" % validation_errors.size())
		for error in validation_errors:
			push_warning("  • " + error)
		print("[MetaProgression] ⚠ Validation completed with %d warnings" % validation_errors.size())


func _validate_single_meta_upgrade(upgrade: MetaUpgrade, resource_path: String, validation_errors: Array[String], used_ids: Dictionary):
	var file_name = resource_path.get_file()
	
	# Validate ID
	if upgrade.id == null or upgrade.id.strip_edges() == "":
		validation_errors.append("Missing or empty ID in %s" % file_name)
	else:
		# Check for duplicate IDs
		if used_ids.has(upgrade.id):
			validation_errors.append("Duplicate ID '%s' found in %s (also in %s)" % [upgrade.id, file_name, used_ids[upgrade.id]])
		else:
			used_ids[upgrade.id] = file_name
	
	# Validate experience_cost
	if upgrade.experience_cost <= 0:
		validation_errors.append("Invalid experience_cost (%d) in %s - must be positive" % [upgrade.experience_cost, file_name])
	
	# Validate max_quantity
	if upgrade.max_quantity < 0:
		validation_errors.append("Invalid max_quantity (%d) in %s - must be non-negative" % [upgrade.max_quantity, file_name])
	
	# Validate title
	if upgrade.title == null or upgrade.title.strip_edges() == "":
		validation_errors.append("Missing or empty title in %s" % file_name)
	
	# Validate description
	if upgrade.description == null or upgrade.description.strip_edges() == "":
		validation_errors.append("Missing or empty description in %s" % file_name)
