return {
  -- 复合节点
  IfElse             = require "behavior3.nodes.composites.ifelse",
  Parallel           = require "behavior3.nodes.composites.parallel",
  Selector           = require "behavior3.nodes.composites.selector",
  Sequence           = require "behavior3.nodes.composites.sequence",

  -- 装饰节点
  Once               = require "behavior3.nodes.decorators.once",
  Invert             = require "behavior3.nodes.decorators.invert",
  AlwaysFail         = require "behavior3.nodes.decorators.always_fail",
  AlwaysSuccess      = require "behavior3.nodes.decorators.always_success",
  RepeatUntilSuccess = require "behavior3.nodes.decorators.repeat_until_success",
  RepeatUntilFailure = require "behavior3.nodes.decorators.repeat_until_fail",
  Repeat             = require "behavior3.nodes.decorators.repeat",

  -- 条件节点
  Check              = require "behavior3.nodes.conditions.check",
  Cmp                = require "behavior3.nodes.conditions.cmp",
  Includes           = require "behavior3.nodes.conditions.includes",
  IsNull             = require "behavior3.nodes.conditions.is_null",
  NotNull            = require "behavior3.nodes.conditions.not_null",

  -- 行为节点
  Calculate          = require "behavior3.nodes.actions.calculate",
  Clear              = require "behavior3.nodes.actions.clear",
  Filter             = require "behavior3.nodes.actions.filter",
  ForEach            = require "behavior3.nodes.actions.foreach",
  Index              = require "behavior3.nodes.actions.index",
  Let                = require "behavior3.nodes.actions.let",
  Log                = require "behavior3.nodes.actions.log",
  Now                = require "behavior3.nodes.actions.now",
  Push               = require "behavior3.nodes.actions.push",
  Random             = require "behavior3.nodes.actions.random",
  RandomIndex        = require "behavior3.nodes.actions.random_index",
  Wait               = require "behavior3.nodes.actions.wait",
  Concat             = require "behavior3.nodes.actions.concat",
  WaitForCount       = require "behavior3.nodes.actions.wait_for_count",
}
