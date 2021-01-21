-- Idle
--

local bret = require "behavior3.behavior_ret"

local M = {
    name = "Idle",
    type = "Action",
    desc = "待机",
}

function M.run(node, env)
    print "Do Idle"
    return bret.SUCCESS
end

return M