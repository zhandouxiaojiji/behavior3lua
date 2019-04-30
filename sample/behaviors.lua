-- 节点逻辑

local M = {}
-- 选择执行, 执行所有子节点直到返回true
function M:Or()
    for _, child in ipairs(self.children) do
        if child:run() then
            return true
        end
    end
    return false
end

-- 顺序执行, 执行所有子节点直到返回false
function M:And()
    for _, child in ipairs(self.children) do
        if not child:run() then
            return false
        end
    end
    return true
end

-- 并行执行, 执行所有子节点并反回true
function M:Parallel()
    for i, child in ipairs(self.children) do
        child:run()
    end
end

-- 取反
function M:Not()
    return not self.children[1]:run()
end

function M:NotNull(v)
    return v ~= nil
end

function M:SetNull()
    self:set_var(self.data.input[1], nil)
    return true
end

-- 延时执行(帧)
function M:RunDelay()
    local count = self:get_var(self.node_id) or -1
    count = count + 1
    self:set_var(self.node_id, count)

    if self.args.round == count then
        for _, child in ipairs(self.children) do
            child:run()
        end
        return self.args.ret
    end
    return self.args.ret
end

-- 普通攻击
function M:NormalAttack(enemy)
    if not enemy then
        return false
    end

    print("AI 普通攻击")
    return true
end

-- 查找最近的敌人(从近到远， 返回单个)
function M:FindEnemy(w, h)
    local args = self.args
    local mine = self.avatar
    local x, y = mine:get_pos()
    if not w then
        w, h = args.w, args.h
    end
    local list = self.ctx:find(function(t)
        return true
    end, args.count)


    table.sort(list, function(a, b)
        return Util.distance(mine, a) < Util.distance(mine, b)
    end)

    local enemy = list[1]
    if enemy then
        return true, enemy
    else
        return false
    end
end


-- 查找最近的敌人(从近到远， 返回列表)
function M:FindEnemyList()
    local args = self.args
    local mine = self.avatar
    local x, y = mine:get_pos()
    local w, h = args.w, args.h
    local map = mine:get_map()
    local list = map:find_avatar(function(t)
        if not Util.is_enemy(mine, t) then
            return false
        end
        return Util.is_in_range(t, mine, -w/2, -h/2, w, h)
    end, args.count)

    table.sort(list, function(a, b)
        return Util.distance(mine, a) < Util.distance(mine, b)
    end)

    if #list > 0 then
        return true, list
    else
        return false
    end
end

-- 移动到目标
function M:MoveToTarget(enemy)
    if not enemy then
        return false
    end
    Log.Info("AI 移动到目标", enemy:get_pos())
    local mine = self.avatar
    local x, y = enemy:get_pos()
    mine:move_to(x, y, mine:get_speed())
    return true
end

-- 平台上随机移动
function M:MoveRandom()
    local mine = self.avatar
    local x, y = mine:get_pos()
    local map = mine:get_map()
    local x1, y1, x2, y2 = map.tiled_map:get_floor_ending_pixel(x, y)
    x = math.random(x1, x2)
    mine:move_to(x, y, mine:get_speed())
    return true
end

-- 在巡逻范围内
function M:InPatrolRange()
    local mine = self.avatar
    local x, y = mine:get_pos()
    local range = mine:get_conf().ai.patrol
    local left = self:get_var("patrol_left")
    local right = self:get_var("patrol_right")
    return left and x <= right and x >= left
end

-- 巡逻
function M:MonsterPatrol()
    local mine = self.avatar
    local x, y = mine:get_pos()
    local range = mine:get_conf().ai.patrol
    local left = self:get_var("patrol_left")
    local right = self:get_var("patrol_right")
    local function reset()
        local map = mine:get_map()
        local x1, y1, x2, y2 = map.tiled_map:get_floor_ending_pixel(x, y)
        left = x - range <= x1 and x1 or x - range
        right = x + range >= x2 and x2 or x + range
        self:set_var("patrol_left", left)
        self:set_var("patrol_right", right)
    end
    if not left or x < left or x > right then
        reset()
    end

    if math.abs(x - left) > math.abs(x - right) then
        mine:move_to(left, y, mine:get_speed())
    else
        mine:move_to(right, y, mine:get_speed())
    end

    return true
end

function M:Idle()
    -- todo
    -- Log.Info("AI 待机")
    return true
end

function M:Wait()
    local args = self.args
    local mine = self.avatar
    self:set_var("WAIT", mine:get_fight().time + args.time)
    return true
end

function M:NotMoving()
    return self.avatar:is_idle_moveinfo()
end

return M
