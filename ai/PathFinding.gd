"""
An AStar path finder that supports multiple 2D levels
"""

extends Node2D

class_name PathFinder

export var level_height := 16

# Reference to a new AStar navigation grid node
onready var astar := AStar.new()

var tile_set: TileSet

var min_point = Vector2(INF, INF)
var max_point = Vector2(-INF, -INF)
var cell_size: Vector2
var size: Vector2
var scaled_size: Vector2

# the tile ids in the tile map corresponding to each level
var tile_level_ids := []
var cells := []

func _ready():
  _parse_tile_maps()
  _add_cells()
  _connect_cells()

func _parse_tile_maps():
  var tile_maps = get_children()
  if tile_maps.empty():
    return
    
  var tile_map_1: TileMap = tile_maps[0]
  cell_size = tile_map_1.cell_size
  tile_set = tile_map_1.tile_set
  
  tile_level_ids = [
    tile_set.find_tile_by_name("level-0"),
    tile_set.find_tile_by_name("level-1"),
    tile_set.find_tile_by_name("level-2"),
    tile_set.find_tile_by_name("level-3"),
    tile_set.find_tile_by_name("level-4")
  ]
  
  for i in range(0, tile_maps.size()):
    var map: TileMap = tile_maps[i]
    var used_cells := map.get_used_cells()
    for used_cell in used_cells:
      var cell := Cell.new()
      cell.tile_id = map.get_cellv(used_cell)
      var world_point = map.map_to_world(used_cell) + cell_size / 2
      if world_point.x < min_point.x: min_point.x = world_point.x
      if world_point.x > max_point.x: max_point.x = world_point.x
      if world_point.y < min_point.y: min_point.y = world_point.y
      if world_point.y > max_point.y: max_point.y = world_point.y
      cell.point = Vector3(world_point.x, world_point.y, i * level_height)
      cell.level = i
      cells.append(cell)
  size = max_point - min_point + cell_size * 2
  scaled_size = size / cell_size

func _add_cells():
  for cell in cells:
    if astar.has_point(_get_id_for_point(cell.point)):
      print("duplicate")
    astar.add_point(_get_id_for_point(cell.point), cell.point)
  
func _connect_cells():
  for cell in cells:
    var cell_id = _get_id_for_point(cell.point)
    # Check all adjacent points in level
    for x in range(-1, 2):
      for y in range(-1, 2):
        # skip the current cell
        # TODO: update this so diagonals are only connected if they share 2 adjacent cells
        if x == 0 && y == 0: continue
        var offset = Vector3(x * cell_size.x, y * cell_size.y, 0)
        var target_id = _get_id_for_point(cell.point + offset)
        if cell_id != target_id:
          if x != 0 && y != 0:
            # diagonal
            var diag_offset = offset
            diag_offset.y = 0
            var adj_id = _get_id_for_point(cell.point + diag_offset)
            if !astar.has_point(adj_id): continue
            diag_offset = offset
            diag_offset.x = 0
            adj_id = _get_id_for_point(cell.point + diag_offset)
            if !astar.has_point(adj_id): continue
          if astar.has_point(target_id):
            astar.connect_points(cell_id, target_id, true)
    # If tile_level_id isn't on the cell's level, then it's a
    # connection to another level, and we should find the
    # corresponding point and connect. These are one way
    var cell_tile_z = _get_tile_z(cell.tile_id)
    if cell.point.z != cell_tile_z:
      var target_point = Vector3(cell.point.x, cell.point.y, cell_tile_z)
      var target_id = _get_id_for_point(target_point)
      if astar.has_point(target_id):
        astar.connect_points(cell_id, target_id, true)
    
func _get_tile_z(tile_id: int):
  return tile_level_ids.find(tile_id) * level_height

func _get_id_for_point(point: Vector3):
  var zerod_point = Vector2(point.x, point.y) - min_point
  var scaled_point = zerod_point / cell_size
  var x = scaled_point.x
  var y = scaled_point.y * scaled_size.x
  var z = point.z * scaled_size.x * scaled_size.y
  return x + y + z
  
func get_nav_path(from: Vector3, to: Vector3):
  var from_id = get_closest_point_in_level(from)
  if from_id == null:
    return []
  var to_id
  to_id = get_closest_point_in_level(to)
  if to_id == null:
    to_id = astar.get_closest_point(Vector3(to.x, to.y, to.z * level_height))
  var path3 = astar.get_point_path(from_id, to_id)
  var path2 = []
  for point in path3:
    path2.append(Vector2(point.x, point.y))
  return path2
  
func get_closest_point_in_level(point: Vector3):
  var closest_point
  var closest_distance = INF
  for cell in cells:
    if point.z * level_height != cell.point.z: continue
    var distance = point.distance_to(cell.point)
    if distance < closest_distance:
      closest_distance = distance
      closest_point = cell.point
  if closest_point:
    return _get_id_for_point(closest_point)

class Cell:
  # the global position of the cell
  # the z axis identifies the level the cell is on
  var point: Vector3
  # the tile id associated with the cell
  var tile_id: int
  var level: int