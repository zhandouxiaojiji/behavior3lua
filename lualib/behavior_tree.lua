local behavior_node = require "behavior_node"
local behavior_ret  = require "behavior_ret"

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

local mt = {}
mt.__index = mt
function mt:init(tree_name)
    self.tree_name = tree_name

    local data = const(require("data."..tree_name))
    self.root = behavior_node.new(data)
end

function mt:run(env)
    print("==============================")
    local r = self.root:run(env)
    if r ~= behavior_ret.RUNNING then
        env.close_nodes = {}
    end
    print("==============================")
end

local function new_tree(name)
    local tree = setmetatable({}, mt)
    tree:init(name)
    trees[name] = tree
    return tree
end

local M = {}
function M.new(name, env)
    env.close_nodes = {}
    env.open_nodes = {}
    env.vars = {}

    local tree = trees[name] or new_tree(name)
    return {
        tree = tree,
        run = function()
            tree:run(env)
        end,
        set_var = function(_, k, v)
            env.vars[k] = v
        end,
        get_var = function(_, k)
            return env.vars[k]
        end
    }
end
return M
