-- AlwaysSuccess
--

local bret = require 'behavior3.behavior_ret'

local M = {
    name = 'AlwaysFail',
    type = 'Decorator',
    desc = '始终返回失败',
    doc = [[
        + 只能有一个子节点,多个仅执行第一个
        + 不管子节点是否成功都返回失败
    ]]
}
function M.run(node, env, enemy)
    local yeild, last_ret = node:resume(env)
    if yeild then
        if last_ret == bret.RUNNING then
            return last_ret
        end
        return bret.FAIL
    end

    local r = node.children[1]:run(env)
    if r == bret.RUNNING then
        return node:yield(env)
    end
    return bret.FAIL
end

return M
