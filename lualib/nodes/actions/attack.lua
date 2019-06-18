-- Attack
--

local bret = require "behavior_ret"

return function(node, enemy)
    if not enemy then
        return bret.FAIL
    end
    local env = node.env
    local owner = env.owner

    print "Do Attack"
    enemy.hp = enemy.hp - 100

    env.vars.ATTACKING = true

    return bret.SUCCESS
end
