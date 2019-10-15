extends Node2D

onready var npc: Character = get_parent()
onready var interactable: Interactable = npc.get_node("Interactable")
onready var speech: SpeechBubble = npc.get_node("SpeechBubble")
onready var take_damage: TakeDamage = npc.get_node("TakeDamage")

func _ready():
  if interactable.connect("interact", self, "_on_interact") != OK:
    print(name + " couldn't connect interact")
    
  if take_damage.connect("take_damage", self, "_on_take_damage") != OK:
    print(name + " couldn't connect take_damage")
  
func _on_interact(other: Character):
  InputLock.lock_input(self)

  npc.face_point(other.global_position)
  
  speech.open()
  yield(speech.speak("""
    Hello,[p 0.25] {player_name}
  
    Be careful
    in this place
  
    There are...[p 0.5] bad
    things down here
    """, {
      player_name = other.name
    }), "completed")
  
  speech.close()
  
  InputLock.unlock_input(self)
  
func _on_take_damage(from: Character, power: int):
  npc.face_point(from.global_position)
  speech.open()
  speech.wait_for_next = false
  speech.speak("""
  Hey[p 0.5]
  
  Stop it[p 0.5]
  """)
  if !yield(speech, "speech_done"):
    speech.close()
  speech.wait_for_next = true