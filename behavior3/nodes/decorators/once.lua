-- Once
--

local bret = require 'behavior3.behavior_ret'

local sformat = string.format

---@type BehaviorNodeDefine
local M = {
    name = "Once",
    type = "Decorator",
    desc = "只执行一次",
    doc = [[
        + 只能有一个子节点,多个仅执行第一个
        + 被打断后该节点后的子节点依旧不会执行
        + 该节点执行后永远返回成功
    ]],
    run = function(node, env)
        local key = sformat("%s#%d_once", node.name, node.id)
        if env:get_var(key) == true then
            return bret.FAIL
        end

        local yeild, last_ret = node:resume(env)
        if yeild then
            if last_ret == bret.RUNNING then
                error(string.format("%s->${%s}#${$d}: unexpected status error",
                    node.tree.name, node.name, node.id))
            end
            env:set_var(key, true)
            return bret.SUCCESS
        end

        local child = node.children[1]
        if not child then
            env:set_var(key, true)
            return bret.SUCCESS
        end

        local r = child:run(env)
        if r == bret.RUNNING then
            return node:yield(env)
        end

        env:set_var(key, true)
        return bret.SUCCESS
    end
}

return M
