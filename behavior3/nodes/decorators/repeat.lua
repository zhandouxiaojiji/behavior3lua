local bret = require "behavior3.behavior_ret"

---@type BehaviorNodeDefine
local M = {
    name = "Repeat",
    type = 'Action',
    desc = "循环执行",
    doc = [[
        + 只能有一个子节点，多个仅执行第一个
        + 当子节点返回「失败」时，退出遍历并返回「失败」状态
        + 其它情况返回成功/正在运行
    ]],
    args = {
        {
            name = "count",
            type = "int?",
            desc = "次数"
        },
    },
    input = { "次数(int)?" },
    run = function(node, env, count)
        count = count or node.args.count
        local last_i, resume_ret = node:resume(env)
        if last_i then
            if resume_ret == bret.RUNNING then
                error(string.format("%s->${%s}#${$d}: unexpected status error",
                    node.tree.name, node.name, node.id))
            elseif resume_ret == bret.FAIL then
                return bret.FAIL
            end
            last_i = last_i + 1
        else
            last_i = 1
        end

        for i = last_i, count do
            local r = node.children[1]:run(env)
            if r == bret.RUNNING then
                return node:yield(env, i)
            elseif r == bret.FAIL then
                return bret.FAIL
            end
        end
        return bret.SUCCESS
    end
}

return M
