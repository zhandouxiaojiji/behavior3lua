-- AlwaysSuccess
--

local bret = require 'behavior_ret'

local M = {
    name = 'AlwaysFail',
    type = 'Decorator',
    desc = '始终返回失败',
    doc = [[
        + 只能有一个子节点,多个仅执行第一个
        + 不管子节点是否成功都返回失败
    ]]
}
function M.run(node, enemy)
    local r = node.children[1]:run(node.env)
    if r == bret.RUNNING or r == bret.CLOSED then
        return r
    end
    return bret.FAIL
end

return M