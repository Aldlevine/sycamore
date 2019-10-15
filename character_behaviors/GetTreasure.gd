extends Node2D

class_name GetTreasure

onready var player = get_parent()

func _ready():
  $Sprite.texture = null
  player.connect("animation_finished", self, "_on_animation_finished")

func play_anim(texture: Texture, hold_for_seconds: float = 0):
  if texture:
# warning-ignore:integer_division
    $Sprite.offset.y = texture.get_height() / -2
  $Sprite.texture = texture
  player.play_anim_facing("get_treasure", hold_for_seconds)
  player.can_attack = false
  player.allow_movement = false
  
func _on_animation_finished(anim_name: String):
  if anim_name.begins_with("get_treasure"):
    $Sprite.texture = null
    player.can_attack = true
    player.allow_movement = true