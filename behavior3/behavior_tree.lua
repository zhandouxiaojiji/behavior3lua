local behavior_node = require 'behavior3.behavior_node'
local behavior_ret = require 'behavior3.behavior_ret'
local behavior_event = require 'behavior3.behavior_event'

---@alias BehaviorCallback fun(...)

---@class BehaviorNodeDefine
---@field name string
---@field type string
---@field desc? string
---@field doc? string
---@field input? string[]
---@field output? string[]
---@field args? {name:string, type:string, desc:string, options?:{name:string, value:string}[]}[]
---@field run? fun(node:BehaviorNode, env:BehaviorEnv, ...): BehaviorRet, ...
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

---@class BehaviorTree
local mt = {}
mt.__index = mt
function mt:init(name, tree_data)
    self.name = name
    local data = const(tree_data)
    self.root = behavior_node.new(data.root, self)
end

---@param env BehaviorEnv
---@return BehaviorRet
function mt:run(env)
    local last_ret
    if #env.stack > 0 then
        local last_node = env.stack[#env.stack]
        while last_node do
            last_ret = last_node:run(env)
            if last_ret == behavior_ret.RUNNING then
                break
            end
            last_node = env.stack[#env.stack]
        end
    else
        self:dispatch(env, behavior_event.BEFORE_RUN)
        last_ret = self.root:run(env)
    end
    if env.abort then
        env.inner_vars = {}
        env.stack = {}
        env.abort = nil
        self:dispatch(env, behavior_event.INTERRUPTED)
        return behavior_ret.ABORT
    elseif last_ret == behavior_ret.SUCCESS then
        self:dispatch(env, behavior_event.AFTER_RUN)
        self:dispatch(env, behavior_event.AFTER_RUN_SUCCESS)
    elseif last_ret == behavior_ret.FAIL then
        self:dispatch(env, behavior_event.AFTER_RUN)
        self:dispatch(env, behavior_event.AFTER_RUN_FAILURE)
    end
    return last_ret
end

---@param env BehaviorEnv
---@param event string
---@param ... unknown
function mt:dispatch(env, event, ...)
    if not env.ctx then
        return
    end
    local dispatch_target = env.ctx.dispatch_target
    if dispatch_target then
        env.ctx:dispatch_target(env, event, ...)
    end
end

function mt:interrupt(env)
    if #env.stack > 0 then
        self:dispatch(env, behavior_event.INTERRUPTED)
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
    ---@class BehaviorEnv
    ---@field ctx any?
    ---@field last_ret BehaviorRet?
    ---@field abort boolean?
    ---@field stack BehaviorNode[]
    ---@field inner_vars {[string]: any}
    local env = {
        inner_vars = {}, -- [k.."_"..node.id] => vars
        vars = {},
        stack = {},
    }
    for k, v in pairs(params) do
        env[k] = v
    end

    ---@param k string
    function env:get_var(k)
        return env.vars[k]
    end

    ---@param k string
    ---@param v any
    function env:set_var(k, v)
        if k == "" then return end
        self.vars[k] = v
    end

    ---@param node BehaviorNode
    ---@param k string
    ---@return any
    function env:get_inner_var(node, k)
        return self.inner_vars[k .. '_' .. node.id]
    end

    ---@param node BehaviorNode
    ---@param k string
    ---@param v any
    function env:set_inner_var(node, k, v)
        self.inner_vars[k .. '_' .. node.id] = v
    end

    ---@param node BehaviorNode
    function env:push_stack(node)
        self.stack[#self.stack + 1] = node
    end

    ---@return BehaviorNode
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
            return tree:run(env)
        end,
        interrupt = function()
            tree:interrupt(env)
        end,
        is_running = function ()
            return #env.stack > 0
        end,
        set_env = function (_, k, v)
            if k == "" then return end
            env[k] = v
        end,
        get_env = function ()
            return env
        end
    }
end
return M
