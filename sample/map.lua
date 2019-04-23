local mt = {}
function mt:init()
    print("map init")
end

function mt:update()

end

local M = {}
function M.new()
    local obj = setmetatable({}, mt)
    obj:init()
    return obj
end
return M
