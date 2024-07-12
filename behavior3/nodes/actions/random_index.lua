local bret = require "behavior3.behavior_ret"

---@type BehaviorNodeDefine
local M = {
    name = "RandomIndex",
    type = "Action",
    desc = "随机返回输入的其中一个",
    input = { "数组" },
    output = { "随机目标" },
    doc = [[
        + 合法元素不包括 nil
        + 在输入数组中，随机返回其中一个
        + 当输入数组为空时，或者没有合法元素，返回「失败」
    ]],
    run = function(node, env, arr)
        if not arr or #arr == 0 then
            return bret.FAIL
        end
        local idx = math.random(1, #arr)
        return bret.SUCCESS, arr[idx]
    end
}

return M