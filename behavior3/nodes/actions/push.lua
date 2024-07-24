local bret = require "behavior3.behavior_ret"

---@type BehaviorNodeDefine
local M = {
    name = "Push",
    type = "Action",
    desc = "向数组中添加元素",
    input = { "数组", "元素" },
    doc = [[
        + 当输入的“数组”不是数组类型时返回「失败」
        + 其余返回「成功」。
    ]],
    run = function(node, env, arr, value)
        if not arr then
            return bret.FAIL
        end
        arr[#arr+1] = value
        return bret.SUCCESS
    end
}

return M