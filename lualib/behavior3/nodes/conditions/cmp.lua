-- Cmp

local bret = require 'behavior3.behavior_ret'

local M = {
    name = 'Cmp',
    type = 'Condition',
    desc = '比较值大小',
    args = {
        {'value', 'lua?', '值'},
        {'gt', 'int?', '>'},
        {'ge', 'int?', '>='},
        {'eq', 'int?', '=='},
        {'le', 'int?', '<='},
        {'lt', 'int?', '<'}
    },
    input = {'值(int)'},
    doc = [[
        + 若值为空，返回失败
        + 非整数类型可能会报错
    ]]
}

local function ret(r)
    return r and bret.SUCCESS or bret.FAIL
end

function M.run(node, env, value)
    assert(type(value) == 'number')
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
        error('args error')
    end
end

return M