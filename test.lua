package.path = package.path .. ';lualib/?.lua'

local behavior_tree = require "behavior_tree"

local monster = {
    hp = 100,
    x = 200,
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


local function test_moster()
    local btree = behavior_tree.new("monster", {
        ctx   = ctx,
        owner = monster,
    })

    monster.hp = 100
    btree:run()

    monster.hp = 20
    btree:run()
end


local function test_hero()
    local btree = behavior_tree.new("hero", {
        ctx   = ctx,
        owner = hero,
    })

    -- 移动到目标并攻击
    btree:run()
    btree:run()
    btree:run()
    btree:run()
    btree:run()
    btree:run()

    -- 后摇
    btree:run()
    btree:run()
    ctx.time = 20
    btree:run()
end

test_hero()
test_moster()