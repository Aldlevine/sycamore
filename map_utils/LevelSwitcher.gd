extends Area2D

# warning-ignore:unused_class_variable
export(String, "x", "y") var axis = "y"
export(int, "0", "1", "2", "3", "4") var negative
export(int, "0", "1", "2", "3", "4") var positive

func _ready():
  if connect("body_exited", self, "_body_exited") != OK:
    print(name + " couldn't connect")
  
func _body_exited(body: PhysicsBody2D):
  if body is Character:
    var dir = global_position.direction_to(body.global_position)
    var level = positive if dir[axis] > 0 else negative
    LevelSwitcher.set_level(body, level)
