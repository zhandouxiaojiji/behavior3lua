local behavior_node = require "behavior_node"

local meta = {
    __newindex = function(_, k)
        error(string.format("readonly:%s", k), 2)
    end
}
local function const(t)
    setmetatable(t, meta)
    for _, v  in pairs(t) do
        if type(v) == "table" then
            const(v)
        end
    end
    return t
end

local trees = {}
local function load_tree(name)
    if trees[name] then
        return trees[name]
    end

    local tree = require("data."..tree_name)
    return const(tree)
end

local mt = {}
mt.__index = mt

function mt:init(data, process, owner, ctx)
    self.process = assert(process)  -- 节点定义，参考sample/behaviors.lua
    self.data    = assert(data)     -- 行为树数据，参考data/hero.lua
    self.owner   = owner            -- 拥有者，通常是角色，怪物等对象
    self.ctx     = ctx              -- 上下文，通常是地图，战斗等对象

    self.tree_name = tree_name
    self.vars = {}
    self.tree_id = self.data.tree_id
    self.root = behavior_node.new(self.data, self)
end

function mt:run()
    local wait = self:get_var("WAIT")
    if wait and self.ctx:get_time() < wait then
        return
    else
        self:set_var("WAIT", nil)
    end
    self.root:run()
end

function mt:get_var(key)
    return self.vars[key]
end

function mt:set_var(key, value)
    self.vars[key] = value
end


local M = {}
function M.new(...)
    local obj = setmetatable({}, mt)
    obj:init(...)
    return obj
end
return M
