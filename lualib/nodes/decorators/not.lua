-- Not
--

local bret = require "behavior_ret"

return function(node, enemy)
    local r = node.children[1]:run(node.env)
    if r == bret.SUCCESS then
        return bret.FAIL
    end
    if r == bret.FAIL then
        return bret.SUCCESS
    end
    return r
end
