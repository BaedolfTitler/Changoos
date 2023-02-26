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


local function split(str, sep)
    local t={}
    if sep == nil then
        for i=1,string.len(str) do
            table.insert(t, string.sub(str, i, i))
        end
    else
        for stn in string.gmatch(str, "([^"..sep.."]+)") do
            table.insert(t, stn)
        end
    end
    return t
end


--- Returns the original string if a match is found
local function softMatch(str, pattern)
    if string.match(str, pattern) then
        return str
    end
end

--- Checks to see if a string(or substring) is in a table
local function inTable(tb, str)
    local m = map(softMatch, tb, {str})
    if m ~= nil then
        return m -- returns the table of elements that matched
    else return nil
    end
end

return {split=split, inTable=inTable}
