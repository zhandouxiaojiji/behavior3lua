local bret = require "behavior_ret"

local sformat = string.format
local node_id = 1

local mt = {}
mt.__index = mt

local process = {
    -- 复合节点
    Parallel = require "nodes.composites.parallel",
    Selector = require "nodes.composites.selector",
    Sequence = require "nodes.composites.sequence",

    -- 装饰节点
    Not           = require "nodes.decorators.not",
    AlwaysFail    = require "nodes.decorators.always_fail",
    AlwaysSuccess = require "nodes.decorators.always_success",

    -- 条件节点
    Cmp       = require "nodes.conditions.cmp",
    FindEnemy = require "nodes.conditions.find_enemy",

    -- 行为节点
    Log          = require "nodes.actions.log",
    GetHp        = require "nodes.actions.get_hp",
    Attack       = require "nodes.actions.attack",
    MoveToTarget = require "nodes.actions.move_to_target",
    Idle         = require "nodes.actions.idle",
    Wait         = require "nodes.actions.wait",
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
    --print("start", self.name, self.node_id)
    self.env = env
    if self:is_close() then
        return bret.CLOSED
    end
    local vars = {}
    for i,v in ipairs(self.data.input or {}) do
        vars[i] = self:get_var(v)
    end
    local func = assert(process[self.name].run, self.name)
    vars = table.pack(func(self, table.unpack(vars)))
    assert(vars[1], sformat("node %s return nil", self.name))
    for i,v in ipairs(self.data.output or {}) do
        self:set_var(v, vars[i+1])
    end
    if vars[1] == bret.RUNNING then
        self:open()
    else
        self:close()
    end
    --print("fini", self.name, self.node_id, table.unpack(vars))
    return vars[1]
end

function mt:get_var(key)
    return self.env.vars[key]
end

function mt:set_var(key, value)
    self.env.vars[key] = value
end

function mt:close()
    self.env.open_nodes[self.node_id] = nil
    self.env.close_nodes[self.node_id] = true
end

function mt:open()
    self.env.open_nodes[self.node_id] = true
    self.env.close_nodes[self.node_id] = nil
end

function mt:is_close()
    return self.env.close_nodes[self.node_id]
end

function mt:is_open()
    return self.env.open_nodes[self.node_id]
end



local M = {}
function M.new(...)
    return new_node(...)
end
return M
