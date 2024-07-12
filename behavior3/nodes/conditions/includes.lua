local bret = require "behavior3.behavior_ret"

---@type BehaviorNodeDefine
local M = {
    name = "Includes",
    type = "Condition",
    desc = "判断元素是否在数组中",
    input = { "数组", "元素" },
    doc = [[
        + 若输入的元素不合法，返回「失败」
        + 只有数组包含元素时返回「成功」，否则返回「失败」
    ]],
    run = function(node, env, arr, obj)
        if not arr or #arr == 0 then
            return bret.FAIL
        end
        for _, v in ipairs(arr) do
            if v == obj then
                return bret.SUCCESS
            end
        end
        return bret.FAIL
    end,
}

return M