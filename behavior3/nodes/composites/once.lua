-- Once
--

local bret = require 'behavior3.behavior_ret'

local M = {
    name = "Once",
    type = "Composite",
    desc = "只执行一次",
    doc = [[
        + 可以接多个子节点，子节点默认全部执行
        + 被打断后该节点后的子节点依旧不会执行
        + 该节点执行后永远返回成功
    ]]
}
function M.run(node, env)
    local key = string.format("%s#%d_once", node.name, node.id)
    if env:get_var(key) == true then
        return bret.FAIL
    end

    for _, child in ipairs(node.children) do
        local r = child:run(env)
        if r == bret.RUNNING then
            error(string.format("%s->%s#%d should not return running status",
                node.tree.name, node.name, node.id))
        end
    end

    env:set_var(key, true)
    
    return bret.FAIL
end

return M
