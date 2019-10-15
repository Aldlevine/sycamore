extends Node2D

export var DESIRED_RESOLUTION = Vector2(480, 270)
onready var vp := get_viewport()
var scaling_factor = 1

func _ready():
  if vp.connect("size_changed", self, "size_changed") != OK:
    print('%s could not connect', name)

func size_changed():
  var scale_vector = vp.size / DESIRED_RESOLUTION
  var new_scaling_factor = max(floor(min(scale_vector[0], scale_vector[1])), 1)
  if new_scaling_factor != scaling_factor:
    scaling_factor = new_scaling_factor
    vp.size = vp.size / scaling_factor
    