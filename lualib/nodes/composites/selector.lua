-- Selector
--

local bret = require "behavior_ret"

return function(node)
    for _, child in ipairs(node.children) do
        local r = child:run(node.env)
        if r == bret.RUNNING or r == bret.SUCCESS then
            return r
        end
    end
    return bret.FAIL
end
