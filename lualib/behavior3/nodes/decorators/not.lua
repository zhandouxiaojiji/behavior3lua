-- Not
--

local bret = require 'behavior3.behavior_ret'

local M = {
    name = 'Not',
    type = 'Decorator',
    desc = '取反',
    doc = [[
        + 将子节点的返回值取反
    ]]
}

function M.run(node, env)
    local yield = node:resume(env)
    local r
    if node:resume(env) then
        r = env.last_ret
    else
        r = node.children[1]:run(env)
    end

    if r == bret.SUCCESS then
        return bret.FAIL
    elseif r == bret.FAIL then
        return bret.SUCCESS
    elseif r == bret.RUNNING then
        return node:yield(env)
    end
end

return M
