tool
extends EditorImportPlugin
class_name ScenarioImportPlugin

func get_importer_name():
	return "game.scenarios"

func get_visible_name():
	return "Combat Scenarios"

func get_recognized_extensions():
	return ["scenario"]

func get_save_extension():
	return "tres"

func get_resource_type():
	return "Resource"

func get_preset_count():
	return 1

func get_preset_name(_preset):
	return "Scenarios"

func get_import_options(preset):
	return []

func import(src_path: String, 
	dest_path: String,
	options: Dictionary, 
	r_platform_variants: Array, 
	r_gen_files: Array
):
	var in_file := File.new()
	var err := in_file.open(src_path, File.READ)
	if err != OK:
		print_debug("Inventory: failed to open %s, error code %d" 
			% [src_path, err])
		return err
	
	var text := in_file.get_as_text()
	in_file.close()
	
	var jpr := JSON.parse(text)
	if !jpr.error == OK:
		print_debug("Scenario: file %s was not valid json.\n[Line %d] %s"
			% [src_path, jpr.error_line, jpr.error_string])
		return jpr.error
	var json = jpr.result
	var c := CombatScenario.new()
	c.waves = json.waves
	ResourceSaver.save("%s.%s" % [dest_path, get_save_extension()], c)
	return OK
