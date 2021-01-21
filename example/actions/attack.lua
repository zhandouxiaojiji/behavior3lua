-- Attack
--

local bret = require "behavior3.behavior_ret"
local M = {
    name = "Attack",
    type = "Action",
    desc = "攻击",
    input = {"{目标}"},
}

function M.run(node, env, enemy)
    if not enemy then
        return bret.FAIL
    end
    local owner = env.owner

    print "Do Attack"
    enemy.hp = enemy.hp - 100

    env.vars.ATTACKING = true

    return bret.SUCCESS
end

return M