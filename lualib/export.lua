local src_path, dest_path = ...

local xml = require("xmlSimple").newParser()
local root = xml:ParseXmlText(io.open(src_path):read("*a"))

local file = io.open(dest_path, "w")
local indent_count = 0

local function indent(count)
    indent_count = indent_count + (count or 2)
end

local function unindent(count)
    indent_count = indent_count - (count or 2)
end

local function write(fmt, ...)
    file:write(string.format(fmt, ...))
end

local function writel(fmt, ...)
    if indent_count > 0 then
        file:write(string.rep(' ', indent_count))
    end
    file:write(string.format(fmt, ...))
    file:write('\n')
end

write('return ')

local function write_node(node, isroot)
    local function node_attr(attr)
        for _, v in ipairs(node:children()) do
            local text = v["@TEXT"]
            if string.find(text, attr) then
                return text, v
            end
        end
    end

    local function node_args(args)
        local str = ""
        for _, v in ipairs(args:children()) do
            str = str .. v["@TEXT"] .. ", "
        end
        return str
    end
    
    local function node_vars(args)
        local str = ""
        for _, v in ipairs(args:children()) do
            str =  string.format("%s\"%s\",",  str, v["@TEXT"])
        end
        return str
    end

    writel('{')
    indent(2)
    writel('name = [[%s]], ', string.match(node["@TEXT"], "(%w+)"))
    writel('desc = [[%s]], ', string.match(node["@TEXT"], "%((.+)%)"))

    local children = {}

    for _, v in ipairs(node:children()) do
        local text = v['@TEXT']
        if text == "args" then
            writel('args = {%s}, ', node_args(v))
        elseif text == "input" then
            writel('input = {%s}, ', node_vars(v))
        elseif text == "output" then
            writel('output = {%s}, ', node_vars(v))
        else
            children[#children + 1] = v
        end
    end

    if #children > 0 then
        writel('children = {')
        indent(2)
        for _, child in ipairs(children) do
            write_node(child)
        end
        unindent(2)
        writel('},')
    end

    unindent(2)
    writel('}%s', isroot and "" or ",")
end

write_node(root.map.node, true)
