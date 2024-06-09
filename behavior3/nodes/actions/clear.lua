local bret = require "behavior3.behavior_ret"

local M = {
    name = "Clear",
    type = "Action",
    desc = "清除变量",
    output = { "清除的变量名" },
    run = function(node, env)
        return bret.SUCCESS, nil
    end
}

return M
