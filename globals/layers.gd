extends Node

enum CollisionBits {
  Player = 1 << 0,
  Character = 1 << 1,
  Thing = 1 << 2,
  Vertical_0 = 1 << 5,
  Vertical_1 = 1 << 6,
  Vertical_2 = 1 << 7,
  Vertical_3 = 1 << 8,
  Vertical_4 = 1 << 9,
  Level_0 = 1 << 10,
  Level_1 = 1 << 11,
  Level_2 = 1 << 12,
  Level_3 = 1 << 13,
  Level_4 = 1 << 14,
  Visibility_0 = 1 << 15,
  Visibility_1 = 1 << 16,
  Visibility_2 = 1 << 17,
  Visibility_3 = 1 << 18,
  Visibility_4 = 1 << 19,
}

enum LightBits {
  Level_0 = 1 << 0,
  Level_1 = 1 << 1,
  Level_2 = 1 << 2,
  Level_3 = 1 << 3,
  Level_4 = 1 << 4,
}

var LevelCollision = [
  CollisionBits.Level_0,
  CollisionBits.Level_1,
  CollisionBits.Level_2,
  CollisionBits.Level_3,
  CollisionBits.Level_4,
]

# warning-ignore:unused_class_variable
var LevelCollisionGroup = (
  LevelCollision[0] |
  LevelCollision[1] |
  LevelCollision[2] |
  LevelCollision[3] |
  LevelCollision[4] )

var VerticalVisibility = [
  CollisionBits.Vertical_0,
  CollisionBits.Vertical_1,
  CollisionBits.Vertical_2,
  CollisionBits.Vertical_3,
  CollisionBits.Vertical_4,
]

# warning-ignore:unused_class_variable
var VerticalVisibilityGroup = (
  VerticalVisibility[0] |
  VerticalVisibility[1] |
  VerticalVisibility[2] |
  VerticalVisibility[3] |
  VerticalVisibility[4] )

var LevelVisibility = [
  CollisionBits.Visibility_0,
  CollisionBits.Visibility_1,
  CollisionBits.Visibility_2,
  CollisionBits.Visibility_3,
  CollisionBits.Visibility_4,
]

# warning-ignore:unused_class_variable
var LevelVisibilityGroup = (
  LevelVisibility[0] |
  LevelVisibility[1] |
  LevelVisibility[2] |
  LevelVisibility[3] |
  LevelVisibility[4] )

var LevelLight = [
  LightBits.Level_0,
  LightBits.Level_1,
  LightBits.Level_2,
  LightBits.Level_3,
  LightBits.Level_4,
]

# warning-ignore:unused_class_variable
var LevelLightGroup = (
  LevelLight[0] |
  LevelLight[1] |
  LevelLight[2] |
  LevelLight[3] |
  LevelLight[4] )

func set_bits(mask: int, bits: int) -> int:
  return mask | bits
  
func clear_bits(mask: int, bits: int) -> int:
  return mask & ~bits
  
func has_bits(mask: int, bits: int) -> bool:
  return mask & bits > 0

func extract_bits(mask: int, bits: int) -> int:
  return mask & bits