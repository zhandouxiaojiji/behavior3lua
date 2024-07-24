local bret = require "behavior3.behavior_ret"

---@type BehaviorNodeDefine
local M = {
    name = "RepeatUntilSuccess",
    type = "Decorator",
    desc = "一直尝试直到子节点返回成功",
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
        + 只有当子节点返回成功时，才返回成功，其它情况返回运行中状态
        + 如果设定了尝试次数，超过指定次数则返回失败
    ]],
    run = function(node, env, max_loop)
        max_loop = max_loop or node.args.maxLoop or math.maxinteger

        local count, resume_ret = node:resume(env)
        if count then
            if resume_ret == bret.SUCCESS then
                return bret.SUCCESS
            elseif count >= max_loop then
                return bret.FAIL
            else
                count = count + 1
            end
        else
            count = 1
        end

        local r = node.children[1]:run(env)
        if r == bret.SUCCESS then
            return bret.SUCCESS
        else
            return node:yield(env, count)
        end
    end
}

return M
