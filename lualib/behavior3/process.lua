return {
  -- 复合节点
  Parallel = require "behavior3.nodes.composites.parallel",
  Selector = require "behavior3.nodes.composites.selector",
  Sequence = require "behavior3.nodes.composites.sequence",

  -- 装饰节点
  Not           = require "behavior3.nodes.decorators.not",
  AlwaysFail    = require "behavior3.nodes.decorators.always_fail",
  AlwaysSuccess = require "behavior3.nodes.decorators.always_success",

  -- 条件节点
  Cmp       = require "behavior3.nodes.conditions.cmp",
  FindEnemy = require "behavior3.nodes.conditions.find_enemy",

  -- 行为节点
  Log          = require "behavior3.nodes.actions.log",
  GetHp        = require "behavior3.nodes.actions.get_hp",
  Attack       = require "behavior3.nodes.actions.attack",
  MoveToTarget = require "behavior3.nodes.actions.move_to_target",
  MoveToPos    = require "behavior3.nodes.actions.move_to_pos",
  Idle         = require "behavior3.nodes.actions.idle",
  Wait         = require "behavior3.nodes.actions.wait",
}