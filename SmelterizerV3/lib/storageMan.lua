---
--- Created by baedolf.
--- DateTime: 3/4/23 6:24 AM
---

--- Contains useful functions for simple storage management

local str = require("lib/stringTools")

-- Soft searches for a peripheral of the soft form `if_name` and returns its wrapped peripheral
local function softFindPeripheral(pf_name)
    local names = peripheral.getNames()
    for k, nm in ipairs(names) do
        if str.softMatch(nm, pf_name) then
            return peripheral.wrap(nm)
        end
    end
    return false
end


local function findItem(inventoryP, itemName)
    -- Returns the full item name, the slot number, and count an item is in
    for slot_number, item in pairs(inventoryP.list()) do
        if str.softMatch(item.name, itemName) then
            return item.name, slot_number, item.count
        end
    end
    return false
end

-- finds the total amount of a given item in an inventory
local function totalCount(inventoryP, itemName)
    local total = 0
    for slot_number, item in pairs(inventoryP.list()) do
        if str.softMatch(item.name, itemName) then
            total = total + item.count
        end
    end
    return total
end


--- Finds fluids in a fluid tank, intended for smeltery drains
--- @param tankSet table The tank table from a fluid container
--- @param fluidName string The name of the fluid to search for. Soft matches results, returning the first found
local function findFluid(tankSet, fluidName)
    if fluidName == nil or fluidName == false then return false end
    for tank_number, fluid in ipairs(tankSet) do
        if str.softMatch(fluid.name, fluidName) then
            return fluid.name, tank_number, fluid.amount
        end
    end
    return false
end

return {findItem = findItem, findFluid = findFluid, softFindPeripheral = softFindPeripheral, totalCount = totalCount}