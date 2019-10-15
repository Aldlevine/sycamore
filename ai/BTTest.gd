extends BT

export var _target: NodePath

onready var character: Character = get_parent()
onready var target: Character = get_node(_target)
onready var vision := $"../Vision"
onready var initial_position = character.global_position
onready var initial_level = character.current_level

var last_known_target_pos = null

func _ready():
  root = sequence([
    when_eq(vision, "can_see_target", true, run_after_seconds(0.125, action(fn("move_to_target")))),
    when_neq("last_known_target_pos", null, series([
      action(fn("move_to_last_known_target_pos")),
      run_after_seconds(0.125, action(fn("move_to_target"))),
      run_after_seconds(0.5, set_value("last_known_target_pos", null)),
    ])),
    run_after_seconds(5, action(fn("move_to_initial_pos")))
  ])

func _process(delta: float):
  return tick(delta)
  
func move_to_target(_delta):
  character.is_running = (target.is_running && target.direction.length_squared() > 0) || !vision.can_see_target
  last_known_target_pos = target.global_position
  character.move_to(target.global_position, target.current_level)
    
func move_to_last_known_target_pos(_delta):
  var move_vector = (last_known_target_pos - character.position)
  move_vector += move_vector.normalized() * 128
  character.move_to(vision.next_visible_point(character.position + move_vector))
  
func move_to_initial_pos(_delta):
  character.is_running = false
  character.move_to(initial_position, initial_level)