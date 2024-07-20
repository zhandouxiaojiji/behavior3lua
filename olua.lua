local cjson

xpcall(function ()
    cjson = require "cjson.safe"
end, function ()
    cjson = {}
end)

local is_windows = package.config:find("\\")

local _ipairs = ipairs
function ipairs(t)
    local mt = getmetatable(t)
    return (mt and mt.__ipairs or _ipairs)(t)
end

local _pairs = pairs
function pairs(t)
    local mt = getmetatable(t)
    return (mt and mt.__pairs or _pairs)(t)
end

olua = {}

---Suppress warnings and hook the value used in `olua.format`.
---@param ... unknown
function olua.use(...) end

function olua.print(fmt)
    print(olua.format(fmt))
end

function olua.isdir(path)
    if not string.find(path, "[/\\]$") then
        path = path .. "/"
    end
    local ok, err, code = os.rename(path, path)
    if not ok then
        if code == 13 then
            return true
        end
    end
    return ok, err
end

function olua.mkdir(dir)
    if not olua.isdir(dir) then
        if is_windows then
            os.execute("mkdir " .. dir:gsub("/", "\\"))
        else
            os.execute("mkdir -p " .. dir)
        end
    end
end

function olua.write(path, content)
    path = olua.format(path)
    local f = io.open(path, "rb")
    if f then
        local flag = f:read("*a") == content
        f:close()
        if flag then
            olua.print("up-to-date: ${path}")
            return
        end
    end

    olua.print("write: ${path}")

    local dir = path:match("(.*)/[^/]+$")
    if dir then
        olua.mkdir(dir)
    end

    f = io.open(path, "w+b")
    assert(f, path)
    f:write(content)
    f:flush()
    f:close()
end

-------------------------------------------------------------------------------
-- Error handle
-------------------------------------------------------------------------------

local willdo = ""

---Will do the job.
---@param message string
function olua.willdo(message)
    willdo = olua.format(message)
end

local function throw_error(msg)
    if #willdo > 0 then
        print(willdo)
    end
    error(msg)
end

---Throw error.
---@param message string
function olua.error(message)
    throw_error(olua.format(message))
end

---Check the value
---@generic T
---@param value T
---@param message? string
---@return T
function olua.assert(value, message)
    if not value then
        olua.error(message or "<no assert info>")
    end
    return value
end

-------------------------------------------------------------------------------
-- array & map & string
-------------------------------------------------------------------------------

---Split the string.
---@param str string
---@param sep string
---@return array
function olua.split(str, sep)
    local arr = olua.array()
    for s in str:gmatch("([^" .. sep .. "]+)") do
        arr:push(s)
    end
    return arr
end

---Join the array.
---@param arr array
---@param sep string
---@param prefix? string
---@param posfix? string
---@return unknown
function olua.join(arr, sep, prefix, posfix)
    prefix = prefix or ""
    posfix = posfix or ""
    return prefix .. table.concat(arr, sep) .. posfix
end

---Clone a table.
---@param t table
---@param new? table
function olua.clone(t, new)
    new = new or {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            if v.clone then
                new[k] = v:clone()
            else
                new[k] = olua.clone(v)
            end
        else
            new[k] = v
        end
    end
    return new
end

---Get the keys of a table.
---@param t table
---@return array
function olua.keys(t)
    local keys = olua.array()
    for k in pairs(t) do
        keys:push(k)
    end
    return keys
end

---Iterate over the table.
---@param t table
---@param fn fun(value:any, key:string|integer, t:table)
function olua.foreach(t, fn)
    for k, v in pairs(t) do
        fn(v, k, t)
    end
end

---Get the values of a table.
---@param t table
---@return array
function olua.values(t)
    local values = olua.array()
    for _, v in pairs(t) do
        values:push(v)
    end
    return values
end

---Sort the table.
---@param t table
---@param field? string|fun(a:any, b:any):boolean
function olua.sort(t, field)
    if type(field) == "function" then
        table.sort(t, field)
    elseif field then
        table.sort(t, function (a, b)
            return a[field] < b[field]
        end)
    else
        table.sort(t)
    end
    return t
end

---@param t any
---@return array
function olua.make_array(t)
    local arr = olua.array()
    setmetatable(t, getmetatable(arr))
    return t
end

---@param t any
---@return ordered_map
function olua.make_ordered_map(t)
    local map = olua.ordered_map()
    for k, v in pairs(t) do
        map:set(k, v)
        t[k] = nil
    end
    setmetatable(map, nil)
    for k, v in pairs(map) do
        t[k] = v
    end
    setmetatable(t, t)
    return t
end

---Create a new array.
---@param sep? string
---@param prefix? string
---@param posfix? string
---@return array
function olua.array(sep, prefix, posfix)
    ---@class array
    ---@field private __tostring fun(self):string
    ---@field private __olua_type string
    local array = {
        __olua_type = "olua.array"
    }

    local joiner = { sep = sep, prefix = prefix, posfix = posfix }

    local function __tostring(self)
        return self:join(joiner.sep or "", joiner.prefix, joiner.posfix)
    end

    if sep then
        array.__tostring = __tostring
    end

    ---@private
    array.__index = array

    ---Clear the array.
    function array:clear()
        for i = 1, #self do
            self[i] = nil
        end
    end

    ---Clone the array.
    ---@return array
    function array:clone()
        local arr = olua.array(joiner.sep, joiner.prefix, joiner.posfix)
        for _, v in ipairs(self) do
            arr:push(olua.clone(v))
        end
        return arr
    end

    ---Get an element at the given index. If `index` is negative, it is relative to the end of the array.
    ---@param index integer
    ---@return any
    function array:at(index)
        if index < 0 then
            index = #self + index + 1
        end
        return self[index]
    end

    ---Push an element at the end of the array. If `value` is `nil`, nothing is done.
    ---@param value any
    ---@return any # Return `value`.
    function array:push(value)
        if value ~= nil then
            table.insert(self, value)
        end
        return value
    end

    ---Push a formatting string at the end of the array.
    ---@param value string
    ---@param indent? integer
    ---@return self
    function array:pushf(value, indent)
        self:push(olua.format(value, indent))
        return self
    end

    ---Remove and return the last element of the array.
    ---@return any
    function array:pop()
        return table.remove(self)
    end

    ---Remove and return the first element of the array.
    function array:shift()
        return table.remove(self, 1)
    end

    ---Push an element at the beginning of the array. If `value` is `nil`, nothing is done.
    ---@param value any
    function array:unshift(value)
        if value ~= nil then
            table.insert(self, 1, value)
        end
    end

    ---Insert an element at the specified position. If `value` is `nil`, nothing is done.
    ---@param index integer
    ---@param value any
    function array:insert(index, value)
        if value ~= nil then
            table.insert(self, index, value)
        end
    end

    ---Remove an element from the array.
    ---@param value any
    function array:remove(value)
        for i = 1, #self do
            if self[i] == value then
                table.remove(self, i)
                break
            end
        end
    end

    ---Remove an element at the specified position from the array.
    ---@param index any
    ---@return unknown|nil
    function array:remove_at(index)
        if index >= 1 and index <= #self then
            return table.remove(self, index)
        end
    end

    ---Concatenate the array with another array.
    ---@param arr any[]
    ---@return self
    function array:concat(arr)
        for _, v in ipairs(arr) do
            self:push(v)
        end
        return self
    end

    ---
    ---Return the index of the value, or 0 if not found.
    ---
    ---@param value any
    ---@return integer
    function array:index_of(value)
        for i, v in ipairs(self) do
            if v == value then
                return i
            end
        end
        return 0
    end

    ---Sort the array.
    ---@param fn? string | fun(a:any, b:any):boolean
    ---@return self
    function array:sort(fn)
        return olua.sort(self, fn)
    end

    ---Get a slice of the array.
    ---@param from? integer
    ---@param to? integer
    ---@return array
    function array:slice(from, to)
        local arr = olua.array(joiner.sep, joiner.prefix, joiner.posfix)
        for i = from or 1, to or #self do
            if i > #self then
                break
            end
            arr:push(self[i])
        end
        return arr
    end

    ---Iterate over the array.
    ---@param fn fun(value:any, index:integer, array:array)
    function array:foreach(fn)
        for k, v in ipairs(self) do
            fn(v, k, self)
        end
    end

    ---Join the array with a separator.
    ---@param sep string
    ---@param prefix? string
    ---@param posfix? string
    ---@diagnostic disable-next-line: redefined-local
    function array:join(sep, prefix, posfix)
        prefix = prefix or ""
        posfix = posfix or ""
        return prefix .. table.concat(self, sep) .. posfix
    end

    ---Return a new array with unique values.
    ---@return array
    function array:toset()
        local filter = {}
        local arr = olua.array(joiner.sep, joiner.prefix, joiner.posfix)
        for _, v in ipairs(self) do
            if not filter[v] then
                arr:push(v)
                filter[v] = true
            end
        end
        return arr
    end

    ---Return a new array with filtered values.
    ---@param fn fun(value:any, index:integer, array:array):boolean
    ---@return array
    function array:filter(fn)
        local arr = olua.array(joiner.sep, joiner.prefix, joiner.posfix)
        for i, v in ipairs(self) do
            if fn(v, i, self) then
                arr:push(v)
            end
        end
        return arr
    end

    ---Find an element in the array.
    ---@param fn fun(value:any, index:integer, array:array):boolean
    ---@return any
    function array:find(fn)
        for i, v in ipairs(self) do
            if fn(v, i, self) then
                return v
            end
        end
    end

    ---Calls a defined callback function on each element of an array, and returns an array that contains the results.
    ---@param fn fun(value:any, index:integer, array:array):any
    ---@return array
    function array:map(fn)
        local arr = olua.array(joiner.sep, joiner.prefix, joiner.posfix)
        for i, v in ipairs(self) do
            arr:push(fn(v, i, self))
        end
        return arr
    end

    return setmetatable({}, array)
end

---Create a new ordered map.
---@param overwritable? boolean Can overwrite the value with the same key, default is `true`.
---@return ordered_map
function olua.ordered_map(overwritable)
    ---@class ordered_map
    ---@field private _keys array
    ---@field private _map table
    local ordered_map = {
        __olua_type = "olua.ordered_map",
        _keys = olua.array(),
        _map = {}
    }

    overwritable = overwritable ~= false

    ---@private
    ---@param key string|integer
    ---@return any
    function ordered_map:__index(key)
        return self:get(key)
    end

    ---@private
    ---@param key string|integer
    ---@param value any
    function ordered_map:__newindex(key, value)
        self:set(key, value)
    end

    ---@private
    function ordered_map:__len()
        return #self._keys
    end

    ---@private
    function ordered_map:__pairs()
        return pairs(self._map)
    end

    ---@private
    function ordered_map:__ipairs()
        return ipairs(self:values())
    end

    ---Clone the ordered map.
    ---@return ordered_map
    function ordered_map:clone()
        local new_map = olua.ordered_map(overwritable)
        self:foreach(function (value, key)
            new_map:set(key, olua.clone(value))
        end)
        return new_map
    end

    ---Set value with the key.
    ---@param key any
    ---@param value any
    function ordered_map:set(key, value)
        if self._keys:index_of(key) == 0 then
            if value ~= nil then
                self._map[key] = value
                self._keys:push(key)
            end
        elseif overwritable then
            self._map[key] = value
            if value == nil then
                self._keys:remove(key)
            end
        else
            error(string.format("key '%s' already exists", key))
        end
    end

    ---Replace value with the key.
    ---@param key string|integer
    ---@param value any
    function ordered_map:replace(key, value)
        self._map[key] = value
        if self._keys:index_of(key) == 0 then
            self._keys:push(key)
        end
    end

    ---Get value with the key.
    ---@param key string|integer
    ---@return unknown
    function ordered_map:get(key)
        return self._map[key]
    end

    ---Check if the key exists.
    ---@param key string|integer
    ---@return boolean
    function ordered_map:has(key)
        return self._map[key] ~= nil
    end

    ---Remove value with the key.
    ---@param key string|integer
    function ordered_map:remove(key)
        self._keys:remove(key)
        self._map[key] = nil
    end

    ---Take value with the key.
    ---@param key string|integer
    ---@return any
    function ordered_map:take(key)
        local value = self._map[key]
        self._keys:remove(key)
        self._map[key] = nil
        return value
    end

    ---Iterate over the ordered map.
    ---@param fn fun(value:any, key:string|integer, map:ordered_map)
    function ordered_map:foreach(fn)
        local keys = self._keys:slice()
        for _, key in ipairs(keys) do
            fn(self._map[key], key, self)
        end
    end

    ---Clear the ordered map.
    function ordered_map:clear()
        self._keys:clear()
        self._map = {}
    end

    ---Return values of the ordered.
    ---@return array
    function ordered_map:values()
        local arr = olua.array()
        for _, key in ipairs(self._keys) do
            arr:push(self._map[key])
        end
        return arr
    end

    ---Return keys of the ordered.
    ---@return array
    function ordered_map:keys()
        return self._keys
    end

    ---Sort the ordered map.
    ---@param fn? fun(a:any, b:any):boolean
    function ordered_map:sort(fn)
        self._keys:sort(fn)
        return self
    end

    ---@alias insertmode
    ---|>'"front"'
    ---| '"after"'
    ---| '"before"'
    ---| '"back"'

    ---Insert an element into the ordered map.
    ---@param mode insertmode
    ---@param at_key string|number|nil
    ---@param key string|number
    ---@param value any
    function ordered_map:insert(mode, at_key, key, value)
        local idx = 0
        if mode == "front" then
            idx = 1
        elseif mode == "after" then
            idx = self._keys:index_of(at_key)
            if idx == 0 then
                idx = #self._keys + 1
            else
                idx = idx + 1
            end
        elseif mode == "before" then
            idx = self._keys:index_of(at_key)
            if idx == 0 then
                idx = 1
            end
        elseif mode == "back" then
            idx = #self._keys + 1
        else
            olua.error("invalid insert mode: ${insertmode}")
        end
        self._keys:insert(idx, key)
        self._map[key] = value
    end

    return setmetatable(ordered_map, ordered_map)
end

-------------------------------------------------------------------------------
--- string util
-------------------------------------------------------------------------------

local FORMAT_PATTERN = "${[%w_.?#()]+}"
local curr_expr = nil

function olua.is_end_with(str, substr)
    local _, e = str:find(substr, #str - #substr + 1, true)
    return e == #str
end

---@param level integer
---@param key string
---@return any
local function lookup(level, key)
    assert(key and #key > 0, key)

    while true do
        local value
        local searchupvalue = true

        local info1 = debug.getinfo(level, "fu")
        for i = 1, 256 do
            local k, v = debug.getlocal(level, i)
            if i <= info1.nparams and v == curr_expr then
                searchupvalue = false
            end
            if k == key then
                if type(v) ~= "string" or not v:find(FORMAT_PATTERN) then
                    value = v
                end
            elseif not k then
                break
            end
        end

        if value ~= nil then
            return value
        end

        if searchupvalue then
            for i = 1, info1.nups do
                local k, v = debug.getupvalue(info1.func, i)
                if k == key then
                    return v
                end
            end
            break
        else
            level = level + 1
        end
    end
end

local function lookup_key_expr(level, key_expr)
    local key = string.match(key_expr, "[%w_]+")
    local value = lookup(level, key)
    local first = true
    value = value == nil and _G[key] or value
    for field in string.gmatch(key_expr, "[^.]+") do
        if first then
            first = false
        elseif value == nil then
            break
        else
            value = value[field]
        end
    end
    return value
end

---@param line string
---@param indent integer
local function eval(line, indent)
    local drop = false
    local function replace(str)
        local level = 1
        while true do
            local info = debug.getinfo(level, "Sfn")
            if info then
                if string.find(info.source, "olua.lua$") and
                    info.func == olua.format
                then
                    break
                else
                    level = level + 1
                end
            else
                break
            end
        end

        local leading_space = string.match(line, " *")
        local value, opt, fix

        local fn, key = string.match(str, "([%w_.]+)%(([%w_.]+)%)")
        if fn then
            --- in lookup func, olua.format is level + 2(lookup_key_expr + lookup)
            local func = lookup_key_expr(level + 3, fn)
            if not func then
                throw_error(string.format("function '%s' not found used by '%s'", fn, str))
            end

            value = lookup_key_expr(level + 3, key)
            if not value then
                throw_error(string.format("value '%s' not found used by '%s'", key, str))
            end

            value = func(value)
            if value == nil then
                throw_error(string.format("%s(%s) return nil in '%s'", fn, key, str))
            end
        else
            -- search in the functin local value
            key = string.match(str, "[%w_]+")
            opt = string.match(str, "%?+")
            fix = string.match(str, "#")
            value = lookup(level + 2, key)
            value = value == nil and _G[key] or value
            for field in string.gmatch(string.match(str, "[%w_.]+"), "[^.]+") do
                if value == nil then
                    break
                elseif field ~= key then
                    value = value[field]
                end
            end
        end

        if value == nil and not opt then
            throw_error("value not found for '" .. str .. "'")
        end

        -- indent the value if value has multiline
        local prefix, posfix = "", ""
        if type(value) == "table" then
            local mt = getmetatable(value)
            if mt and mt.__tostring then
                value = tostring(value)
            else
                throw_error("no meta method '__tostring' for " .. str)
            end
        elseif value == nil then
            drop = opt == "??"
            value = "nil"
        elseif type(value) == "string" then
            value = value:gsub("[\n]*$", "")
            if opt then
                value = olua.trim(value)
                if value:find("[\n\r]") then
                    value = "\n" .. value
                    prefix = "[["
                    posfix = "\n" .. leading_space .. "]]"
                    leading_space = leading_space .. string.rep(" ", indent)
                elseif value:find('[\'"]') then
                    value = "[[" .. value .. "]]"
                else
                    value = "'" .. value .. "'"
                end
            end
        else
            value = tostring(value)
        end

        if fix then
            value = value:gsub("[^%w_]+", "_"):gsub("_+$", "")
        end

        return prefix .. value:gsub("\n", "\n" .. leading_space) .. posfix
    end
    line = line:gsub(FORMAT_PATTERN, replace)
    return not drop and line or nil
end

---@param expr string
---@param indent integer
local function doeval(expr, indent)
    local arr = {}
    local idx = 1
    while idx <= #expr do
        local from, to = string.find(expr, "[\n\r]", idx)
        if not from then
            from = #expr + 1
            to = from
        end
        arr[#arr + 1] = eval(string.sub(expr, idx, from - 1), indent)
        idx = to + 1
    end
    return table.concat(arr, "\n")
end

---Trim the expression.
---@param expr string
---@param indent? integer
---@param keepspace? boolean
---@return string
function olua.trim(expr, indent, keepspace)
    if type(expr) == "string" then
        local idx
        expr, idx = expr:gsub("[\n\r]", "\n")
        if idx > 0 or not keepspace then
            expr = expr:gsub("^[\n]*", "")  -- trim head '\n'
            expr = expr:gsub("[ \n]*$", "") -- trim tail '\n' or ' '
            local space = string.match(expr, "^[ ]*")
            expr = expr:gsub("^[ ]*", "")   -- trim head space
            expr = expr:gsub("\n" .. space, "\n")
            if indent and indent ~= 4 then
                expr = expr:gsub("\n( +)", function (spaces)
                    local n = #spaces // 4
                    return "\n" .. string.rep(" ", n * indent)
                end)
            end
        end
    end
    return expr
end

---Format the expression.
---
--- Example:
--- ```lua
--- olua.format("${path}/output")
--- olua.format("${olua.tostring(file.path)}")
--- ```
---@param expr string
---@param indent? integer
---@return string
function olua.format(expr, indent)
    curr_expr = expr
    expr = doeval(olua.trim(expr, indent, true), indent or 4)

    while true do
        local s, n = expr:gsub("\n[ ]+\n", "\n\n")
        expr = s
        if n == 0 then
            break
        end
    end

    while true do
        local s, n = expr:gsub("\n\n\n", "\n\n")
        expr = s
        if n == 0 then
            break
        end
    end

    expr = expr:gsub("{\n\n", "{\n")
    expr = expr:gsub("\n\n}", "\n}")

    return expr
end

-- TODO: rm
function olua.command_proxy(cmd, parent)
    local proxy = {}
    assert(cmd.__proxy == nil, "already add command proxy")
    cmd.__proxy = proxy
    function proxy.__index(_, key)
        local f = cmd[key]
        if f then
            return function (...)
                return f(...) or proxy
            end
        elseif parent and parent.__proxy then
            return parent.__proxy[key]
        else
            error(string.format("command '%s' not found", key))
        end
    end

    function proxy.__newindex(_, key, value)
        error(string.format("create command '%s' is not allowed", key))
    end

    return setmetatable(proxy, proxy)
end

---@param t any
---@param name string
---@return boolean
function olua.has_metafield(t, name)
    return olua.get_metafield(t, name) ~= nil
end

---@param t any
---@param name string
---@return unknown
function olua.get_metafield(t, name)
    local mt = getmetatable(t)
    return mt and mt[name]
end

-------------------------------------------------------------------------------
--- stringify
-------------------------------------------------------------------------------

local function is_array(t)
    local mt = getmetatable(t)
    if mt and mt.__olua_object then
        return false
    end
    local n = 0
    for k in pairs(t) do
        n = n + 1
    end
    if #t ~= n then
        return false
    else
        for i = 1, n do
            if t[i] == nil then
                return false
            end
        end
        return true
    end
end

function olua.as_object(t)
    local mt = getmetatable(t)
    if not mt then
        mt = {}
        setmetatable(t, mt)
    end
    mt.__olua_object = true
end

---Get the comment of a field. If not found, return empty string.
---@param t any
---@param k string
---@param marshal? string
---@return string
function olua.get_comment(t, k, marshal)
    local comments = olua.get_metafield(t, "__olua_comment")
    local str = comments and comments[k] or ""
    if marshal and str ~= "" then
        str = marshal .. str
    end
    return str
end

---@class olua.json_options
---@field indent? number

---@param data any
---@param options? olua.json_options
---@return string
function olua.json_stringify(data, options)
    local json_array_stringify
    local json_object_stringify

    local indent = options and options.indent or 4

    local function json_value_stringify(value)
        local type_name = type(value)
        if type_name == "number" then
            if value == value // 1 then
                return value >> 0
            else
                return value
            end
        elseif type_name == "boolean" then
            return tostring(value)
        elseif type_name == "string" then
            return '"' .. value:gsub('"', '\\"'):gsub("\n", "\\n") .. '"'
        elseif type_name == "table" then
            local mt = getmetatable(value)
            if mt and mt.__tostring then
                return mt.__tostring(value)
            elseif mt and mt.__olua_type == "olua.array" then
                return json_array_stringify(value)
            elseif mt and mt.__olua_type == "olua.ordered_map" then
                return json_object_stringify(value._map)
            elseif is_array(value) then
                return json_array_stringify(value)
            else
                return json_object_stringify(value)
            end
        elseif value == cjson.null then
            return "null"
        else
            olua.error("unsupport type: ${type_name}")
        end
    end

    function json_object_stringify(value)
        local keys = olua.keys(value):sort(function (a, b)
            if type(a) ~= type(b) then
                return tostring(a) < tostring(b)
            else
                return a < b
            end
        end)
        local out = olua.array(",\n")
        for _, k in ipairs(keys) do
            local v = value[k]
            local v_str = json_value_stringify(v)
            local type_name = type(v)
            local k_str
            if type(k) ~= "string" then
                k_str = olua.format([["${k}"]])
            else
                k_str = string.format("%q", k)
            end
            olua.use(v_str, k_str)
            if type_name ~= "table" then
                out:pushf([[
                    ${k_str}: ${v_str}
                ]], indent)
            elseif is_array(v) then
                out:pushf([[
                    ${k_str}: [
                        ${v_str}
                    ]
                ]], indent)
            else
                out:pushf([[
                    ${k_str}: {
                        ${v_str}
                    }
                ]], indent)
            end
        end
        return out
    end

    function json_array_stringify(value)
        local out = olua.array(",\n")
        for i, v in ipairs(value) do
            local v_str = json_value_stringify(v)
            local type_name = type(v)
            olua.use(v_str)
            if type_name ~= "table" then
                out:pushf([[
                    ${v_str}
                ]], indent)
            elseif is_array(v) then
                out:pushf([[
                    [
                        ${v_str}
                    ]
                ]], indent)
            else
                out:pushf([[
                    {
                        ${v_str}
                    }
                ]], indent)
            end
        end
        return out
    end

    local olua_object = olua.get_metafield(data, "__olua_object")
    local str = json_value_stringify(data)
    if not olua_object and is_array(data) then
        str = olua.format([[
            [
                ${str}
            ]
        ]], indent)
    else
        str = olua.format([[
            {
                ${str}
            }
        ]], indent)
    end
    return str
end

---@class olua.lua_options
---@field indent? number
---@field marshal? string

---@param data any
---@param options? olua.lua_options
---@return string
function olua.lua_stringify(data, options)
    local lua_array_stringify
    local lua_object_stringify

    local indent = (options and options.indent) or 4
    local marshal = (options and options.marshal) and (options.marshal .. " ") or ""

    ---@param value any
    ---@param out array
    local function lua_annotation_type(value, out)
        local v_cls_out
        local k_type_out
        for k, v in pairs(value) do
            local olua_class = olua.get_metafield(v, "__olua_class")
            if olua_class then
                if not v_cls_out then
                    v_cls_out = olua.array(" | ")
                    k_type_out = olua.array(" | ")
                end
                v_cls_out:push(olua_class)
                if type(k) == "string" then
                    k_type_out:push("string")
                else
                    k_type_out:push("integer")
                end
            end
        end
        if v_cls_out then
            v_cls_out = v_cls_out:toset():sort()
            k_type_out = k_type_out:toset():sort()
            out:pushf([[
                ---@type { [${k_type_out}]: ${v_cls_out} }
            ]])
        end
    end

    ---@param value any
    ---@param out array
    local function lua_annotation_class(value, out)
        local annotation = olua.get_metafield(value, "__olua_annotation")
        if annotation then
            out:push(annotation)
            out:push("")
        end
    end

    local function lua_value_stringify(value)
        local type_name = type(value)
        if type_name == "number" then
            if value == value // 1 then
                return value >> 0
            else
                return value
            end
        elseif type_name == "boolean" then
            return tostring(value)
        elseif type_name == "string" then
            return '"' .. value:gsub('"', '\\"'):gsub("\n", "\\n") .. '"'
        elseif type_name == "table" then
            local mt = getmetatable(value)
            if mt and mt.__tostring then
                return mt.__tostring(value)
            elseif mt and mt.__olua_type == "olua.array" then
                return lua_array_stringify(value)
            elseif mt and mt.__olua_type == "olua.ordered_map" then
                return lua_object_stringify(value._map)
            elseif is_array(value) then
                return lua_array_stringify(value)
            else
                return lua_object_stringify(value)
            end
        elseif value == cjson.null then
            return "nil"
        else
            olua.error("unsupport type: ${type_name}")
        end
    end

    function lua_object_stringify(value)
        local keys = olua.keys(value):sort(function (a, b)
            if type(a) ~= type(b) then
                return tostring(a) < tostring(b)
            else
                return a < b
            end
        end)
        local out = olua.array("\n")
        for _, k in ipairs(keys) do
            local v = value[k]
            local type_name = type(v)
            local k_str
            if type(k) ~= "string" then
                k_str = olua.format("[${k}]")
            elseif string.find(k, "[^%w_]") then
                k_str = olua.format('["${k}"]')
            else
                k_str = olua.format("${k}")
            end
            if type_name ~= "table" then
                local olua_comment = olua.get_comment(value, k, " -- ")
                local v_str = lua_value_stringify(v)
                olua.use(k_str, v_str, olua_comment)
                out:pushf([[
                    ${k_str} = ${v_str},${olua_comment}
                ]], indent)
            elseif olua.has_metafield(v, "__olua_enum") then
                local olua_enum = olua.get_metafield(v, "__olua_enum")
                local v_out = olua.array("\n")
                for enum_name, enum_value in pairs(v) do
                    local olua_comment = olua.get_comment(v, enum_name, " -- ")
                    enum_value = lua_value_stringify(enum_value)
                    olua.use(olua_comment)
                    v_out:pushf([[
                        ${enum_name} = ${enum_value},${olua_comment}
                    ]], indent)
                end
                v_out:sort()
                olua.use(olua_enum)
                out:pushf([[
                    ---@enum ${olua_enum}
                    ${k_str} = {
                        ${v_out}
                    },
                ]], indent)
            else
                local v_str = lua_value_stringify(v)
                olua.use(v_str)
                lua_annotation_type(v, out)
                out:pushf([[
                    ${k_str} = {
                        ${v_str}
                    },
                ]], indent)
            end
        end
        return out
    end

    function lua_array_stringify(value)
        local out = olua.array("\n")
        for _, v in ipairs(value) do
            local v_str = lua_value_stringify(v)
            local type_name = type(v)
            olua.use(v_str)
            if type_name == "table" then
                out:pushf([[
                    {
                        ${v_str}
                    },
                ]], indent)
            else
                out:pushf([[
                   ${v_str},
                ]], indent)
            end
        end
        return out
    end

    local out = olua.array("\n")
    local str = lua_value_stringify(data)
    lua_annotation_class(data, out)
    lua_annotation_type(data, out)
    olua.use(str, marshal)
    out:pushf([[
        ${marshal}{
            ${str}
        }
    ]], indent)
    return tostring(out)
end

---@class olua.ts_options
---@field indent? number
---@field marshal? string

---@param data any
---@param options olua.ts_options
function olua.ts_stringify(data, options)
    local ts_array_stringify
    local ts_object_stringify

    local enums = olua.array("\n")

    local indent = (options and options.indent) or 4
    local marshal = (options and options.marshal) and (options.marshal .. " ") or ""

    local function ts_value_stringify(value)
        local type_name = type(value)
        local olua_enum = olua.get_metafield(value, "__olua_enum")
        if olua_enum then
            local out = olua.array("\n")
            local keys = olua.keys(value):sort()
            for _, enum_name in ipairs(keys) do
                local enum_value = value[enum_name]
                local olua_comment = olua.get_comment(value, enum_name)
                if olua_comment ~= "" then
                    out:pushf([[
                        /**
                         * ${olua_comment}
                         */
                    ]])
                end
                enum_value = ts_value_stringify(enum_value)
                out:pushf([[${enum_name} = ${enum_value},]], indent)
            end
            enums:pushf([[
                export enum ${olua_enum} {
                    ${out}
                }
            ]])
            enums:push("")
            return olua_enum
        elseif type_name == "number" then
            if value == value // 1 then
                return value >> 0
            else
                return value
            end
        elseif type_name == "boolean" then
            return tostring(value)
        elseif type_name == "string" then
            return '"' .. value:gsub('"', '\\"'):gsub("\n", "\\n") .. '"'
        elseif type_name == "table" then
            local mt = getmetatable(value)
            if mt and mt.__tostring then
                return mt.__tostring(value)
            elseif mt and mt.__olua_type == "olua.array" then
                return ts_array_stringify(value)
            elseif mt and mt.__olua_type == "olua.ordered_map" then
                return ts_object_stringify(value._map)
            elseif is_array(value) then
                return ts_array_stringify(value)
            else
                return ts_object_stringify(value)
            end
        elseif value == cjson.null then
            return "null"
        else
            olua.error("unsupport type: ${type_name}")
        end
    end

    function ts_object_stringify(value)
        local keys = olua.keys(value):sort(function (a, b)
            if type(a) ~= type(b) then
                return tostring(a) < tostring(b)
            else
                return a < b
            end
        end)
        local out = olua.array("\n")
        for _, k in ipairs(keys) do
            local v = value[k]
            local v_str = ts_value_stringify(v)
            local k_str = k
            local type_name = type(v)
            local olua_comment = olua.get_comment(value, k)
            if olua_comment ~= "" then
                out:pushf([[
                    /** ${olua_comment} */
                ]])
            end
            olua.use(v_str, k_str)
            if type_name ~= "table" or olua.get_metafield(v, "__olua_enum") then
                out:pushf([[
                    ${k_str}: ${v_str},
                ]], indent)
            elseif is_array(v) then
                out:pushf([[
                    ${k_str}: [
                        ${v_str}
                    ],
                ]], indent)
            else
                out:pushf([[
                    ${k_str}: {
                        ${v_str}
                    },
                ]], indent)
            end
        end
        return out
    end

    function ts_array_stringify(value)
        local out = olua.array("\n")
        for i, v in ipairs(value) do
            local v_str = ts_value_stringify(v)
            local type_name = type(v)
            olua.use(v_str)
            if type_name ~= "table" then
                out:pushf([[
                    ${v_str},
                ]], indent)
            elseif is_array(v) then
                out:pushf([[
                    [
                        ${v_str}
                    ],
                ]], indent)
            else
                out:pushf([[
                    {
                        ${v_str}
                    },
                ]], indent)
            end
        end
        return out
    end

    local out = olua.array("\n")
    local olua_object = olua.get_metafield(data, "__olua_object")
    local str = ts_value_stringify(data)
    olua.use(str, marshal)
    if #enums > 0 then
        out:push(tostring(enums))
        out:push("")
    end
    if not olua_object and is_array(data) then
        out:pushf([[
            ${marshal}[
                ${str}
            ]
        ]], indent)
    else
        out:pushf([[
            ${marshal}{
                ${str}
            }
        ]], indent)
    end
    return tostring(out)
end

return olua