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

-- 对比，args:gt,ge,eq,lt,le
function M:Cmp(value)
    assert(type(value) == "number")
    local args = self.args
    if args.gt then
        return value > args.gt
    elseif args.ge then
        return value >= args.ge
    elseif args.eq then
        return value == args.eq
    elseif args.lt then
        return value < args.lt
    elseif args.le then
        return value <= args.le
    else
        error("args error")
    end
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

function M:GetHp()
    return true, self.owner.hp
end

-- 普通攻击
function M:Attack(enemy)
    if not enemy then
        return false
    end

    print("AI 普通攻击")
    return true
end

-- 查找最近的敌人
function M:FindEnemy(w, h)
    local args = self.args
    local x, y = self.owner.x, self.owner.y
    if not w then
        w, h = args.w, args.h
    end
    local list = self.ctx:find(function(t)
        return true
    end, args.count)

    local enemy = list[1]
    if enemy then
        return true, enemy
    else
        return false
    end
end


function M:Idle()
    print("AI 待机")
end

function M:Wait()
    self:set_var("WAIT", self.ctx.time + self.args.time)
    return true
end

function M:Log()
    print(self.args.str)
    return true
end

return M
