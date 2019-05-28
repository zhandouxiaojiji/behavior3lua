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

function mt:init(data, process, owner, ctx, frame)
    self.process = assert(process)  -- 节点定义，参考sample/behaviors.lua
    self.data    = assert(data)     -- 行为树数据，参考data/hero.lua
    self.owner   = owner            -- 拥有者，通常是角色，怪物等对象
    self.ctx     = ctx              -- 上下文，通常是地图，战斗等对象
    self.frame   = frame            -- 执行频率

    self.tree_name = tree_name
    self.vars      = {}
    self.tree_id   = self.data.tree_id
    self.root      = behavior_node.new(self.data, self)

    self.action = "WAIT" -- 挂起行为
    self.wait   = 0

    self.co = coroutine.create(function()
        while true do
            local ok, err = xpcall(function()
                self.root:run()
            end, debug.traceback)
            if not ok then
                print(err)
                return
            end
            if self.frame then
                self:yield("WAIT", self.frame)
            else
                self:yield("SLEEP") -- 无限等待直到下次 resume("SLEEP")
            end
        end
    end)
end

function mt:update()
    local status = coroutine.status(self.co)
    if status == "suspended" then
        print("waiting")
        if self.action == "SLEEP" or (self.action == "WAIT" and self.ctx.time > self.wait) then
            return
        end
    elseif status == "running" then
        error("repeat run")
    end

    self:resume("WAIT")
end

function mt:resume(action, ...)
    if self.action == action then
        local ret = {coroutine.resume(self.co, ...)}
        if coroutine.status(self.co) == "suspended" then
            self.action = ret[2]
            if self.action == "WAIT" then
                local wait = tonumber(ret[3])
                self.wait = assert(wait, ret[3])
            end
        else
            self.action = nil
        end
    end
end

function mt:yield(action, ...)
    return coroutine.yield(action, ...)
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
