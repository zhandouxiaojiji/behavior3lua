local bret = require "behavior3.behavior_ret"
local butil = require "behavior3.behavior_util"

---@type BehaviorNodeDefine
return {
    name = "SetField",
    type = "Action",
    children = 0,
    status = {"success", "failure"},
    desc = "设置对象字段值",
    input = {"输入对象", "字段(field)?", "值(value)?"},
    args = {
        { name = "field", type = "string?", desc = "字段(field)", oneof = "字段(field)" },
        { name = "value", type = "json?", desc = "值(value)", oneof = "值(value)" },
    },
    doc = [[
        + 对输入对象设置 \`field\` 和 \`value\`
        + 输入参数1必须为对象，否则返回 \`failure\`
        + 如果 \`field\` 不为 \`string\`, 也返回 \`failure\`
        + 如果 \`value\` 为 \`undefined\` 或 \`null\`, 则删除 \`field\` 的值
    ]],

    run = function(node, env, obj, field, value)
        if type(obj) ~= "table" then
            butil.warn(node, "invalid obj")
            return bret.FAIL
        end

        local args = node.args
        field = butil.check_oneof(node, 2, field, args.field)
        value = butil.check_oneof(node, 3, value, args.value, butil.NIL)
        obj[field] = value
        return bret.SUCCESS
    end
}