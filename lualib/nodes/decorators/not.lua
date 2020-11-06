-- Not
--

local bret = require 'behavior_ret'

local M = {
    name = 'Not',
    type = 'Decorator',
    desc = '取反',
    doc = [[
        + 将子节点的返回值取反
    ]]
}

function M.run(node, enemy)
    local r = node.children[1]:run(node.env)
    if r == bret.SUCCESS then
        return bret.FAIL
    end
    if r == bret.FAIL then
        return bret.SUCCESS
    end
    return r
end

return M