local bret = require "behavior3.behavior_ret"

---@type BehaviorNodeDefine
local M = {
    name = "Calculate",
    type = "Action",
    desc = "计算公式",
    args = {
        {
            name = "value",
            type = "code?",
            desc = "公式"
        },
    },
    doc = [[
        + 做简单数值公式计算
    ]],
    run = function(node, env)
        local value = node:get_env_args("value", env)
        return bret.SUCCESS, value
    end,
}

return M