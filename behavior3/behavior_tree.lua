local behavior_node = require 'behavior3.behavior_node'
local behavior_ret = require 'behavior3.behavior_ret'
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
function mt:init(name, tree_data)

    self.name = name
    self.tick = 0
    local data = const(tree_data)
    self.root = behavior_node.new(data.root, self)
end

function mt:run(env)
    -- print(string.format('===== tree:%s, tick:%s, stack:%d =====', self.name, self.tick, #env.stack))
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

function mt:interrupt(env)
    if #env.stack > 0 then
        env.inner_vars = {}
        env.stack = {}
    end
end

local function new_tree(name, tree_data)
    local tree = setmetatable({}, mt)
    tree:init(name, tree_data)
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
function M.new(name, tree_data, env_params)
    local env = new_env(env_params)
    local tree = trees[name] or new_tree(name, tree_data)
    return {
        tree = tree,
        run = function()
            tree:run(env)
        end,
        interrupt = function()
            tree:interrupt(env)
        end,
    }
end
return M
