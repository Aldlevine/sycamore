extends Node

var input_lock_stack := []

func lock_input(obj):
  input_lock_stack.append(obj)
  
func unlock_input(obj):
  var idx = input_lock_stack.find_last(obj)
  if idx > -1:
    input_lock_stack.resize(idx)
  
func accepts_input(obj) -> bool:
  var size = input_lock_stack.size()
  if size == 0: return true
  return input_lock_stack.find_last(obj) == size - 1