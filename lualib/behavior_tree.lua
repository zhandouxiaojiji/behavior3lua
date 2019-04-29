local Res = require "res.entry"
local BehaviorNode = require "fight.ai.behavior_node"

local mt = {}
mt.__index = mt

function mt:init(avatar, tree_name)
    self.avatar = avatar
    self.map = avatar.map
    self.fight = avatar:get_fight()
    self.tree_name = tree_name
    self.vars = {}
    self.data = Res.get_entry("ai."..tree_name)
    self.tree_id = self.data.tree_id
    self.root = BehaviorNode.new(self.data, self)
end

function mt:run()
    local wait = self:get_var("WAIT")
    if wait and self.fight.time < wait then
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
