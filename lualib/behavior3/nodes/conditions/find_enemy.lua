-- FindEnemy

local bret = require "behavior3.behavior_ret"

local M = {
    name = "FindEnemy",
    type = "Condition",
    desc = "查找敌人",
    args = {
        {"x",     "int?",     "x"},
        {"y",     "int?",     "y"},
        {"w",     "int?",     "宽"},
        {"h",     "int?",     "高"},
        {"count", "string?",  "查找上限"},
    },
    output = {"目标单位"},
    doc = [[
        + 没找到返回失败
    ]]
}

local function ret(r)
    return r and bret.SUCCESS or bret.FAIL
end

function M.run(node, env)
    local args = node.args
    local x, y = env.owner.x, env.owner.y
    local w, h = args.w, args.h
    local list = env.ctx:find(function(t)
        if t == env.owner then
            return false
        end
        local tx, ty = t.x, t.y
        return math.abs(x - tx) <= w and math.abs(y - ty) <= h
    end, args.count)

    local enemy = list[1]
    return ret(enemy), enemy
end

return M