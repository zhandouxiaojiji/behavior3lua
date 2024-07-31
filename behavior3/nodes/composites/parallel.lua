-- Parallel
--

local bret = require 'behavior3.behavior_ret'

---@type BehaviorNodeDefine
local M = {
    name = 'Parallel',
    type = 'Composite',
    desc = '并行执行',
    doc = [[
        执行所有子节点并返回成功
    ]],
    run = function(node, env)
        local count = 0
        local last, last_ret = node:resume(env)
        local level = #env.stack
        last = last or {}

        for i = 1, #node.children do
            local status = nil
            local child = node.children[i]
            local nodes = last[i]
            if nodes == nil then
                status = child:run(env)
            elseif #nodes > 0 then
                while #nodes > 0 do
                    child = table.remove(nodes)
                    env:push_stack(child)
                    status = child:run(env)
                    if status == bret.RUNNING then
                        local p = #nodes + 1
                        while #env.stack > level do
                            table.insert(nodes, p, env:pop_stack())
                        end
                        break
                    end
                end
            else
                status = bret.SUCCESS
            end

            if status == bret.RUNNING then
                if nodes == nil then
                    nodes = {}
                end
                while #env.stack > level do
                    table.insert(nodes, 1, env:pop_stack())
                end
            else
                nodes = {}
                count = count + 1
            end

            last[i] = nodes
        end

        if count == #node.children then
            return bret.SUCCESS
        else
            return node:yield(env, last)
        end
    end
}

return M
