package.path = package.path .. ';lualib/?.lua'

local behavior_tree = require "behavior_tree"

local process       = require "sample.behaviors"
local tree_hero     = require "data.hero"
local tree_monster  = require "data.monster"

local monster = {
    hp = 100,
    x = 5,
    y = 0,
}

local hero = {
    hp = 100,
    x = 0,
    y = 0,
}

local ctx = {
    time = 0,
    avatars = {monster, hero},
}
function ctx:find(func)
    local list = {}
    for _, v in pairs(ctx.avatars) do
        if func(v) then
            list[#list+1] = v
        end
    end
    return list
end

local btree1 = behavior_tree.new(tree_monster, process, monster, ctx, 6)

print "update monster ai"
monster.hp = 100
btree1:update()

print "update monster ai"
monster.hp = 20
btree1:update()


local btree2 = behavior_tree.new(tree_hero, process, hero, ctx)

print "update hero ai"
btree2:update()
btree2:update()
btree2:update()
btree2:resume("MOVING")
btree2:resume("ATTACKING", 9999)

btree2:update()
ctx.time = 20
btree2:update()


