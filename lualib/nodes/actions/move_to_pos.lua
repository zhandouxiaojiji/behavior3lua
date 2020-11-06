local bret = require 'behavior_ret'

local M = {
    name = 'MoveToPos',
    type = 'Action',
    desc = '移动到坐标',
    args = {
        {'x', 'int', 'x'},
        {'y', 'int', 'y'}
    }
}

function M.run(node)
    local args = node.args
    local env = node.env
    local owner = env.owner
    owner.x = args.x
    owner.y = args.y
    return bret.SUCCESS
end

return M
