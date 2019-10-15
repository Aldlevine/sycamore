extends TileMap

func _ready():
  var points = get_used_cells()
  for point in points:
    var area = Area2D.new()
    var collision_shape = CollisionShape2D.new()
    var id = get_cellv(point)
    var shape := tile_set.tile_get_shape(id, 0) 
    collision_shape.shape = shape
    area.collision_layer = collision_layer
    area.add_child(collision_shape)
    area.global_position = map_to_world(point)
    add_child(area)
  