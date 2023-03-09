---
--- Created by baedolf.
--- DateTime: 2/25/23 5:58 AM
---



--- map - Applies a function to each element in a table.
---@param func function - The function to apply
---@param tb table - The table to apply to
---@param args table - The additional arguments for the function call
---@return table - Table of elements from the function
local function map(func, tb, args)
    local t = {}
    for k, v in ipairs(tb) do
        t[k] = func(v, table.unpack(args))
    end
    return t
end

-- strips characters off both ends of a string



-- Strips `char` from the beginning of a string, whitespace by default
local function lstrip(str, char)
    if char == nil then char = "%s" end
    return string.gsub(str, "^"..char.."*", "")
end

-- Strips `char` from the end of a string, whitespace by default
local function rstrip(str, char)
    if char == nil then char = "%s" end
    return string.reverse(string.gsub(string.reverse(str), "^c"..char.."*", ""))
end

-- Strips `char` from both ends of a string, whitespace by default
local function strip(str, char)
    local str = lstrip(str, char)
    return rstrip(str, char)
end

-- good lord this thing isnt sanitized LOL
local function split(str, sep)
    local t={}
    if sep == nil then sep = "" end
    local sepstring = "([^"..sep.."]+)"
    if sep == nil or #sep == 0 then
        for i=1,string.len(str) do
            table.insert(t, string.sub(str, i, i))
        end
    elseif #str > 0 then
        for stn in string.gmatch(str, sepstring) do
            table.insert(t, stn)
        end
    end
    return t
end


local function getUserInput(prompt)
    if prompt ~= nil or false then
        print(prompt)
    else return io.read()
    end
end



--- Returns the original string if a match is found, case insensitive
local function softMatch(str, pattern)
    str = string.lower(str)
    pattern = string.lower(pattern)
    if string.match(str, pattern) then
        return str
    end
end

--- Checks to see if a string(or substring) is in a table
local function inTable(tb, str)
    local m = map(softMatch, tb, {str})
    if #m ~= 0 then
        return m -- returns the table of elements that matched
    else return false
    end
end

return {split=split, inTable=inTable, map = map, softMatch = softMatch, rstrip=rstrip, lstrip=lstrip, strip=strip}