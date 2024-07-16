-- Wait
--

local bret = require 'behavior3.behavior_ret'

local abs = math.abs
local SPEED = 50

---@type BehaviorNodeDefine
local M = {
    name = 'Wait',
    type = 'Action',
    desc = '等待',
    args = {
        {
            name = 'time',
            type = 'int',
            desc = '时间/tick'
        }
    },
    run = function(node, env)
        local args = node.args
        local t = node:resume(env)
        if t then
            if env.ctx.time >= t then
                print('CONTINUE')
                return bret.SUCCESS
            else
                print('WAITING', "node#" .. node.data.id)
                return bret.RUNNING
            end
        end
        print('Wait', args.time)
        return node:yield(env, env.ctx.time + args.time)
    end
}

return M
