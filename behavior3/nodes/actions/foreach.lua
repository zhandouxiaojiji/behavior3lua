local bret = require "behavior3.behavior_ret"

---@type BehaviorNodeDefine
local M = {
    name = "ForEach",
    type = 'Action',
    desc = "遍历数组",
    input = { "[{数组}]" },
    output = { "{变量}" },
    doc = [[
        + 只能有一个子节点，多个仅执行第一个
        + 每次执行子节点前会设置当前遍历到的变量
        + 当子节点返回失败时，退出遍历并返回失败状态
        + 其它情况返回成功/正在运行
    ]],
    run = function(node, env, arr)
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

        for i = last_i, #arr do
            local var = arr[i]
            env:set_var(node.data.output[1], var)
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
