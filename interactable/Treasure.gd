extends RigidBody2D

export(Texture) var treasure_texture
export(float) var hold_for_seconds = 0.8

var is_open = false

func _ready():
  if $Interactable.connect("interact", self, "_on_interact") != OK:
    print(name + " couldn't connect")

func _on_interact(character: Character):
  if !is_open:
    print("Hooray, "+character.name+" found treasure!")
    is_open = true
    $Sprite.frame = 1
    if character.has_node("GetTreasure"):
      var getTreasure: GetTreasure = character.get_node("GetTreasure")
      getTreasure.play_anim(treasure_texture, hold_for_seconds)
  else:
    print("You've already found what's inside")
