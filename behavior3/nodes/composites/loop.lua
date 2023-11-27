local bret = require 'behavior3.behavior_ret'

local M = {
    name = 'Loop',
    type = 'Composite',
    desc = '循环执行',
    args = {
        { name = 'count', type = 'int?', desc = '次数' },
    },
    input = { '次数(int)?' },
}

function M.run(node, env, count)
    count = count or node.args.count
    local resume_data, resume_ret = node:resume(env)
    local last_i = 1
    local last_j = 1
    if resume_data then
        last_i = resume_data[1]
        last_j = resume_data[2]
        if resume_ret == bret.RUNNING then
            return
        else
            last_j = last_j + 1
            if last_j > #node.children then
                last_j = 1
                last_i = last_i + 1
            end
        end
    end

    for i = last_i, count do
        for j = last_j, #node.children do
            local child = node.children[j]
            local r = child:run(env)
            if r == bret.RUNNING then
                return node:yield(env, { i, j })
            end
        end
    end
    return bret.SUCCESS
end

return M
