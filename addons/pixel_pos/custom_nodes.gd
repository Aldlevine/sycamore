tool

extends EditorPlugin

func _enter_tree():
  add_custom_type("PixelPos", "Node", preload("pixel_pos.gd"), preload("pixel_pos.png"))
  
func _exit_tree():
  remove_custom_type("PixelPos")