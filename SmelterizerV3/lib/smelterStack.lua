---
--- Created by baedolf.
--- DateTime: 3/4/23 2:47 AM
---

--- Rewrite of the SmelterStack Object

local str = require("stringTools")
local log = require("loggerizer")
local inv = require("lib/storageMan")


-- Common uses
-- >> Smelt `n = 40` blocks of `fluid = molten_iron`
--
-- blockCasts = smelterStack().filterInterfaces("basin")
-- blockCasts.setInventory(inventory)

-- recipe = craftingQueue.addRecipe(first = molten_iron, second = nil, amount = n)
-- blockCasts.calibrate(recipe)


-- blockCasts.smelt(recipe = recipe)
--
-- >> advSmelt -b 40 -f <iron>


-- Times the smelting operation, will not pull the item if isCrafting is true
local function timeSmelt(smelterStack, isCrafting)
    local t1 = os.time()
    local coolTime
    while true do
        if smelterStack.interfaces[1].getItemDetail(2) ~= nil then
            local t2 = os.time()
            if not isCrafting then smelterStack.interfaces[1].pushItems(peripheral.getName(smelterStack.inventory), 2) end
            coolTime = ((t2-t1)*1/(1/50))*1.05
            break
        else
            os.sleep(0.1)
        end
    end
    return coolTime
end


--- Creates a new smelterStack object, wrapped interfaces should be provided
local function smelterStack(interfaces)
    local s = {}
    if #interfaces ~= 0 then s.interfaces = interfaces else log.anger("No interfaces found for Smelter Stack...") end

    --- vvvvvvvvvv
    --- Machine Attributes / Parameters
    --- ^^^^^^^^^^
    s.vizChar = "-"
    s.vizColor = "0"

    s.smeltery = nil
    s.inventory = nil

    s.firstMinimum = 1 -- minimum amount  of fluid required to complete smelt for the first item
    s.secondMinimum = 1 -- minimum amount for the second item
    s.firstCooltime = 0.1 -- the time it takes for the first item to complete
    s.secondCooltime = 0.1 -- The time it takes for the second item to complete

    s.ItemCrafting = false -- The smeltery is using item crafting

    -- amounts of fluid or items the smelter currently has left to work with
    s.workingFirst = {name = nil, amount = 0}
    s.workingSecond = {name = nil, amount = 0}


    --- vvvvvvvvvv
    --- Machine Management
    --- ^^^^^^^^^^

    --- Sets the SmelterStack's interfaces to be only of the type requested
    --- @param interfaceName string Takes the names `basin`, `table` `*_cast` where `*_cast` represents a casting table that holds a cast of that type, like `ingot_cast` or `gem_cast`
    s.filterInterfaces = function(interfaceName)
        -- takes names: "basin", "table", "*_cast"
        -- Returns matching interfaces

        -- find out if we're requesting a cast
        local filtered_interfaces = {}
        log.info("Searching for "..interfaceName.."s")
        if str.softMatch(interfaceName, "cast") then
            for _, i in ipairs(s.interfaces) do
                if str.softMatch(i.getItemDetail(1).name, interfaceName) == interfaceName then
                    table.insert(filtered_interfaces, i)
                end
            end

        -- else filter tables or basins
        else
            for _, i in ipairs(s.interfaces) do
                local is_type = str.softMatch(peripheral.getName(i), interfaceName) == interfaceName
                local is_empty = i.getItemDetail(1) == nil
                if is_type and is_empty then
                    table.insert(filtered_interfaces, i)
                end
            end
        end
        if #filtered_interfaces == 0 then
            log.anger("Could not find any interfaces of type: "..interfaceName)
            s.interfaces = {}
        else
            s.interfaces = filtered_interfaces
        end


    end

    -- Finds the amount of fluids/items currently available to the SmelterStack
    s.calculateAmounts = function(recipe)
        -- Takes a resolved recipe item
        
        s.workingFirst.name = recipe.first
        if s.ItemCrafting then
            s.workingFirst.amount = inv.totalCount(s.inventory, recipe.first)
        else
            _, _, s.workingFirst.amount = inv.findFluid(s.smeltery, recipe.first)
        end

        s.workingSecond.name = recipe.second
        _, _, s.workingSecond.amount = inv.findFluid(s.smeltery, recipe.second)
        
    end

    s.setInventory = function(inventory)
        -- Sets the stack's inventory to a wrapped inventory peripheral
        s.inventory = inventory
    end

    s.setSmeltery = function(smeltery)
        -- Sets the stack's smeltery to a wrapped drain peripheral
        s.smeltery = smeltery
    end

    s.calibrate = function(recipe)
        -- Finds the minimum amount of fluid to place in a casting table to complete a smelt
        -- ensures an inventory is connected to the computer
        -- Also finds the amount of time it needs to wait for a completed smelt
        -- Takes in an element from a `recipe` object, taken from the field `queue` {first, second, amount}

        assert(s.inventory, "Could not find inventory for smelterStack. Please attach/assign a valid inventory")
        assert(s.smeltery,  "Could not find smeltery for smelterStack. Please attach/assign a valid smeltery (drain/tank)")


        -- search for the specified item in the connected inventory
        local itemName, itemSlot, itemCount = inv.findItem(s.inventory, recipe.first)
        if itemName then s.ItemCrafting = true end

        -- Item crafting
        if s.ItemCrafting then
            s.interfaces[1].pullItems(peripheral.getName(s.inventory, itemSlot, 1, 1))
            s.secondMinimum = s.interfaces[1].pullFluid(peripheral.getName(s.smeltery), 99999, recipe.second)

            -- Wait for item to complete and set time it took to finish
            s.secondCooltime = timeSmelt(s, false)
            recipe.amount = recipe.amount - 1



        -- Fluid crafting
        else
            -- simple smelting
            s.firstMinimum = s.interfaces[1].pullFluid(peripheral.getName(s.smeltery), 99999, recipe.first)

            -- move on to the second item if it exists, else just get the first coolTime
            if recipe.second ~= nil then
                s.firstCoolTime = timeSmelt(s, true)
                s.secondMinimum = s.interfaces[1].pullFluid(peripheral.getName(s.smeltery), 99999, recipe.second)
                s.secondCooltime = timeSmelt(s, true)
                recipe.amount = recipe.amount - 1

            else
                s.firstCoolTime = timeSmelt(s, false)
                recipe.amount = recipe.amount - 1
            end
        end
        s.calculateAmounts(recipe) -- register total resources to the SmelterStack
    end

    ---
    --- Machine Functionality
    ---

    s.dumpAttributes = function()
        log.tell_amount("First item cast time:", s.firstCoolTime.."s")
        log.tell_amount("Second item cast time:", s.secondCooltime.."s")

        log.tell_amount("Amount of Ingredient 1", s.workingFirst.amount)
        log.tell_amount("Amount of Ingredient 2", s.workingSecond.amount)
    end

    return s
end


return {smelterStack=smelterStack}