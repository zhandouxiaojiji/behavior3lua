local bret = require 'behavior3.behavior_ret'

local M = {
    name = 'MoveToPos',
    type = 'Action',
    desc = '移动到坐标',
    args = {
        {name = 'x', type = 'int', desc = 'x'},
        {name = 'y', type = 'int', desc = 'y'}
    }
}

function M.run(node, env)
    local args = node.args
    local owner = env.owner
    owner.x = args.x
    owner.y = args.y
    return bret.SUCCESS
end

return M
