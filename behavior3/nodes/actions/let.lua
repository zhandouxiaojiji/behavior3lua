local bret = require "behavior3.behavior_ret"

---@type BehaviorNodeDefine
local M = {
    name = "Let",
    type = "Action",
    children = 0,
    desc = "定义新的变量名",
    input = { "变量名" },
    output = { "新变量名" },
    run = function(node, env, value)
        return bret.SUCCESS, value
    end
}

return M