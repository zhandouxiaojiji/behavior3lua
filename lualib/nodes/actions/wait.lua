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
        if env.ctx.time >= t then
            print("CONTINUE")
            return bret.SUCCESS
        else
            print("WAITING")
            return bret.RUNNING
        end
    end
    print("Wait", args.time)
    node:set_var("WAITING", env.ctx.time + args.time)
    return bret.RUNNING
end
