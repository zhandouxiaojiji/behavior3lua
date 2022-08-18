local bret = require 'behavior3.behavior_ret'
local process = require 'behavior3.sample_process'

local sformat = string.format
local table = table
local print = print

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
    self.children = {}
    for _, child_data in ipairs(node_data.children or {}) do
        local child = new_node(child_data, tree)
        table.insert(self.children, child)
    end
end

function mt:run(env)
    --print("start", self.name, self.node_id)
    if env:get_inner_var(self, "YIELD") == nil then
        env:push_stack(self)
    end
    local vars = {}
    for i, var_name in ipairs(self.data.input or {}) do
        vars[i] = env:get_var(var_name)
    end
    local func = assert(process[self.name].run, self.name)
    if self.data.input then
        vars = table.pack(func(self, env, table.unpack(vars, 1, #self.data.input)))
    else
        vars = table.pack(func(self, env, table.unpack(vars)))
    end
    local ret = vars[1]
    assert(ret, self.info)
    if ret ~= bret.RUNNING then
        env:set_inner_var(self, "YIELD", nil)
        env:pop_stack()
    end
    for i, var_name in ipairs(self.data.output or {}) do
        env:set_var(var_name, vars[i + 1])
    end
    env.last_ret = ret
    --print("fini", self.name, self.node_id, table.unpack(vars, 1, #self.data.input))

    if self.data.debug then
        local var_str = ''
        for k, v in pairs(env.vars) do
            var_str = sformat("[%s]=%s,", k, v)
        end
        print(sformat("[DEBUG] btree:%s, node:%s, ret:%s vars:{%s}",
        self.tree.name, self.id, ret, var_str))
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

local M = {}
function M.new(...)
    return new_node(...)
end
function M.process(custom)
    process = custom
end
return M
