local bret = require 'behavior3.behavior_ret'

---@type BehaviorNodeDefine
local M = {
    name = 'Invert',
    type = 'Decorator',
    desc = '取反',
    doc = [[
        + 将子节点的返回值取反
        + 只能有一个子节点，多个仅执行第一个
    ]],
    run = function(node, env)
        local r
        if node:resume(env) then
            r = env.last_ret
        else
            r = node.children[1]:run(env)
        end

        if r == bret.SUCCESS then
            return bret.FAIL
        elseif r == bret.FAIL then
            return bret.SUCCESS
        else
            return node:yield(env)
        end
    end
}

return M
