-- AlwaysSuccess
--

local bret = require "behavior_ret"

return function(node, enemy)
    local r = node.children[1]:run(node.env)
    if r == bret.RUNNING or r == bret.CLOSED then
        return r
    end
    return bret.SUCCESS
end
