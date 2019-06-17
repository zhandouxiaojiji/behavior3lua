local ret = require "behavior_ret"

return function(node)
    for _, child in pairs(node.children) do
        local r = child:run(node.env)
        if r == ret.RUNNING or r == ret.SUCCESS then
            return r
        end
    end
    return ret.FAIL
end
