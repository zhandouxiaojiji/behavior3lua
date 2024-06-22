local bret = require "behavior3.behavior_ret"

---@type BehaviorNodeDefine
local M = {
    name = "ForEach",
    type = 'Composite',
    desc = "遍历数组",
    input = { "[{数组}]" },
    output = { "{变量}" },
    doc = [[
        + 每次执行子节点前会设置当前遍历到的变量
        + 当子节点返回失败时，退出遍历并返回失败状态
        + 其它情况返回成功/正在运行
    ]],
    run = function(node, env, arr)
        local resume_data, resume_ret = node:resume(env)
        local last_i = 1
        local last_j = 1
        if resume_data then
            if resume_ret == bret.RUNNING then
                error(string.format("%s->${%s}#${$d}: unexpected status error",
                    node.tree.name, node.name, node.id))
            end

            last_i = resume_data[1]
            last_j = resume_data[2] + 1
            if last_j > #node.children then
                last_j = 1
                last_i = last_i + 1
            end
        end

        for i = last_i, #arr do
            local var = arr[i]
            env:set_var(node.data.output[1], var)
            for j = last_j, #node.children do
                local child = node.children[j]
                local r = child:run(env)
                if r == bret.RUNNING then
                    return node:yield(env, { i, j })
                elseif r == bret.FAIL then
                    return bret.FAIL
                end
            end
            last_j = 1
        end
        return bret.SUCCESS
    end
}


return M
