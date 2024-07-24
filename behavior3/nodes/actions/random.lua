local bret = require "behavior3.behavior_ret"

---@type BehaviorNodeDefine
local M = {
    name = "Random",
    type = "Action",
    desc = "返回一个随机数",
    input = { "最小值?", "最大值?" },
    output = { "随机数" },
    args = {
        {
            name = "min",
            type = "float?",
            desc = "最小值"
        },
        {
            name = "max",
            type = "float?",
            desc = "最大值"
        },
        {
            name = "floor",
            type = "bool?",
            desc = "是否向下取整"
        }
    },
    run = function(node, env, min, max)
        min = min or node.args.min
        max = max or node.args.max
        local value = min + math.random() * (max - min)
        if node.args.floor then
            value = math.floor(value)
        end
        return bret.SUCCESS, value
    end
}

return M