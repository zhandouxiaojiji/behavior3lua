-- Cmp

local bret = require "behavior_ret"

local function ret(r)
    return r and bret.SUCCESS or bret.FAIL
end

return function(node, value)
    assert(type(value) == "number")
    local args = node.args
    if args.gt then
        return ret(value > args.gt)
    elseif args.ge then
        return ret(value >= args.ge)
    elseif args.eq then
        return ret(value == args.eq)
    elseif args.lt then
        return ret(value < args.lt)
    elseif args.le then
        return ret(value <= args.le)
    else
        error("args error")
    end
end
