extends Area2D

class_name Interactable

signal interact(object)

func _ready():
  if connect("body_entered", self, "_body_entered") != OK:
    print("%s could not connect", name)
  if connect("body_exited", self, "_body_exited") != OK:
    print("%s could not connect", name)

func interact(object):
  emit_signal("interact", object)
  
func _body_entered(body: PhysicsBody2D):
  if body.has_node("Interaction"):
    var interaction = body.get_node("Interaction")
    if interaction is Interaction:
      interaction.interactable = self
    
func _body_exited(body: PhysicsBody2D):
  if body.has_node("Interaction"):
    var interaction = body.get_node("Interaction")
    if interaction is Interaction && interaction.interactable == self:
      interaction.interactable = null