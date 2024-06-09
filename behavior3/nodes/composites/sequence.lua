-- Sequence
--

local bret = require 'behavior3.behavior_ret'

---@type BehaviorNodeDefine
local M = {
    name = 'Sequence',
    type = 'Composite',
    desc = '顺序执行',
    doc = [[
        + 一直往下执行，只有当所有子节点都返回成功, 才返回成功
        + 子节点是与（AND）的关系
    ]],
    run = function(node, env)
        local last_idx, last_ret = node:resume(env)
        if last_idx then
            -- print("last", last_idx, last_ret)
            if last_ret == bret.FAIL then
                return last_ret
            elseif last_ret == bret.SUCCESS then
                last_idx = last_idx + 1
            else
                error(string.format("%s->${%s}#${$d}: unexpected status error",
                    node.tree.name, node.name, node.id))
            end
        else
            last_idx = 1
        end

        for i = last_idx, #node.children do
            local child = node.children[i]
            local r = child:run(env)
            if r == bret.RUNNING then
                return node:yield(env, i)
            end
            if r == bret.FAIL then
                return r
            end
        end
        return bret.SUCCESS
    end
}

return M
