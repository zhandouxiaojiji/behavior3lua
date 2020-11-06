-- Selector
--

local bret = require 'behavior_ret'

local M = {
    name = 'Selector',
    type = 'Composite',
    desc = '选择执行',
    doc = [[
        + 一直往下执行，有子节点返回成功则返回成功，若全部节点返回失败则返回失败
        + 子节点是或的关系
    ]]
}
function M.run(node)
    for _, child in ipairs(node.children) do
        local r = child:run(node.env)
        if r == bret.RUNNING or r == bret.SUCCESS then
            return r
        end
    end
    return bret.FAIL
end

return M
