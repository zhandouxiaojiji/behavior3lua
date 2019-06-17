-- FindEnemy

local bret = require "behavior_ret"

local function ret(r)
    return r and bret.SUCCESS or bret.FAIL
end

return function(node, value)
    local env = node.env
    local args = node.args
    local x, y = env.owner.x, env.owner.y
    if not w then
        w, h = args.w, args.h
    end
    local list = env.ctx:find(function(t)
        local tx, ty = t.x, t.y
        return math.abs(x - tx) <= w and math.abs(y - ty) <= h
    end, args.count)

    local enemy = list[1]
    return ret(enemy), enemy
end
