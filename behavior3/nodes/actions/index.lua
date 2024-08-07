local bret = require "behavior3.behavior_ret"

---@type BehaviorNodeDefine
local M = {
    name = "Index",
    type = "Action",
    children = 0,
    desc = "索引输入的数组",
    args = {
        {
            name = "index",
            type = "string",
            desc = "索引",
        }
    },
    input = { "数组", "索引?" },
    output = { "元素" },
    doc = [[
        + 合法元素不包括 undefined 和 null
        + 只有索引到有合法元素时候才会返回「成功」，否则返回「失败」
    ]],
    run = function(node, env, arr, key)
        if not arr then
            return bret.FAIL
        end
        if not key then
            key = tonumber(node.args.index)
        end
        if type(key) ~= "number" then
            print(string.format("%s: index type error", node.info))
            return bret.FAIL
        end

        local value = arr[key + 1]
        if value == nil then
            return bret.FAIL
        end
        return bret.SUCCESS, value
    end,
}

return M