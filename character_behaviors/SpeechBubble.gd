extends Node2D

class_name SpeechBubble

signal typing_done
signal pausing_done
signal speech_done(cancelled)

enum SpeechState {
  None,
  Typing,
  Pausing,
  AwaitingNext,
}

# export vars
export var default_speed := 0.05
export var wait_for_next := true

# onready vars
onready var label = $VBox/HBox/Label

var state: int = SpeechState.None
var tag_queue := []
var typing_speed := 0.1
var typing_elapsed := 0.0
var logged_chars := 0

var pause_time := 0.0
var pause_elapsed := 0.0

var white_space_regex = RegEx.new()
var indent_regex = RegEx.new()

func _ready():
  close()
  white_space_regex.compile("\\s")
  indent_regex.compile("\n[ \t]+")

func _process(delta):
  if state == SpeechState.Typing:
    if logged_chars >= printable_length(label.text):
      if !tag_queue.empty():
        process_tag(tag_queue.pop_front())
      else:
        state = SpeechState.AwaitingNext
    if wait_for_next && logged_chars > 0 && Input.is_action_just_pressed("ui_accept"):
      logged_chars = printable_length(label.text)
      label.visible_characters = logged_chars
      tag_queue.clear()
    else:
      typing_elapsed += delta
      if typing_elapsed >= typing_speed:
        logged_chars += 1
        typing_elapsed = 0
      label.visible_characters = logged_chars
      if !tag_queue.empty():
        if label.visible_characters >= tag_queue[0].index:
          process_tag(tag_queue.pop_front())
  elif state == SpeechState.Pausing:
    if wait_for_next && pause_elapsed > 0 && Input.is_action_just_pressed("ui_accept"):
      logged_chars = printable_length(label.text)
      label.visible_characters = logged_chars
      tag_queue.clear()
      state = SpeechState.Typing
      emit_signal("pausing_done")
    else:
      pause_elapsed += delta
      if pause_elapsed >= pause_time:
        state = SpeechState.Typing
        emit_signal("pausing_done")
  elif state == SpeechState.AwaitingNext:
    if wait_for_next:
      if Input.is_action_just_pressed("ui_accept"):
        clear_text()
        emit_signal("typing_done")
    else:
      clear_text()
      emit_signal("typing_done")

func process_tag(tag: Tag):
  match tag.name:
    "s":
      logged_chars = label.visible_characters
      typing_elapsed = 0.0
      typing_speed = float(tag.args[0]) if tag.args.size() > 0 else default_speed
    "p":
      pause(float(tag.args[0]))
  
func pause(time: float):
  state = SpeechState.Pausing
  pause_elapsed = 0.0
  pause_time = time
  
func clear_text():
  label.visible_characters = 0
  label.text = ''
  logged_chars = 0

func open():
  visible = true
  $AnimationPlayer.play("open")
  yield($AnimationPlayer, "animation_finished")
  
func close():
  label.text = ""
  $AnimationPlayer.play("close")
  yield($AnimationPlayer, "animation_finished")
  visible = false
  
func cancel():
  emit_signal("typing_done")
  emit_signal("speech_done", true)
  
func speak(text: String, data := {}):
  yield(play_speech(parse_speech(text, data)), "completed")
  
func play_speech(speech: Speech):
  if is_processing():
    cancel()
  set_process(true)
  for i in range(speech.lines.size()):
    var line: Line = speech.lines[i]
    yield(type_text(line.text, speech.data, line.tags), "completed")
  set_process(false)
  emit_signal("speech_done", false)
  
func type_text(text: String, data := {}, tags := []):
  label.text = text.format(data)
  tag_queue = tags
  typing_elapsed = 0.0
  typing_speed = default_speed
  state = SpeechState.Typing
  set_process(true)
  yield(self, "typing_done")

func parse_speech(text: String, data: Dictionary) -> Speech:
  var result = []
  var lines = indent_regex.sub(text.strip_edges(), "\n", true).split("\n\n")
  for line in lines:
    result.append(parse_line(line.strip_edges()))
  return Speech.new(result, data)
  
func parse_line(line: String) -> Line:
  var tags := []
  var current_chunk := ''
  var text := ''
  var parsing_tag := false
  for i in range(line.length()):
    var ch = line[i]
    if parsing_tag:
      if ch == "]":
        tags.append(parse_tag(current_chunk, printable_length(text)))
        current_chunk = ''
        parsing_tag = false
      else:
        current_chunk += ch
    else:
      if ch == "[":
        if current_chunk.length() > 0:
          text += current_chunk
          current_chunk = ''
        parsing_tag = true
      else:
        current_chunk += ch
  if current_chunk.length() > 0:
#    result.append(parse_text(current_chunk))
    text += current_chunk
#  return result
  return Line.new(text, tags)
  
func printable_length(string: String) -> int:
  return white_space_regex.sub(string, "", true).length()
#func parse_text(string: String) -> Text:
#  return Text.new(string)
  
func parse_tag(tag_text: String, index: int) -> Tag:
  var split = tag_text.split(" ", true)
  var n = split[0]
  var a := []
  for i in range(1, split.size()):
    a.append(split[i])
  return Tag.new(index, n, a)

class Speech:
  var lines: Array
  var data: Dictionary
  
  func _init(l: Array, d: Dictionary = {}):
    lines = l
    data = d
    
  func to_string() -> String:
    var result = []
    for line in lines:
      var l = []
      for item in line:
        l.append(item.to_string().format(data))
      result.append(PoolStringArray(l).join(" "))
    return PoolStringArray(result).join("\n")

class Line:
  var text: String
  var tags: Array
  
  func _init(tx: String, tg: Array):
    text = tx
    tags = tg

class Text:
  var value: String
  
  func _init(v: String):
    value = v
  
  func to_string() -> String:
    return '"{value}"'.format({
      value = value
    })

class Tag:
  var index: int
  var name: String
  var args: Array
  
  func _init(i: int, n: String, a: Array):
    index = i
    name = n
    args = a
    
  func to_string() -> String:
    return "{name}({args})".format({
      name = name,
      args = PoolStringArray(args).join(", ")
    })