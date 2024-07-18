local bret = require "behavior3.behavior_ret"

---@type BehaviorNodeDefine
local M = {
    name = "NotNull",
    type = "Condition",
    desc = "判断变量是否存在",
    input = { "判断的变量" },
    run = function(node, env, value)
        return value ~= nil and bret.SUCCESS or bret.FAIL
    end
}

return M