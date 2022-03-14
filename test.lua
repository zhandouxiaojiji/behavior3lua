
local behavior_tree = require "behavior3.behavior_tree"
local behavior_node = require "behavior3.behavior_node"
behavior_node.process(require "example.process")

local json = require "json"

local function load_tree(path)
    local file, err = io.open(path, 'r')
    assert(file, err)
    local str = file:read('*a')
    file:close()
    return json.decode(str)
end

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

local function test_hero()
    print("=================== test hero ========================")
    local btree = behavior_tree.new("hero", load_tree("workspace/trees/hero.json"), {
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
    btree:interrupt()
    btree:run()
    ctx.time = 20
    btree:run()
end

test_hero()


local function test_moster()
    print("=================== test monster ========================")
    local btree = behavior_tree.new("monster", load_tree("workspace/trees/monster.json"), {
        ctx   = ctx,
        owner = monster,
    })

    monster.hp = 100
    btree:run()

    monster.hp = 20
    btree:run()
    ctx.time = 40
    btree:run()
    btree:run()
end

test_moster()