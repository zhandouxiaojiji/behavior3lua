local bret = require "behavior3.behavior_ret"

---@type BehaviorNodeDefine
local M = {
    name = "Repeat",
    type = "Decorator",
    desc = "一直尝试直到子节点返回失败",
    input = { "最大循环次数?" },
    args = {
        {
            name = "maxLoop",
            type = "int?",
            desc = "最大循环次数"
        }
    },
    doc = [[
        + 只能有一个子节点，多个仅执行第一个
        + 当子节点返回失败时，退出遍历并返回失败状态
        + 执行完所有子节点后，返回成功
    ]],
    run = function(node, env, max_loop)
        max_loop = max_loop or node.args.maxLoop or math.maxinteger

        local count, resume_ret = node:resume(env)
        if count then
            if resume_ret == bret.FAIL then
                return bret.FAIL
            elseif count >= max_loop then
                return bret.SUCCESS
            else
                count = count + 1
            end
        else
            count = 1
        end

        local r = node.children[1]:run(env)
        if r == bret.FAIL then
            return bret.FAIL
        else
            return node:yield(env, count)
        end
    end
}

return M
