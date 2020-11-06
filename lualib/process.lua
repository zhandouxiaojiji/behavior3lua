return {
  -- 复合节点
  Parallel = require "nodes.composites.parallel",
  Selector = require "nodes.composites.selector",
  Sequence = require "nodes.composites.sequence",

  -- 装饰节点
  Not           = require "nodes.decorators.not",
  AlwaysFail    = require "nodes.decorators.always_fail",
  AlwaysSuccess = require "nodes.decorators.always_success",

  -- 条件节点
  Cmp       = require "nodes.conditions.cmp",
  FindEnemy = require "nodes.conditions.find_enemy",

  -- 行为节点
  Log          = require "nodes.actions.log",
  GetHp        = require "nodes.actions.get_hp",
  Attack       = require "nodes.actions.attack",
  MoveToTarget = require "nodes.actions.move_to_target",
  MoveToPos    = require "nodes.actions.move_to_pos",
  Idle         = require "nodes.actions.idle",
  Wait         = require "nodes.actions.wait",
}