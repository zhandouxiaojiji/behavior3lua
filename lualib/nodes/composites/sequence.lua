-- Sequence
--

local bret = require "behavior_ret"

return function(node)
    for _, child in pairs(node.children) do
        local r = child:run(node.env)
        if r == bret.RUNNING or r == bret.FAIL then
            return r
        end
    end
    return bret.SUCCESS
end
