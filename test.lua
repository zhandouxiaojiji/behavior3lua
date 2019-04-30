package.path = package.path .. ';lualib/?.lua'

local behavior_tree = require "behavior_tree"

local process       = require "sample.behaviors"
local tree_hero     = require "data.hero"
local tree_monster  = require "data.monster"

local ctx = {
    time = 0,
}
local monster = {
    hp = 100,
}

local btree = behavior_tree.new(tree_monster, process, monster, ctx)

print("run monster ai")
monster.hp = 100
btree:run()

print("run monster ai")
monster.hp = 20
btree:run()
