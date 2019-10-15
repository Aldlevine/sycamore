extends Node2D

onready var character: Character = get_parent()

#var accepts_input := true

func _process(_delta):
  handle_input()
  
func handle_input():
#  if !accepts_input: return
  var new_direction = Vector2()
#  if !InputLock.accepts_input(character):
#    character.path = null
#    character.is_running = false
#  else:  
  if InputLock.accepts_input(character):
    if Input.is_action_pressed("player_left"):
      new_direction.x -= 1
    if Input.is_action_pressed("player_right"):
      new_direction.x += 1
    if Input.is_action_pressed("player_up"):
      new_direction.y -= 1
    if Input.is_action_pressed("player_down"):
      new_direction.y += 1
    character.is_running = Input.is_action_pressed("player_run")
  else:
    character.is_running = false
  
  if character.path == null || new_direction != Vector2():
    character.cancel_path()
    character.direction = new_direction