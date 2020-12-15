local behavior_node = require 'behavior_node'
local behavior_ret = require 'behavior_ret'
local json = require 'json'

local meta = {
    __newindex = function(_, k)
        error(string.format('readonly:%s', k), 2)
    end
}
local function const(t)
    setmetatable(t, meta)
    for _, v in pairs(t) do
        if type(v) == 'table' then
            const(v)
        end
    end
    return t
end

local trees = {}

local mt = {}
mt.__index = mt
function mt:init(name)
    self.name = name
    self.tick = 0

    local file = io.open('./workspace/trees/' .. name .. '.json', 'r')
    local str = file:read('*a')
    local data = const(json.decode(str))
    self.root = behavior_node.new(data.root, self)
end

function mt:run(env)
    print(string.format('===== tree:%s, tick:%s, stack:%d =====', self.name, self.tick, #env.stack))
    if #env.stack > 0 then
        local last_node = env.stack[#env.stack]
        while last_node do
            local ret = last_node:run(env)
            if ret == behavior_ret.RUNNING then
                break
            end
            last_node = env.stack[#env.stack]
        end
    else
        self.root:run(env)
    end
    self.tick = self.tick + 1
end

local function new_tree(name)
    local tree = setmetatable({}, mt)
    tree:init(name)
    trees[name] = tree
    return tree
end

local function new_env(params)
    local env = {
        inner_vars = {}, -- [k.."_"..node.id] => vars
        vars = {},
        stack = {},
        last_ret = nil
    }
    for k, v in pairs(params) do
        env[k] = v
    end

    function env:get_var(k)
        return env.vars[k]
    end
    function env:set_var(k, v)
        self.vars[k] = v
    end
    function env:get_inner_var(node, k)
        return self.inner_vars[k .. '_' .. node.id]
    end
    function env:set_inner_var(node, k, v)
        self.inner_vars[k .. '_' .. node.id] = v
    end
    function env:push_stack(node)
        self.stack[#self.stack + 1] = node
    end
    function env:pop_stack()
        local node = self.stack[#self.stack]
        self.stack[#self.stack] = nil
        return node
    end
    return env
end

local M = {}
function M.new(name, env_params)
    local env = new_env(env_params)
    local tree = trees[name] or new_tree(name)
    return {
        tree = tree,
        run = function()
            tree:run(env)
        end
    }
end
return M
