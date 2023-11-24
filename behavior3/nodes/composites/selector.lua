-- Selector
--

local bret = require 'behavior3.behavior_ret'

local M = {
    name = 'Selector',
    type = 'Composite',
    desc = '选择执行',
    doc = [[
        + 一直往下执行，只有当所有子节点都返回成功, 才返回成功
        + 子节点是与（AND）的关系
    ]]
}
function M.run(node, env)
    local last_idx, last_ret = node:resume(env)
    if last_idx then
        if last_ret == bret.SUCCESS or last_ret == bret.RUNNING then
            return last_ret
        elseif last_ret == bret.FAIL then
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
        if r == bret.SUCCESS then
            return r
        end
    end
    return bret.FAIL
end

return M
