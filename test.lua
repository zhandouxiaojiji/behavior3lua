package.path = package.path .. ';lualib/?.lua'

local behavior_tree = require "behavior_tree"

local process       = require "sample.behaviors"

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

local btree1 = behavior_tree.new("monster", {
    ctx   = ctx,
    owner = monster,
})

print "run monster ai"
monster.hp = 100
btree1:run()

print "run monster ai"
monster.hp = 20
btree1:run()


local btree2 = behavior_tree.new("hero", {
    ctx   = ctx,
    owner = hero,
})

print "run hero ai"
btree2:run()
btree2:run()
btree2:run()
--btree2:resume("MOVING")
--btree2:resume("ATTACKING", 9999)

btree2:run()
ctx.time = 20
btree2:run()


