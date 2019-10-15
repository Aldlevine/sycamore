extends Area2D

export var _npc: NodePath
onready var npc: Character = get_node(_npc)
onready var npc_speech: SpeechBubble = npc.get_node("SpeechBubble")

export var _player: NodePath
onready var player = get_node(_player)
onready var player_speech: SpeechBubble = player.get_node("SpeechBubble")

var played = false

func _ready():
  if connect("body_entered", self, "_on_body_entered") != OK:
    print(name + " couldn't connect")

func _on_body_entered(body):
  if body == player:
    act()

func act():
  if played: return
  InputLock.lock_input(self)
  
  npc_speech.open()
  yield(npc_speech.speak("""
  Woah![p 0.5]
  What are you doing!
  
  You shouldn't go in there![p 0.5]
  It's super dangerous.
  """), "completed")
  npc_speech.close()

  player.move_to($PlayerPos1.global_position)
  yield(get_tree().create_timer(0.25), "timeout")
  yield(npc.move_to($NPCPos1.global_position), "completed")
  player.face_point(npc.global_position)
  
  player_speech.open()
  yield(player_speech.speak("""
  What?
  
  What are you
  talking about?
  
  This place seems[p 0.5]
  pleasant[p 0.25] to me
  """), "completed")
  player_speech.close()
  
  npc.face_point(player.global_position)
  
  npc_speech.open()
  yield(npc_speech.speak("""
  Pleasant[s][p 0.25] is [s 0.1]not[s][p 0.25] how I
  would describe it
  my friend
  
  This place is full of things that
  would[p 0.25] [s 0.1]happily[s][p 0.25] eat your flesh
  if given half a chance
  """), "completed")
  npc_speech.close()
  
  player_speech.open()
  yield(player_speech.speak("""
  Right...
  
  Like you know[p 0.5]
  [s 0.15]anything[p 0.25][s] about this place
  """), "completed")
  player_speech.close()
  
  player.move_to($PlayerPos2.global_position)
  yield(get_tree().create_timer(0.25), "timeout")
  yield(npc.move_to($NPCPos2.global_position), "completed")
  npc_speech.open()
  yield(npc_speech.speak("""
  Well, I can't let you in.
  
  Not unless you can prove that
  you possess the necessary skills
  to traverse these halls 
  """), "completed")
  npc_speech.close()
  
  InputLock.unlock_input(self)
  played = true