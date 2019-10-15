extends Character

class_name Player

#var accepts_input := true
#
#func _process(_delta):
#  handle_input()
#
#func handle_input():
#  if !accepts_input: return
#  var new_direction = Vector2()
#  if Input.is_action_pressed("player_left"):
#    new_direction.x -= 1
#  if Input.is_action_pressed("player_right"):
#    new_direction.x += 1
#  if Input.is_action_pressed("player_up"):
#    new_direction.y -= 1
#  if Input.is_action_pressed("player_down"):
#    new_direction.y += 1
#  is_running = Input.is_action_pressed("player_run")
#
#  if path == null || new_direction != Vector2():
#    cancel_path()
#    direction = new_direction
#
#func move_to (point: Vector2):
#  .move_to(point)
##  accepts_input = false
#  yield(self, "reached_target")
##  accepts_input = true