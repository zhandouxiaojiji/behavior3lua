-- Log
--

local bret = require "behavior3.behavior_ret"

---@type BehaviorNodeDefine
local M = {
    name = "Log",
    type = "Action",
    desc = "打印日志",
    args = {
        { "str", "string", "日志" }
    },
    run = function(node, env)
        print(node.args.str)
        return bret.SUCCESS
    end
}



return M
