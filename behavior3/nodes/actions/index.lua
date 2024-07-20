local bret = require "behavior3.behavior_ret"

---@type BehaviorNodeDefine
local M = {
    name = "Index",
    type = "Action",
    children = 0,
    desc = "索引输入的数组或对象",
    args = {
        {
            name = "idx",
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
        local value
        if #arr > 0 then
            local idx = key or tonumber(node.args.idx)
            if type(key) ~= "number" then
                print(string.format("%s->${%s}#${$d}: index type error",
                    node.tree.name, node.name, node.id))
            end
            value = arr[idx]
        else
            value = arr[key or node.args.idx]
        end

        if value == nil then
            return bret.FAIL
        end
        return bret.SUCCESS, value
    end,
}

return M