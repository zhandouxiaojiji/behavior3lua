-- GetHp
--

local bret = require "behavior_ret"

return function(node)
    local env = node.env
    return bret.SUCCESS, env.owner.hp
end
