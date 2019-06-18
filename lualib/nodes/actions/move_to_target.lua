-- MoveToTarget
--

local bret = require "behavior_ret"

local abs = math.abs
local SPEED = 50

return function(node, target)
    if not target then
        return bret.FAIL
    end
    local env = node.env
    local owner = env.owner

    local x, y = owner.x, owner.y
    local tx, ty = target.x, target.y

    if abs(x - tx) < SPEED and abs(y - ty) < SPEED  then
        return bret.SUCCESS
    end

    print("Moving", abs(x - tx), abs(y - ty), x, y)

    if abs(x - tx) >= SPEED then
        owner.x = owner.x + SPEED * (tx > x and 1 or -1)
    end

    if abs(y - ty) >= SPEED then
        owner.y = owner.y + SPEED * (ty > y and 1 or -1)
    end

    return bret.RUNNING
end
