extends Node2D

class_name Health

signal die

export var max_health := 10
onready var health: int = max_health
onready var character: Character = get_parent()

func damage(amount: int):
  health -= amount
  if health <= 0:
    emit_signal("die")
    die()
    
func die():
  character.queue_free()
  pass