extends Node2D

class_name BT

enum {BT_IDLE, BT_SUCCESS, BT_FAIL, BT_RUNNING}

var root: Behavior = behavior()

func tick(delta: float) -> int:
  return root.tick(delta)

func fn(arg1, arg2=null) -> FuncRef:
  if arg2 == null:
    return funcref(self, arg1)
  else:
    return funcref(arg1, arg2)
  
####  Behavior
func behavior():
  return Behavior.new()
  
class Behavior:
  var state := BT_IDLE
  var node : Behavior
  var nodes := []
  
  func tick(delta: float) -> int:
    if state == BT_IDLE:
      state = BT_RUNNING
      reset()
    var result = on_tick(delta)
    if result != BT_RUNNING:
      state = BT_IDLE
    return result
  
  ## override me
  func reset():
    if node:
      node.reset()
    for node in nodes:
      if node is Behavior:
        node.reset()
  
  ## override me
  func on_tick(_delta: float) -> int:
    return BT_SUCCESS

#### Sequence
func sequence(nodes: Array) -> Sequence:
  return Sequence.new(nodes)
  
class Sequence extends Behavior:
  func _init(nodes: Array = []):
    self.nodes = nodes
  
  func on_tick(delta: float):
    var result: int
    var got_result = false
    for node in nodes:
      if node is Behavior:
        if !got_result:
          result = node.tick(delta)
          if result == BT_SUCCESS || result == BT_RUNNING:
            got_result = true
        else:
          node.reset()
    if got_result:
      return result
    return BT_FAIL
    
#### Series
func series(nodes: Array) -> Series:
  return Series.new(nodes)
  
class Series extends Behavior:
  var current_node := 0
  
  func _init(nodes: Array = []):
    self.nodes = nodes
  
  func reset():
    current_node = 0
  
  func on_tick(delta: float):
    if nodes.empty():
      return BT_SUCCESS
    var node = nodes[current_node]
    var result = node.tick(delta)
    if result == BT_SUCCESS:
      current_node += 1
      if current_node >= nodes.size():
        return BT_SUCCESS
      return BT_RUNNING
    return result
    
#### Action
static func action(act: FuncRef) -> Action:
  return Action.new(act)
  
class Action extends Behavior:
  var act: FuncRef
  
  func _init(act: FuncRef):
    self.act = act
    
  func on_tick(delta: float) -> int:
    act.call_func(delta)
    return BT_SUCCESS
  
#### RunAfterSeconds
static func run_after_seconds(timeout: float, node: Behavior) -> RunAfterSeconds:
  return RunAfterSeconds.new(timeout, node)
    
class RunAfterSeconds extends Behavior:
  var timeout: float
  var timer: float = 0
  
  func _init(timeout: float, node: Behavior):
    self.timeout = timeout
    self.node = node
    
  func reset():
    timer = 0
    
  func on_tick(delta: float) -> int:
    timer += delta
    if timer < timeout:
      return BT_RUNNING
    return node.tick(delta)

#### RunForSeconds
static func run_for_seconds(timeout: float, node: Behavior, force := false) -> RunForSeconds:
  return RunForSeconds.new(timeout, node, force)
    
class RunForSeconds extends Behavior:
  var timeout: float
  var timer: float = 0
  var force := false
  
  func _init(timeout: float, node: Behavior, force := false):
    self.timeout = timeout
    self.node = node
    self.force = force
    
  func reset():
    timer = 0
    
  func on_tick(delta: float) -> int:
    timer += delta
    if timer < timeout:
      var result = node.tick(delta)
      return BT_RUNNING if force else result
    return BT_SUCCESS
    
#### RunForever
func run_forever(node = null) -> RunForever:
  return RunForever.new(node)
class RunForever extends Behavior:
  func _init(node = null):
    self.node = node
  
  func on_tick(delta: float) -> int:
# warning-ignore:return_value_discarded
    if node: node.tick(delta)
    return BT_RUNNING

#### SetValue
func set_value(arg1, arg2, arg3 = null) -> SetValue:
  var obj
  var key
  var value
  if arg3 == null:
    obj = self
    key = arg1
    value = arg2
  else:
    obj = arg1
    key = arg2
    value = arg3
  return SetValue.new(obj, key, value)
    
class SetValue extends Behavior:
  var obj: Object
  var key: String
  var value
  
  func _init(obj: Object, key: String, value):
    self.obj = obj
    self.key = key
    self.value = value
  
  func on_tick(_delta: float) -> int:
    obj[key] = value
    return BT_SUCCESS
    
#### When
func when(pred: FuncRef, node: Behavior):
  return When.new(pred, node)
  
class When extends Behavior:
  var pred: FuncRef
  
  func _init(pred: FuncRef, node: Behavior):
    self.pred = pred
    self.node = node
  
  func on_tick(delta: float) -> int:
    if pred.call_func(delta):
      return node.tick(delta)
    else:
      return BT_FAIL
      
#### WhenCompare
#func when_compare(comparator: FuncRef, obj: Object, key: String, value, node: Behavior):
func when_compare(comparator: FuncRef, arg1, arg2, arg3, arg4 = null):
  var obj
  var key
  var value
  var node
  if arg4 == null:
    obj = self
    key = arg1
    value = arg2
    node = arg3
  else:
    obj = arg1
    key = arg2
    value = arg3
    node = arg4
  
  return WhenCompare.new(comparator, obj, key, value, node)
  
class WhenCompare extends Behavior:
  var obj: Object
  var key: String
  var comparator: FuncRef
  var value
  
  func _init(comparator: FuncRef, obj: Object, key: String, value, node: Behavior):
    self.comparator = comparator
    self.obj = obj
    self.key = key
    self.value = value
    self.node = node
  
  func on_tick(delta: float) -> int:
    if comparator.call_func(obj[key], value):
      return node.tick(delta)
    else:
      return BT_FAIL
      
#### WhenEq
func eq_comparator(a, b) -> bool:
  return a == b
func when_eq(obj, key, value, node=null):
  return when_compare(fn("eq_comparator"), obj, key, value, node)
  
#### WhenNeq
func neq_comparator(a, b) -> bool:
  return a != b
func when_neq(obj, key, value, node=null):
  return when_compare(fn("neq_comparator"), obj, key, value, node)
  
#### WhenLt
func lt_comparator(a, b) -> bool:
  return a < b
func when_lt(obj, key, value, node=null):
  return when_compare(fn("lt_comparator"), obj, key, value, node)

#### WhenLte
func lte_comparator(a, b) -> bool:
  return a <= b
func when_lte(obj, key, value, node=null):
  return when_compare(fn("lte_comparator"), obj, key, value, node)
  
#### WhenGt
func gt_comparator(a, b) -> bool:
  return a > b
func when_gt(obj, key, value, node=null):
  return when_compare(fn("gt_comparator"), obj, key, value, node)

#### WhenGte
func gte_comparator(a, b) -> bool:
  return a >= b
func when_gte(obj, key, value, node=null):
  return when_compare(fn("gte_comparator"), obj, key, value, node)