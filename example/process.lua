return {
    -- 复合节点
    Parallel = require "behavior3.nodes.composites.parallel",
    Selector = require "behavior3.nodes.composites.selector",
    Sequence = require "behavior3.nodes.composites.sequence",
    IfElse   = require "behavior3.nodes.composites.ifelse",

    -- 装饰节点
    Not           = require "behavior3.nodes.decorators.not",
    AlwaysFail    = require "behavior3.nodes.decorators.always_fail",
    AlwaysSuccess = require "behavior3.nodes.decorators.always_success",

    -- 条件节点
    Cmp       = require "behavior3.nodes.conditions.cmp",
    FindEnemy = require "example.conditions.find_enemy",

    -- 行为节点
    Log          = require "behavior3.nodes.actions.log",
    Wait         = require "behavior3.nodes.actions.wait",
    GetHp        = require "example.actions.get_hp",
    Attack       = require "example.actions.attack",
    MoveToTarget = require "example.actions.move_to_target",
    MoveToPos    = require "example.actions.move_to_pos",
    Idle         = require "example.actions.idle",
}