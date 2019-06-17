-- GetHp
--

local bret = require "behavior_ret"

return function(node, enemy)
    if not enemy then
        return bret.FALSE
    end
    local env = node.env
    local owner = env.owner

    if node:is_open() then
        if env.states.ATTACKING then
            return bret.RUNNING
        else
            return bret.SUCCESS
        end
    end

    print "Do Attack"
    env.states.ATTACKING = true
    return bret.RUNNING
end
