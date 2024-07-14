local bret = require "behavior3.behavior_ret"

---@type BehaviorNodeDefine
local M = {
    name = "Filter",
    type = "Action",
    desc = "返回满足条件的元素",
    input = { "数组" },
    output = { "变量", "新数组" },
    doc = [[
        + 只能有一个子节点，多个仅执行第一个
        + 当子节点返回「运行中」时，返回「运行中」状态
        + 遍历输入数组，将满足条件的元素放入新数组
        + 当新数组为空时，返回「失败」
    ]],
    run = function(node, env, arr)
        if not arr or #arr == 0 then
            return bret.FAIL
        end

        local new_arr
        local last_i
        local last, resume_ret = node:resume(env)
        if last then
            last_i = last[1]
            new_arr = last[2]
            if resume_ret == bret.RUNNING then
                error(string.format("%s->${%s}#${$d}: unexpected status error",
                    node.tree.name, node.name, node.id))
            elseif resume_ret == bret.SUCCESS then
                new_arr[#new_arr+1] = arr[last_i]
            end
            last_i = last_i + 1
        else
            new_arr = {}
            last_i = 1
        end

        for i = last_i, #arr do
            env:set_var(node.data.output[1], arr[i])
            local r = node.children[1]:run(env)
            if r == bret.RUNNING then
                return node:yield(env, {i, new_arr})
            elseif r == bret.SUCCESS then
                new_arr[#new_arr+1] = arr[i]
            end
        end

        return bret.SUCCESS, nil, new_arr
    end,
}

return M
