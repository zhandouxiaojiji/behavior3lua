---@enum BehaviorTreeEvent
local BehaviorTreeEvent = {
    INTERRUPTED = "treeInterrupted",           -- 行为树被中断
    BEFORE_RUN = "beforeRunTree",              -- 行为树开始执行前
    AFTER_RUN = "afterRunTree",                -- 行为树执行完成后
    AFTER_RUN_SUCCESS = "afterRunTreeSuccess", -- 行为树执行成功后
    AFTER_RUN_FAILURE = "afterRunTreeFailure", -- 行为树执行失败后
}

return BehaviorTreeEvent
