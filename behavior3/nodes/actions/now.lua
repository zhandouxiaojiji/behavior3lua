local bret = require "behavior3.behavior_ret"

---@type BehaviorNodeDefine
local M = {
    name = "Now",
    type = "Action",
    desc = "获取当前时间",
    output = { "当前时间" },
    run = function(node, env)
        return bret.SUCCESS, env.ctx.time
    end
}

return M
