extends Node2D

class_name Interaction

onready var parent: Character = get_parent()

var interactable

func _unhandled_input(event):
  if !InputLock.accepts_input(parent): return
  if event.is_action_pressed("player_interact"):
    if interactable && interactable.has_method("interact") && parent.is_facing(parent.global_position.direction_to(interactable.global_position)):
      interactable.interact(parent)