-- Log
--

local bret = require "behavior_ret"

return function(node)
    print(node.args.str)
    return bret.SUCCESS
end
