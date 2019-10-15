extends Node

var data = {
  version = 0,
  player_name = "",
}

func save_data() -> Dictionary:
  return data

func load_data(d: Dictionary):
  for key in d.keys():
    data[key] = d[key]