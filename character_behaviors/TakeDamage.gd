extends Node2D

class_name TakeDamage

signal take_damage(from, power)

onready var character = get_parent()
var health: Health

func _ready():
  if character.has_node("Health"):
    health = character.get_node("Health")

func take_damage(from: Character, power: int):
  if health:
    health.damage(compute_damage(power))
  emit_signal("take_damage", from, power)
  
func compute_damage(power: int) -> int:
  return power