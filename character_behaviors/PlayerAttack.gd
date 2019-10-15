extends Node2D

onready var player: Character = get_parent()
onready var anim_player: AnimationPlayer = $"../AnimationPlayer"

var attacking_bodies = []

func _ready():
  set_process(false)
  if anim_player.connect("animation_finished", self, "animation_finished") != OK:
    print('%s could not connect', name)

func _process(_delta):
  player.reface_anim("sword")
  for body in $Area2D.get_overlapping_bodies():
    if body is Character && body != player && !attacking_bodies.has(body):
      attacking_bodies.append(body)
      var take_damage := Utils.get_node_of_type(body, TakeDamage) as TakeDamage
      if take_damage != null:
        var direction = body.global_position - player.global_position
        if (player.facing == 'left' && direction.x < 0 ||
        player.facing == 'right' && direction.x > 0 ||
        player.facing == 'up' && direction.y < 0 ||
        player.facing == 'down' && direction.y > 0):
          take_damage.take_damage(player, 10)
#          print("Attacked ", body.name)

func _unhandled_input(event):
  if !InputLock.accepts_input(player): return
  if event.is_action_pressed("player_attack_1") && player.can_attack:
    attack()

func attack():
  player.allow_movement = false
  player.can_attack = false
  player.play_anim_facing("sword")
  set_process(true)

func animation_finished(name: String):
  if name.begins_with("sword"):
    player.allow_movement = true
    player.can_attack = true
    attacking_bodies.clear()
    set_process(false)