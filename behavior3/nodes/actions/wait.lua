-- Wait
--

local bret = require 'behavior3.behavior_ret'

local M = {
    name = 'Wait',
    type = 'Action',
    desc = '等待',
    args = {
        {'time', 'int', '时间/tick'}
    }
}

local abs = math.abs
local SPEED = 50

function M.run(node, env)
    local args = node.args
    local t = node:resume(env)
    if t then
        if env.ctx.time >= t then
            print('CONTINUE')
            return bret.SUCCESS
        else
            print('WAITING')
            return bret.RUNNING
        end
    end
    print('Wait', args.time)
    return node:yield(env, env.ctx.time + args.time)
end

return M
