"""
groups:
level_visibility_layer - for Player collision layer
level_visibility_mask - for the Visibility raycast collision mask
level_collision_mask - for Player and characters collision layer
level_collision_mask - for Player and characters collision mask
level_light_mask - for Player and characters light mask
level_light_range - for Player Visibility light and Player light range mask
level_light_shadow - for Player Visibility light shadow mask
"""

extends Node

const LEVEL_VISIBILITY_LAYER = "level_visibility_layer"
const LEVEL_VISIBILITY_MASK = "level_visibility_mask"
const LEVEL_COLLISION_LAYER = "level_collision_mask"
const LEVEL_COLLISION_MASK = "level_collision_mask"
const LEVEL_LIGHT_MASK = "level_light_mask"
const LEVEL_LIGHT_RANGE = "level_light_range"
const LEVEL_LIGHT_SHADOW = "level_light_shadow"

const LEVEL_HEIGHT = 16

func enable_level(node: Node, level: int):
  if node.is_in_group(LEVEL_VISIBILITY_LAYER):
    var initial = node.collision_layer
    var bits = Layers.LevelVisibility[level]
    node.collision_layer = Layers.set_bits(initial, bits)
  if node.is_in_group(LEVEL_VISIBILITY_MASK):
    var initial = node.collision_mask
    var bits = Layers.LevelVisibility[level]
    node.collision_mask = Layers.set_bits(initial, bits)
  if node.is_in_group(LEVEL_COLLISION_LAYER):
    var initial = node.collision_layer
    var bits = Layers.LevelCollision[level]
    node.collision_layer = Layers.set_bits(initial, bits)
  if node.is_in_group(LEVEL_COLLISION_MASK):
    var initial = node.collision_mask
    var bits = Layers.LevelCollision[level]
    node.collision_mask = Layers.set_bits(initial, bits)
  if node.is_in_group(LEVEL_LIGHT_MASK):
    var initial = node.light_mask
    var bits = Layers.LevelLight[level]
    node.light_mask = Layers.set_bits(initial, bits)
  if node.is_in_group(LEVEL_LIGHT_RANGE):
    var initial = node.range_item_cull_mask
    var bits = Layers.LevelLight[level]
    node.range_item_cull_mask = Layers.set_bits(initial, bits)
  if node.is_in_group(LEVEL_LIGHT_SHADOW):
    var initial = node.shadow_item_cull_mask
    var bits = Layers.LevelLight[level]
    node.shadow_item_cull_mask = Layers.set_bits(initial, bits)
  for n in node.get_children():
    enable_level(n, level)
    

func disable_level(node: Node, level: int):
  if node.is_in_group(LEVEL_VISIBILITY_LAYER):
    var initial = node.collision_layer
    var bits = Layers.LevelVisibility[level]
    node.collision_layer = Layers.clear_bits(initial, bits)
  if node.is_in_group(LEVEL_VISIBILITY_MASK):
    var initial = node.collision_mask
    var bits = Layers.LevelVisibility[level]
    node.collision_mask = Layers.clear_bits(initial, bits)
  if node.is_in_group(LEVEL_COLLISION_LAYER):
    var initial = node.collision_layer
    var bits = Layers.LevelCollision[level]
    node.collision_layer = Layers.clear_bits(initial, bits)
  if node.is_in_group(LEVEL_COLLISION_MASK):
    var initial = node.collision_mask
    var bits = Layers.LevelCollision[level]
    node.collision_mask = Layers.clear_bits(initial, bits)
  if node.is_in_group(LEVEL_LIGHT_MASK):
    var initial = node.light_mask
    var bits = Layers.LevelLight[level]
    node.light_mask = Layers.clear_bits(initial, bits)
  if node.is_in_group(LEVEL_LIGHT_RANGE):
    var initial = node.range_item_cull_mask
    var bits = Layers.LevelLight[level]
    node.range_item_cull_mask = Layers.clear_bits(initial, bits)
  if node.is_in_group(LEVEL_LIGHT_SHADOW):
    var initial = node.shadow_item_cull_mask
    var bits = Layers.LevelLight[level]
    node.shadow_item_cull_mask = Layers.clear_bits(initial, bits)
  for n in node.get_children():
    disable_level(n, level)
    
func set_level(character: Character, level: int):
  disable_level(character, character.current_level)
  character.current_level = level
  character.z_index = level
  enable_level(character, level)