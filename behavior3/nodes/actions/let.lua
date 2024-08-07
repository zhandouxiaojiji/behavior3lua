local bret = require "behavior3.behavior_ret"
local butil = require "behavior3.behavior_util"

---@type BehaviorNodeDefine
local M = {
    name = "Let",
    type = "Action",
    desc = "定义新的变量名",
    input = { "已存在变量名?" },
    args = {
        {
            name= "value",
            type= "json?",
            desc= "值(value)",
            oneof= "已存在变量名",
        }
    },
    output = { "新变量名" },
    doc = [[
        + 如果有输入变量，则给已有变量重新定义一个名字
        +  如果\`值(value)\`为 \`null\`，则清除变量
    ]],
    run = function(node, env, value)
        local args = node.args
        value = butil.check_oneof(node, 1, value, args.value, butil.NIL)
        return bret.SUCCESS, value
    end
}

return M