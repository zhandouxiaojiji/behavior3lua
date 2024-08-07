local M = {
    NIL = {}
}

---@param node BehaviorNode
---@param input_idx integer
---@param input_value any
---@param arg_value any
---@param default_value any
---@return any
function M.check_oneof(node, input_idx, input_value, arg_value, default_value)
    local input_name = node.data.input[input_idx]
    local value
    if input_name and input_name ~= "" then
        if input_value == nil then
            local func = default_value == nil and error or print
            func(string.format("%s->${%s}#${%d}: input value is nil",
                node.tree.name, node.name, node.id))
        end
        value = nil
    else
        value = arg_value
    end
    if default_value == M.NIL then
        default_value = nil
    end
    if value == nil then
        return default_value
    else
        return value
    end
end

---@param node BehaviorNode
function M.warn(node, msg)
    print(string.format("[WARN] %s->${%s}#${$d}: %s", node.tree.name, node.name, node.id, msg))
end

return M