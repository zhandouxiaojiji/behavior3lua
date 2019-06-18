-- MoveToTarget
--

local bret = require "behavior_ret"

local abs = math.abs
local SPEED = 50

return function(node)
    local args = node.args
    local env = node.env
    if node:is_open() then
        local t = node:get_var("WAITING")
        if env.time >= t then
            return bret.SUCCESS
        end
    end
    node:set_var("WAITING", env.time + args.time)
    return bret.RUNNING
end
