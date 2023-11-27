package.path = package.path .. ';lualib/?.lua'

local json = require "json"
local process = require "example.process"

local function processArgs(args)
    local processedArgs = {}
    for i, arg in pairs(args) do
        processedArgs[i] = {
            name = arg.name or '',
            type = arg.type or '',
            desc = arg.desc or '',
            default = arg.default or nil,
        }
    end
    return processedArgs
end

local function trimString(str)
    return (str:gsub('^%s+', ''):gsub('\n%s+', '\n'))
end

local function createNode(v)
    if v.args then
        v.args = processArgs(v.args)
    end

    local doc = type(v.doc) == 'string' and trimString(v.doc) or v.doc

    local node = {
        name   = v.name,
        type   = v.type,
        desc   = v.desc,
        args   = v.args,
        input  = v.input,
        output = v.output,
        doc    = doc,
    }

    return node
end

local nodes = {}
for _, v in pairs(process) do
    local node = createNode(v)
    table.insert(nodes, node)
end

table.sort(nodes, function(a, b)
    return a.name < b.name
end)

local str = json.encode(nodes)
print(str)

local path = "workspace/node-config.json"
local file = io.open(path, "w")
file:write(str)
file:close()

print("save to", path)