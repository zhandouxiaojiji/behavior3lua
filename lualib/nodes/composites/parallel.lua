-- Parallel
--

local bret = require 'behavior_ret'

local M = {
    name = 'Parallel',
    type = 'Composite',
    desc = '并行执行',
    doc = [[
        执行所有子节点并返回成功
    ]]
}
function M.run(node)
    for _, child in ipairs(node.children) do
        local r = child:run(node.env)
        if r == bret.RUNNING then
            return r
        end
    end
    return bret.SUCCESS
end

return M
