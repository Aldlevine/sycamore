extends Node2D

onready var player = get_parent()

func _input(event):
  if !InputLock.accepts_input(player): return
  if event is InputEventMouseButton:
    if event.button_index == BUTTON_LEFT && event.pressed:
      player.move_to(get_global_mouse_position(), -1)
      $Line2D.points = player.path
      
func _process(_delta):
  $Line2D.position = -player.global_position