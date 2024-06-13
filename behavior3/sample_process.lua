return {
  -- 复合节点
  Parallel = require "behavior3.nodes.composites.parallel",
  Selector = require "behavior3.nodes.composites.selector",
  Sequence = require "behavior3.nodes.composites.sequence",

  -- 装饰节点
  Once          = require "behavior3.nodes.decorators.once",
  Not           = require "behavior3.nodes.decorators.not",
  Inverter      = require "behavior3.nodes.decorators.not",
  Listen        = require "behavior3.nodes.decorators.listen",
  AlwaysFail    = require "behavior3.nodes.decorators.always_fail",
  AlwaysSuccess = require "behavior3.nodes.decorators.always_success",
  RepeatUntilSuccess = require "behavior3.nodes.decorators.repeat_until_success",
  RepeatUntilFailure = require "behavior3.nodes.decorators.repeat_until_fail",

  -- 条件节点
  Cmp = require "behavior3.nodes.conditions.cmp",
  Check = require "behavior3.nodes.conditions.check",

  -- 行为节点
  Log  = require "behavior3.nodes.actions.log",
  Wait = require "behavior3.nodes.actions.wait",
  Now = require "behavior3.nodes.actions.now",
  Clear = require "behavior3.nodes.actions.clear",
}