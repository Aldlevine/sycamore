extends Node

export var show_debug := false setget set_show_debug

func _ready():
  set_show_debug(show_debug)

func set_show_debug(val: bool):
  show_debug = val
  for node in get_tree().get_nodes_in_group('debug_visible'):
    node.visible = show_debug
