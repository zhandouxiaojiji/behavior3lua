package.path = package.path .. ';lualib/?.lua'

local olua = require "olua"
local process = require "example.process"

local nodes = {}
for k, v in pairs(process) do
    if v.args then
        for i, vv in pairs(v.args) do
            if #vv > 0 then
                v.args[i] = vv
            end
        end
    end

    local doc = v.doc
    if type(doc) == "string" then
        doc = string.gsub(doc, "^([ ]+", "")
        doc = string.gsub(doc, "\n([ ]+", "\n")
    end

    local node = {
        name     = v.name,
        type     = v.type,
        desc     = v.desc,
        args     = v.args,
        input    = v.input,
        output   = v.output,
        children = v.children,
        status   = v.status,
        doc      = doc,
    }
    table.insert(nodes, node)
end

table.sort(nodes, function(a, b)
    return a.name < b.name
end)

local str = olua.json_stringify(nodes, { indent = 2})
print(str)

local path = "workspace/node-config.b3-setting"
local file = io.open(path, "w")
if file then
    local success, err = pcall(function()
        file:write(str)
    end)
    if not success then
        print("Error writing to file:", err)
    end
    file:close()
else
    print("Error: Unable to open file for writing")
end

print("save to", path)
