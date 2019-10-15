extends Node

var parent: Node2D

func _ready():
  parent = get_parent()
  assert parent is Node2D

func _process(_delta):
  if (parent):
    parent.position.x = round(parent.position.x)
    parent.position.y = round(parent.position.y)
