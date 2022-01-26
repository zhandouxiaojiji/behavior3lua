-- Parallel
--

local bret = require 'behavior3.behavior_ret'

local M = {
    name = 'Parallel',
    type = 'Composite',
    desc = '并行执行',
    doc = [[
        执行所有子节点并返回成功
    ]]
}
function M.run(node, env)
    local last_idx, last_ret = node:resume(env)
    if last_idx then
        if last_ret == bret.RUNNING then
            return last_ret
        end
        last_idx = last_idx + 1
    else
        last_idx = 1
    end

    for i = last_idx, #node.children do
        local child = node.children[i]
        local r = child:run(env)
        if r == bret.RUNNING then
            return node:yield(env, i)
        end
    end
    return bret.SUCCESS
end

return M
