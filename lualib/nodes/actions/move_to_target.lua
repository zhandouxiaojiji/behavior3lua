-- MoveToTarget
--

local bret = require "behavior_ret"

local M = {
    name = "MoveToTarget",
    type = "Action",
    desc = "移动到目标",
    input = {"{目标}"},
}

local abs     = math.abs
local sformat = string.format

local SPEED = 50

function M.run(node, target)
    if not target then
        return bret.FAIL
    end
    local env = node.env
    local owner = env.owner

    local x, y = owner.x, owner.y
    local tx, ty = target.x, target.y

    if abs(x - tx) < SPEED and abs(y - ty) < SPEED  then
        print("Moving reach target")
        return bret.SUCCESS
    end

    print(sformat("Moving (%d, %d) => (%d, %d)", x, y, tx, ty))

    if abs(x - tx) >= SPEED then
        owner.x = owner.x + SPEED * (tx > x and 1 or -1)
    end

    if abs(y - ty) >= SPEED then
        owner.y = owner.y + SPEED * (ty > y and 1 or -1)
    end

    return bret.RUNNING
end

return M