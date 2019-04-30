local node_id = 1

local mt = {}
mt.__index = mt

local function new_node(...)
    local obj = setmetatable({}, mt)
    obj:init(...)
    return obj
end

function mt:init(node_data, tree)
    self.name = node_data.name
    self.tree = tree
    self.owner = tree.owner
    self.ctx = tree.ctx

    self.node_id = node_id
    node_id = node_id + 1

    self.data = node_data
    self.args = self.data.args or {}
    self.children = {}
    for _, child_data in ipairs(node_data.children or {}) do
        local child = new_node(child_data, tree)
        table.insert(self.children, child)
    end
end

function mt:run()
    local vars = {}
    for i,v in ipairs(self.data.input or {}) do
        vars[i] = self:get_var(v)
    end
    local func = assert(self.tree.process[self.name], self.name)
    vars = table.pack(func(self, table.unpack(vars)))
    for i,v in ipairs(self.data.output or {}) do
        self:set_var(v, vars[i+1])
    end
    return vars[1]
end

function mt:set_var(key, value)
    self.tree:set_var(key, value)
end
function mt:get_var(key)
    return self.tree:get_var(key)
end


local M = {}
function M.new(...)
    return new_node(...)
end
return M
