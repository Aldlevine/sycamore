extends RayCast2D

export var xray_vision := false
export var vision_radius := 128
export var _target: NodePath
onready var target: Character = get_node(_target)
onready var character: Character = get_parent()

var can_see_target := false

func _physics_process(_delta):
  can_see_target = check_can_see_target()

func check_can_see_target() -> bool:
  if !target: return false
  return can_see(target)
#  if !target: return false
#  if xray_vision: return global_position.distance_to(target.global_position) <= vision_radius
#
#  if character.current_level != target.current_level && no_vertical_obstacles():
#    collision_mask = Layers.set_bits(collision_mask, Layers.LevelVisibility[target.current_level])
#
#  var cast_vector = target.global_position - global_position
#  cast_to = cast_vector.normalized() * vision_radius
#  force_raycast_update()
#  var result = false
#  if is_colliding():
#    if get_collider() == target:
#      result = true
#
#  if character.current_level != target.current_level:
#    collision_mask = Layers.clear_bits(collision_mask, Layers.LevelVisibility[target.current_level])
#
#  return result
  
func can_see(tgt: Character) -> bool:
  if xray_vision: return global_position.distance_to(tgt.global_position) <= vision_radius
  
  if character.current_level != tgt.current_level && no_vertical_obstacles():
    collision_mask = Layers.set_bits(collision_mask, Layers.LevelVisibility[tgt.current_level])
    
  var cast_vector = tgt.global_position - global_position
  cast_to = cast_vector.normalized() * vision_radius
  force_raycast_update()
  var result = false
  if is_colliding():
    if get_collider() == tgt:
      result = true
      
  if character.current_level != tgt.current_level:
    collision_mask = Layers.clear_bits(collision_mask, Layers.LevelVisibility[tgt.current_level])
    
  return result

func next_visible_point(point: Vector2) -> Vector2:
  var cast_vector = point - global_position
  cast_to = cast_vector.normalized() * vision_radius
  force_raycast_update()
  if is_colliding():
    return get_collision_point()
  return point

func no_vertical_obstacles() -> bool:
  var areas = $Area2D.get_overlapping_areas()
  var min_level = min(character.current_level, target.current_level)
  var max_level = max(character.current_level, target.current_level)
  for i in range(areas.size()):
    var area: Area2D = areas[i]
    if (Layers.has_bits(area.collision_layer, Layers.VerticalVisibilityGroup)):
      var obstacle_level = Layers.VerticalVisibility.find(area.collision_layer)
      if obstacle_level > min_level && obstacle_level <= max_level:
        return false
  return true