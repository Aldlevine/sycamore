extends TileMap

#onready var vision_light = get_tree().get_nodes_in_group("player")[0]
var vision_light: Light2D
var wall_cells = get_used_cells()
var wall_cell_data = []

func _ready():
  var vision_light_group = get_tree().get_nodes_in_group("vision_light")
  if vision_light_group.size() > 0:
    vision_light = vision_light_group[0]
  wall_cell_data.resize(wall_cells.size())
  for i in range(0, wall_cells.size()):
    var cell = {}
    cell.id = get_cellv(wall_cells[i])
    cell.flip_x = is_cell_x_flipped(wall_cells[i].x, wall_cells[i].y)
    cell.flip_y = is_cell_y_flipped(wall_cells[i].x, wall_cells[i].y)
    cell.transpose = is_cell_transposed(wall_cells[i].x, wall_cells[i].y)
    cell.autotile_coord = get_cell_autotile_coord(wall_cells[i].x, wall_cells[i].y)
    wall_cell_data[i] = cell
    $WallsUnlit.set_cell(wall_cells[i].x, wall_cells[i].y, cell.id, cell.flip_x, cell.flip_y, cell.transpose, cell.autotile_coord)


func _process(_delta: float):
  if vision_light:
    var y = world_to_map(vision_light.global_position).y - cell_half_offset/2.0
    for i in range(0, wall_cells.size()):
      if y < wall_cells[i].y:
        set_cellv(wall_cells[i], -1)
      else:
        var cell = wall_cell_data[i]
        set_cell(wall_cells[i].x, wall_cells[i].y, cell.id, cell.flip_x, cell.flip_y, cell.transpose, cell.autotile_coord)