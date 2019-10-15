extends KinematicBody2D

class_name Character

export var current_level := 1
export var walk_speed := 100
export var run_speed := 175
export var look_ahead := 8
export var point_radius := 16
export var _path_finder: NodePath

var level_position: Vector3 setget , get_level_position
var target_position := Vector2()
var direction := Vector2()
var velocity := Vector2()
var facing := 'down'
var allow_movement := true
# warning-ignore:unused_class_variable
var can_attack := true
var is_running := false
var current_anim = null
var current_anim_hold := 0.0

onready var map: PathFinder = get_node(_path_finder)
var path = null

signal path_complete
signal reached_target
signal animation_finished(anim_name)

func get_level_position() -> Vector3:
  return Vector3(global_position.x, global_position.y, current_level)

func _ready():
  if $AnimationPlayer.connect("animation_finished", self, "_on_animation_finished") != OK:
    print("%s cannot connect", name)
  LevelSwitcher.set_level(self, current_level)
  
func _process(delta):
  follow_path(delta)
  compute_position(delta)
  compute_facing()
  compute_anim_state()

func set_is_running(v: bool):
  is_running = v

func get_is_running() -> bool:
  return is_running

func play_anim(anim_name: String, hold_for_seconds: float = 0):
  if current_anim != null:
    stop_anim()
  current_anim = anim_name
  current_anim_hold = hold_for_seconds
  $AnimationPlayer.play(anim_name)
  
func play_anim_facing(anim_name: String, hold_for_seconds: float = 0):
  play_anim(anim_name + '_' + facing, hold_for_seconds)
  
func reface_anim(anim_name: String):
  var current_time = $AnimationPlayer.current_animation_position
  current_anim = anim_name + '_' + facing
  $AnimationPlayer.play(current_anim)
  $AnimationPlayer.seek(current_time)
  
func stop_anim():
  var anim_name = current_anim
  current_anim = null
  emit_signal("animation_finished", anim_name)

func _on_animation_finished(anim_name: String):
  if anim_name == current_anim:
    yield(get_tree().create_timer(current_anim_hold), "timeout")
    stop_anim()
  
func compute_anim_state():
  if current_anim:
    return
  if direction.length_squared() == 0:
    $AnimationPlayer.play("idle_" + facing)
  else:
    $AnimationPlayer.play("run_"+facing if is_running else "walk_"+facing)
    
func get_facing_direction(dir: Vector2) -> String:
  if dir.length_squared() > 0:
    if dir.abs().x >= dir.abs().y:
      if dir.x > 0:
        return "right"
      elif dir.x < 0:
        return "left"
    elif dir.abs().y > dir.abs().x:
      if dir.y < 0:
         return "up"
      elif dir.y > 0:
        return "down"
  return facing
  
func face_direction(dir: Vector2):
  facing = get_facing_direction(dir)
  
func face_point(point: Vector2):
  face_direction(global_position.direction_to(point))
  
func compute_facing():
  face_direction(direction)
  
func is_facing(dir: Vector2, strict: bool = false) -> bool:
  if strict:
    return facing == get_facing_direction(dir)
  else:
    match facing:
      "left": return dir.x < 0
      "right": return dir.x > 0
      "up": return dir.y < 0
      "down": return dir.y > 0
    
func follow_path (_delta: float):
  if path:
    target_position = path[0]
    if position.distance_to(target_position) < point_radius:
      path.remove(0)
      if path.size() == 0:
        path = null
        direction = Vector2()
        emit_signal("path_complete")
        return
    else:
      direction = avoid_obstacles(target_position).normalized()

func avoid_obstacles(target: Vector2) -> Vector2:
  # first, we need to check to see if there's anything in the way
  var target_vector = target - global_position
  # if there is, we need to alter our path around it
  if test_move(transform, target_vector.normalized() * look_ahead):
    # find all open paths within range
    var pi_8 = PI / 32
    var options = []
    for i in range(-24, 24, 1):
      var angle = pi_8 * i
      var new_target_vector = target_vector.rotated(angle)
      if !test_move(transform, new_target_vector.normalized() * look_ahead):
        options.append(new_target_vector)
    # now find the one that's the closest to our current direction
    var closest_angle = 2 * PI
    var closest_vector
    for option in options:
      var angle = abs(option.angle_to(direction))
      if angle < closest_angle:
        closest_angle = angle
        closest_vector = option
    if closest_vector:
      return closest_vector
  # otherwise, we're in the clear
  return target_vector
    
func compute_position(_delta: float):
  if !allow_movement: return
  var speed =  run_speed if is_running else walk_speed
  velocity = move_and_slide(direction * speed, Vector2())
  
func move_to (new_position, level = current_level):
  var from_point = self.level_position
  var to_point = Vector3(new_position.x, new_position.y, level)
  path = map.get_nav_path(from_point, to_point)
  if path:
#    path.append(new_position)
    yield(self, "path_complete")
  emit_signal("reached_target")

func cancel_path():
  path = null
  direction = Vector2()
  emit_signal("path_complete")
  