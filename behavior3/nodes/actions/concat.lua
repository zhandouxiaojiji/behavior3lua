--[[
    override get descriptor(): NodeDef {
        return {
            name: "Concat",
            type: "Action",
            status: ["success", "failure"],
            desc: "将两个输入合并为一个数组，并返回新数组",
            input: ["数组1", "数组2"],
            output: ["新数组"],
            doc: `
                + 如果输入不是数组，则返回\`失败\`
            `,
        };
    }
]]

local bret = require "behavior3.behavior_ret"

---@type BehaviorNodeDefine
local M = {
    name = "Concat",
    type = "Action",
    desc = "将两个输入合并为一个数组，并返回新数组",
    input = { "数组1", "数组2" },
    output = { "新数组" },
    run = function(node, env, arr1, arr2)
        if not arr1 or not arr2 then
            return bret.FAIL
        end
        local arr = {}
        for _, v in ipairs(arr1) do
            arr[#arr+1] = v
        end
        for _, v in ipairs(arr2) do
            arr[#arr+1] = v
        end
        return bret.SUCCESS, arr
    end
}

return M