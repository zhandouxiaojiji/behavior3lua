-- Sequence
--

local bret = require 'behavior3.behavior_ret'

local M = {
    name = 'Sequence',
    type = 'Composite',
    desc = '顺序执行',
    doc = [[
        + 一直往下执行，有子节点返回成功则返回成功，若全部节点返回失败则返回失败
        + 子节点是或的关系
    ]]
}

function M.run(node, env)
    local last_idx, last_ret = node:resume(env)
    if last_idx then
        -- print("last", last_idx, last_ret)
        if last_ret == bret.FAIL or last_ret == bret.RUNNING then
            return last_ret
        elseif last_ret == bret.SUCCESS then
            last_idx = last_idx + 1
        else
            error('wrong ret')
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

return M
