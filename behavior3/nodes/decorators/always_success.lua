-- AlwaysSuccess
--

local bret = require 'behavior3.behavior_ret'

---@type BehaviorNodeDefine
local M = {
    name = 'AlwaysSuccess',
    type = 'Decorator',
    desc = '始终返回成功',
    doc = [[
        + 只能有一个子节点,多个仅执行第一个
        + 不管子节点是否成功都返回成功
    ]],
    run = function(node, env)
        local yeild, last_ret = node:resume(env)
        if yeild then
            if last_ret == bret.RUNNING then
                error(string.format("%s->${%s}#${$d}: unexpected status error",
                    node.tree.name, node.name, node.id))
            end
            return bret.SUCCESS
        end

        local child = node.children[1]
        if not child then
            return bret.SUCCESS
        end
        local r = child:run(env)
        if r == bret.RUNNING then
            return node:yield(env)
        end
        return bret.SUCCESS
    end
}

return M
