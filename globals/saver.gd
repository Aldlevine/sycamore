extends Node

const SAVE_ROOT = "user://save/"

func save_global_data():
  var file = File.new()
  file.open(SAVE_ROOT + "global.json", File.WRITE)
  file.store_string(to_json(GlobalData.save_data()))
  file.close()
  
func load_global_data():
  var file = File.new()
  file.open(name, File.READ)
  GlobalData.load_data(parse_json(file.get_as_text()))