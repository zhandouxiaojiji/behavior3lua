local bret = require "behavior3.behavior_ret"
local butil = require "behavior3.behavior_util"

---@type BehaviorNodeDefine
return {
    name = "GetField",
    type = "Action",
    children = 0,
    status = {"success", "failure"},
    desc = "获取对象的字段值",
    args = {
        {
            name = "field",
            type = "string?",
            desc = "字段(field)",
            oneof = "字段(field)",
        },
    },
    input = {"对象", "字段(field)?"},
    output = {"字段值(value)"},
    doc = [[
        + 合法元素不包括 \`undefined\` 和 \`null\`
        + 只有获取到合法元素时候才会返回 \`success\`，否则返回 \`failure\`
    ]],

    run = function(node, env, obj, field)
        if type(obj) ~= "table" then
            butil.warn(node, "invalid obj")
            return bret.FAIL
        end
        local args = node.args
        local key = butil.check_oneof(node, 2, field, args.field)
        local value = obj[key]
        if value == nil then
            return bret.FAIL
        end
        return bret.SUCCESS, value
    end
}