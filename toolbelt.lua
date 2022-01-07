
-- A collection of utility functions for making lua less difficult
_mines.tools = {}
local tools = _mines.tools

-- Centralize logging
tools.log = function (input)
    minetest.log("action", "[mines] "..tostring(input))
end

-- Centralize errors
tools.error = function (input)
    error("[mines] "..tostring(input))
end

-- Returns a table of the string split by the given seperation string
tools.split = function (inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

-- Returns true or false if search string is in inputstring
tools.contains = function(inputstr, search)
    if string.match(inputstr, search) then
        return true
    end
    return false
end

-- Returns space seperated position
tools.pos2str = function (pos)
    return "" .. tostring(math.floor(pos.x)) .. " " .. tostring(math.floor(pos.y)) .. " " .. tostring(math.floor(pos.z))
end

-- Returns a xyz vector from space seperated position
tools.str2pos = function (str)
    local pos = tools.split(str, " ")
    return vector.new(tonumber(pos[1]), tonumber(pos[2]), tonumber(pos[3]))
end

-- Returns 0, 90, 180, 270 based on direction given (assumes degree)
tools.to4dir = function (dir)
    local dir4 = math.floor(dir) / 90
    tools.log(tostring(dir4))
    if dir4 > 3.5 or dir4 < 0.5 then
        return 180
    elseif dir4 > 2.5 and dir4 < 3.5 then
        return 270
    elseif dir4 > 1.5 and dir4 < 2.5 then
        return 0
    elseif dir4 > 0.5 and dir4 < 3.5 then
        return 90
    end
    tools.log("to4dir(" .. tostring(dir) .. ") failed with " .. tostring(dir4))
    return -1
end

-- Given radians returns degrees
tools.rad2deg = function (rads)
    return (rads * 180) / 3.14159
end

-- Given degrees returns radians
tools.deg2rad = function (deg)
    return (deg * 3.14159) / 180
end

-- Converts the given string so the first letter is uppercase (Returns the converted string)
tools.firstToUpper = function (str)
    return (str:gsub("^%l", string.upper))
end

-- https://stackoverflow.com/questions/2282444/how-to-check-if-a-table-contains-an-element-in-lua
-- Checks if a value is in the given table (True if the value exists, False otherwise)
tools.tableContainsValue = function (table, element)
    for key, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

tools.tableContainsKey = function (table, element)
    for key, value in pairs(table) do
        if key == element then
            return true
        end
    end
    return false
end

-- Given a table returns it's keys (Returns a table)
tools.tableKeys = function (t)
    local keys = {}
    for k, v in pairs(t) do
        table.insert(v)
    end
    return keys
end

-- Returns whole percentage given current and max values
tools.getPercent = function (current, max)
    if max == nil then
        max = 100
    end
    return math.floor( (current / max) * 100 )
end

-- Returns whole number assuming given is a percent (limit's it to within a percent 0-100)
tools.makePercent = function (value)
    if value < 0 then
        value = 0
    end
    if value > 100 then
        value = 100
    end
    return math.floor(value)
end

-- Attempts to calculate all the percentages then return the whole
tools.addPercent = function (values_table)
    local val = 0
    for k, v in pairs(values_table) do
        local v1 = tools.split(v, "=")
        val = val + tools.makePercent(tonumber(v1[#v1]))
    end
    return val
end
