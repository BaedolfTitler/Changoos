---
--- Created by baedolf.
--- DateTime: 3/4/23 2:47 AM
---

--- Rewrite of the SmelterStack Object

local str = require("lib/stringTools")
local log = require("lib/loggerizer")
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
            if not isCrafting then smelterStack.interfaces[1].pushItems(smelterStack.invName, 2) end
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
    s.smelteryName = nil
    s.inventory = nil
    s.invName = nil

    s.firstMinimum = 1 -- minimum amount  of fluid required to complete smelt for the first item
    s.secondMinimum = 1 -- minimum amount for the second item
    s.firstCooltime = 0.1 -- the time it takes for the first item to complete
    s.secondCooltime = 0.1 -- The time it takes for the second item to complete

    s.ItemCrafting = false -- The smeltery is using item crafting

    -- amounts of fluid or items the smelter currently has left to work with
    s.workingFirst = {name = nil, amount = false}
    s.workingSecond = {name = nil, amount = false}

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
        local cast
        if str.softMatch(interfaceName, "cast") then cast = true else cast = false end -- find out if it's a cast
        log.info("Searching for "..interfaceName.."s...")

        for _, i in ipairs(s.interfaces) do
            local i_name = peripheral.getName(i)
            local toinsert = false
            -- filter tables and basins
            if str.softMatch(i_name, "table") or str.softMatch(i_name, "basin") then -- oh yeah, it's if spam time
                toinsert = true
                if cast then
                    toinsert = false
                    local tbcast = i.getItemDetail(1)
                    if tbcast == nil then tbcast = {name = ""} end
                    if str.softMatch(tbcast.name, interfaceName) then
                        if i.getItemDetail(2) then
                            log.info("Emptying cast: "..i_name)
                            i.pushItems(s.invName, 2)
                        end
                        toinsert = true
                    end
                else
                    -- try to pull items out of the interfaces if they're stuck in there
                    local tHasItem
                    if i.getItemDetail(1) then tHasItem = 1 end
                    if i.getItemDetail(2) then tHasItem = 2 end
                    if tHasItem then
                        log.info("Emptying table: "..i_name.."["..tostring(tHasItem).."]")
                        i.pushItems(s.invName, tHasItem)
                    end
                end
            end
            if toinsert then table.insert(filtered_interfaces, i) end
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
            _, _, s.workingFirst.amount = inv.findFluid(s.smeltery.tanks(), recipe.first)
        end

        if recipe.second ~= nil then
            s.workingSecond.name = recipe.second
            _, _, s.workingSecond.amount = inv.findFluid(s.smeltery.tanks(), recipe.second)
        end
    end

    s.setInventory = function(inventory)
        -- Sets the stack's inventory to a wrapped inventory peripheral
        s.inventory = inventory
        s.invName = peripheral.getName(s.inventory)
    end

    s.setSmeltery = function(smeltery)
        -- Sets the stack's smeltery to a wrapped drain peripheral
        s.smeltery = smeltery
        s.smelteryName = peripheral.getName(s.smeltery)
    end
    
    s.canCraftFromInventory = function(recipe)
        -- checks to see if the requested first item is placed in the inventory
        -- assumes first ingredient is a fluid if nothing's found
        local itemName, itemSlot, itemCount = inv.findItem(s.inventory, recipe.first)
        if recipe.second ~= nil and itemName then s.ItemCrafting = true end
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

        -- Item crafting
        if recipe.second ~= nil and s.ItemCrafting then
            s.interfaces[1].pullItems(s.invName, itemSlot, 1, 1)
            s.secondMinimum = s.interfaces[1].pullFluid(s.smelteryName, 99999, recipe.second)

            -- Wait for item to complete and set time it took to finish
            s.secondCooltime = timeSmelt(s, false)
            recipe.amount = recipe.amount - 1



        -- Fluid crafting
        else
            -- simple smelting
            s.firstMinimum = s.interfaces[1].pullFluid(s.smelteryName, 99999, recipe.first)

            -- move on to the second item if it exists, else just get the first coolTime
            if recipe.second ~= nil and recipe.second ~= false then
                s.firstCoolTime = timeSmelt(s, true)
                s.secondMinimum = s.interfaces[1].pullFluid(s.smelteryName, 99999, recipe.second)
                s.secondCooltime = timeSmelt(s, false)
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


    s.craftAmount = function(recipe, amount, loop)
        s.calibrate(recipe)
        L = true
        while L
            -- craft `amount` items, if -1, craft until the program closes
            while amount ~= 0 do
                s.calculateAmounts(recipe)
                -- Wait a little bit if some certain ingredient levels are low
                if s.workingFirst.amount < s.firstMinimum then 
                    log.tell_amount("Need Ingredient 1:", s.firstMinimum - s.workingFirst)
                    os.sleep(5)
                end
                if s.workingSecond.amount < s.secondMinimum then 
                    log.tell_amount("Need Ingredient 1:", s.secondMinimum - s.workingSecond)
                    os.sleep(5)
                end


                local pullItems = false

                -- First round of items/fluids
                for _, i in ipairs(s.interfaces) do
                    -- Put items in tables, or cast first fluid
                    if s.workingFirst.amount >= s.firstMinimum then
                        local m_amount

                        if s.ItemCrafting then
                            local itemName, itemSlot, itemCount = inv.findItem(s.inventory, recipe.first)
                            m_amount = i.pullItems(s.invName, itemSlot, 1, 1)
                            if m_amount == 0 then break else
                            s.workingFirst.amount = s.workingFirst.amount - m_amount end

                        else
                            m_amount = i.pullFluid(s.smelteryName, s.firstMinimum, recipe.first)
                            if m_amount == 0 then break else
                            s.workingFirst.amount = s.workingFirst.amount - m_amount end

                            -- pull items if this is the only item to be crafted
                            if recipe.second == nil or recipe.second == false then
                                pullItems = true
                            end
                        end
                    end
                end

                -- Wait for the items to cool
                os.sleep(s.firstCoolTime)

                -- Pull items if needed
                if pullItems then
                    for _, i in ipairs(s.interfaces) do
                        local m_items = i.pushItems(s.invName, 2)
                        amount = amount - m_items
                    end
                    break
                end


                -- continue to second item
                for _, i in ipairs(s.interfaces) do
                    if s.workingSecond.amount >= s.secondMinimum then
                        local m_amount = i.pullFluid(s.smelteryName, s.secondMinimum, recipe.second)
                        if m_amount == 0 then break else
                        s.workingSecond.amount = s.workingSecond.amount - m_amount end
                        end
                    end
                end
                
                -- Wait for items to cool
                os.sleep(s.secondCooltime)


                -- pull all items
                for _, i in ipairs(s.interfaces) do
                    local m_items = i.pushItems(s.invName, 2)
                    amount = amount - m_items
                end

                
            if loop then
                os.sleep(3)
                log.happy("looping...")
                L = true
            end
        end
    end

    s.dumpAttributes = function()
        log.tell_amount("First item cast time:", tostring(s.firstCoolTime).."s")
        log.tell_amount("Second item cast time:", tostring(s.secondCooltime).."s")

        log.tell_amount("Amount of Ingredient 1", tostring(s.workingFirst.amount))
        log.tell_amount("Amount of Ingredient 2", tostring(s.workingSecond.amount))
    end

    return s
end


return {smelterStack=smelterStack}
