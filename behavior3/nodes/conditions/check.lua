local bret = require 'behavior3.behavior_ret'

---@type BehaviorNodeDefine
local M = {
    name = "Check",
    type = "Condition",
    desc = "检查True或False",
    args = {
        {
            name = "value",
            type = "code?",
            desc = "值"
        },
    },
    doc = [[
        + 做简单数值公式判定，返回成功或失败
    ]],
    run = function(node, env)
        return node:get_env_args("value", env) and bret.SUCCESS or bret.FAIL
    end
}

return M
