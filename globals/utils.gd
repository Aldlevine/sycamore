extends Node

func get_player() -> Character:
  var nodes = get_tree().get_nodes_in_group("player")
  for node in nodes:
    if node is Character:
      return node
  return null
  
func get_nodes_of_type(node: Node, type) -> Array:
  var result = []
  for child in node.get_children():
    if child is type:
      result.append(child)
  return result
  
func get_node_of_type(node: Node, type) -> Node:
  for child in node.get_children():
    if child is type:
      return child
  return null