---@enum BehaviorTreeEvent
local BehaviorTreeEvent = {
    INTERRUPTED = "interrupted",            -- 行为树被中断
    BEFORE_RUN = "beforeRun",               -- 行为树开始执行前
    AFTER_RUN = "afterRun",                 -- 行为树执行完成后
    AFTER_RUN_SUCCESS = "afterRunSuccess",  -- 行为树执行成功后
    AFTER_RUN_FAILURE = "afterRunFailure",  -- 行为树执行失败后
}

return BehaviorTreeEvent