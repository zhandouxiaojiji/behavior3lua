local bevent = require 'behavior3.behavior_event'
local bret = require 'behavior3.behavior_ret'

---@type BehaviorNodeDefine
local M = {
    name = "ListenTree",
    type = "Decorator",
    desc = "侦听行为树事件",
    args = {
        {
            name = "builtin",
            type = "enum",
            desc = "事件",
            options = {
                {
                    name = "无",
                    value = "<none>",
                },
                {
                    name = "行为树被中断",
                    value = bevent.INTERRUPTED,
                },
                {
                    name = "行为树开始执行前",
                    value = bevent.BEFORE_RUN,
                },
                {
                    name = "行为树执行完成后",
                    value = bevent.AFTER_RUN,
                },
                {
                    name = "行为树执行成功后",
                    value = bevent.AFTER_RUN_SUCCESS,
                },
                {
                    name = "行为树执行失败后",
                    value = bevent.AFTER_RUN_FAILURE,
                },
            }
        },
        {
            name = "event",
            type = "string?",
            desc = "自定义事件",
        }
    },
    doc = [[
        + 当事件触发时，执行第一个子节点，多个仅执行第一个
        + 如果子节点返回 「运行中」，会中断执行并清理执行栈
    ]],

    run = function(node, env)
        local event = node.args.event or node.args.builtin
        env:on(event, function()
            if #node.children == 0 then
                return
            end
            local level = #env.stack
            local ret = node.children[1]:run(env)
            if ret == bret.RUNNING then
                while #env.stack > level do
                    local child = env:pop_stack()
                    env:set_inner_var(child, "YIELD", nil)
                end
            end
        end)
        return bret.SUCCESS
    end
}

return M
