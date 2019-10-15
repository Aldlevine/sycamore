extends Node2D

export var _target: NodePath
export var xray_vision := false

onready var character: Character = get_parent()
onready var target: Character = get_node(_target)
onready var vision := $"../Vision"
onready var initial_position = global_position

var last_known_target_pos = null
var is_idle := true
var is_searching := false
var is_wandering := false

var tic_start := -1

func _ready():
  if $TargetTimer.connect("timeout", self, "target_player") != OK:
    print('%s could not connect', name)

func target_player():
  if xray_vision || vision.can_see_target:
    clear_timer()
    is_searching = false
    is_wandering = false
    is_idle = false
    character.is_running = target.is_running && target.direction.length_squared() > 0
    last_known_target_pos = target.position
    if global_position.distance_to(target.position) > 32:
      character.move_to(target.position, target.current_level)
  elif !is_searching && last_known_target_pos:
    is_searching = true
    character.is_running = true
    var move_vector = (last_known_target_pos - character.position)
    move_vector += move_vector.normalized() * 128
    character.move_to(vision.next_visible_point(character.position + move_vector))
    yield(get_tree().create_timer(0.25), "timeout")
    is_searching = false
    character.move_to(target.position)
    last_known_target_pos = null
  elif !is_idle:
    if tic_for_seconds(5.0):
      character.is_running = false
      character.move_to(initial_position)
      is_idle = true
      
func clear_timer():
  tic_start = -1

func tic_for_seconds(seconds: float) -> bool:
  if tic_start == -1:
    tic_start = OS.get_ticks_msec()
  else:
    var diff = OS.get_ticks_msec() - tic_start
    if seconds * 1000 <= diff:
      return true
  return false