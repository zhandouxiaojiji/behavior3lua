local bret = require 'behavior3.behavior_ret'
local process = require 'behavior3.sample_process'
local debugger

local sformat = string.format
local table = table
local print = print

---@class BehaviorNode
local mt = {}
mt.__index = mt

local function new_node(...)
    local obj = setmetatable({}, mt)
    obj:init(...)
    return obj
end

function mt:init(node_data, tree)
    self.tree = tree
    self.name = node_data.name
    self.id = node_data.id
    self.info = sformat('node %s.%s %s', tree.name, self.id, self.name)

    self.data = node_data
    self.args = self.data.args or {}
    ---@type BehaviorNode[]
    self.children = {}
    for _, child_data in ipairs(node_data.children or {}) do
        if not child_data.disabled then
            local child = new_node(child_data, tree)
            table.insert(self.children, child)
        end
    end
end

--- BehaviorNode:run()
---@param env BehaviorEnv
---@return BehaviorRet
function mt:run(env)
    if env.abort then
        return bret.RUNNING
    end
    --print("start", self.name, self.node_id)
    if env:get_inner_var(self, "YIELD") == nil then
        env:push_stack(self)
    end
    local vars = {}
    for i, var_name in ipairs(self.data.input or {}) do
        vars[i] = env:get_var(var_name)
    end
    assert(process[self.name], self.name)
    local func = assert(process[self.name].run, self.name)
    local ok, errmsg = xpcall(function()
        if self.data.input then
            vars = table.pack(func(self, env, table.unpack(vars, 1, #self.data.input)))
        else
            vars = table.pack(func(self, env, table.unpack(vars)))
        end
    end, debug.traceback)
    if not ok then
        error(sformat("node %s run error:%s", self.info, errmsg))
    end

    local ret = vars[1]
    assert(ret, self.info)
    if ret == bret.ABORT then
        env.abort = true
        return bret.RUNNING -- 为了安全退栈
    end
    if ret ~= bret.RUNNING then
        for i, var_name in ipairs(self.data.output or {}) do
            env:set_var(var_name, vars[i + 1])
        end
        env:set_inner_var(self, "YIELD", nil)
        env:pop_stack()
    elseif env:get_inner_var(self, "YIELD") == nil then
        env:set_inner_var(self, "YIELD", true)
    end

    env.last_ret = ret
    --print("fini", self.name, self.node_id, table.unpack(vars, 1, #self.data.input))

    if self.data.debug then
        debugger(self, env, ret)
    end
    return ret
end

function mt:yield(env, arg)
    env:set_inner_var(self, "YIELD", arg or true)
    return bret.RUNNING
end

function mt:resume(env)
    return env:get_inner_var(self, "YIELD"), env.last_ret
end

function mt:get_debug_info(env, ret)
    local var_str = ''
    for k, v in pairs(env.vars) do
        var_str = var_str .. sformat("[%s]=%s,", k, v)
    end
    return sformat("[DEBUG] btree:%s, ret:%s vars:{%s}", self.info, ret, var_str)
end

local btree_funcs = {}
local function btree_func(code, env)
    local func = btree_funcs[code]
    if not func then
        code = code:gsub("!=", "~=")
        func = load("return function(vars, math) _ENV = vars return " .. code .. " end")()
        btree_funcs[code] = func
    end
    return func(env.vars, math)
end

function mt:get_env_args(key, env)
    local a
    if not self.data.args or not self.data.args[key] then
        return
    end
    return btree_func(assert(self.data.args[key], key), env)
end

local M = {}
function M.new(...)
    return new_node(...)
end

function M.process(custom)
    process = custom
end

debugger = function(node, env, ret)
    print(node:get_debug_info(env, ret))
end

function M.set_debugger(func)
    debugger = func
end

return M
