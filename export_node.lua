package.path = package.path .. ';lualib/?.lua'

local json = require "json"
local process = require "example.process"

local nodes = {}
for k, v in pairs(process) do  
    if v.args then             
        for i, vv in pairs(v.args) do   
            v.args[i] = {      
                name = vv[1],  
                type = vv[2],  
                desc = vv[3],  
            }
        end
    end
    
    local doc = v.doc          
    if type(doc) == "string" then   
        doc = string.gsub(doc, "^([ ]+", "")
        doc = string.gsub(doc, "\n([ ]+", "\n")
    end
    
    local node = {
        name   = v.name,       
        type   = v.type,       
        desc   = v.desc,       
        args   = v.args,       
        input  = v.input,      
        output = v.output,     
        doc    = doc,          
    }
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