local behavior_ret = require "behavior_ret"

local node_id = 1

local mt = {}
mt.__index = mt

local process = {
    Parallel = require "nodes.composites.parallel",
    Selector = require "nodes.composites.selector",
    Sequence = require "nodes.composites.sequence",
}

local function new_node(...)
    local obj = setmetatable({}, mt)
    obj:init(...)
    return obj
end

function mt:init(node_data)
    self.name = node_data.name
    self.node_id = node_id
    self.env = nil

    node_id = node_id + 1

    self.data = node_data
    self.args = self.data.args or {}
    self.children = {}
    for _, child_data in ipairs(node_data.children or {}) do
        local child = new_node(child_data)
        table.insert(self.children, child)
    end
end

function mt:run(env)
    print("start", self.name, self.node_id)
    self.env = env
    if self:is_close() then
        return behavior_ret.CLOSED
    end
    local vars = {}
    for i,v in ipairs(self.data.input or {}) do
        vars[i] = self:get_var(v)
    end
    local func = assert(process[self.name], self.name)
    vars = table.pack(func(self, table.unpack(vars)))
    for i,v in ipairs(self.data.output or {}) do
        self:set_var(v, vars[i+1])
    end
    if vars[1] ~= behavior_ret.RUNNING then
        self:close()
    end
    print("fini", self.name, self.node_id)
    return vars[1]
end

function mt:get_var(key)
    return self.env[key]
end

function mt:set_var(key, value)
    self.env[key] = value
end

function mt:close()
    self.env.close_nodes[self.node_id] = true
end

function mt:is_close()
    return self.env.close_nodes[self.node_id]
end

function mt:is_open()
    return not self.env.close_nodes[self.node_id]
end



local M = {}
function M.new(...)
    return new_node(...)
end
return M
