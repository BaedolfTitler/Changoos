---
--- Created by baedolf.
--- DateTime: 3/4/23 4:34 AM
---

--- Recipe object for managing craft jobs

local inv = require("lib/storageMan")
local str = require("lib/stringTools")
local log = require("lib/loggerizer")

--- Recipe queue thing to manage order of items to be smelted into and things and stuff
--- At the moment each instance of the "queue" may hold only one recipe, lol
local function recipeQueue()
    local rq = {}

    rq.queue = {}

    rq.addRecipe = function(first, second, amount)
        -- Adds a recipe for the smelterStack object to process
        local recipe = {}
        recipe.first = first
        recipe.second = second
        recipe.amount = amount
        table.insert(rq.queue, recipe)
    end

    rq.getUserRequest = function(amount)
        -- Requests should be in the form "<first item/fluid>, <second fluid>, more verbose names are recommended
        -- Will craft all by default
        local input = io.read()
        input = str.map(str.strip, str.split(input, ", "), {})
        assert(#input > 1, "Less than two parameters specified, ensure ingredientes are separated by commas")
        if str.inTable({"nil", "none", "null", "nothing", "%-", "%."}, input[2]) then input[2] = false end  -- may cause issues with addRecipe
        rq.addRecipe(input[1], input[2], amount)
    end

    rq.resolveRecipe = function(smelterStack, recipe)
        -- Uses a smelterStack to resolve recipes in the queue to their actual names
        -- Returns the recipe where each item has its full name 
        local resRecipe = {}
            -- Check inventory first for crafting items...
            local t = false -- switch total avoid spamming the user
            local foundItemFirst
            if smelterStack.ItemCrafting then
                repeat
                    local fitem, itemSlot = inv.findItem(smelterStack.inventory, recipe.first)
                    foundItemFirst = fitem -- rough way of moving the bundled return of the findItem function out of this scope
                    if fitem == false and t == false then t = true log.anger("Could not find item: ["..recipe.first.."] in registered inventory.\nWaiting for item...") end
                    if fitem then log.happy("Found "..fitem.." in slot "..itemSlot) end
                    if t == true then os.sleep(1) end
                until fitem ~= false
                resRecipe.first = foundItemFirst

            else -- Find a fluid of the type
                local ffluid = inv.findFluid(smelterStack.smeltery.tanks(), recipe.first)
                if ffluid == false then log.anger("Could not find fluid: "..recipe.first) end
                resRecipe.first = ffluid
            end
            

            -- Find second fluid
            local ffluid = inv.findFluid(smelterStack.smeltery.tanks(), recipe.second)
            resRecipe.second = ffluid

            resRecipe.amount = recipe.amount
        return resRecipe
    end

    return rq
end

return {recipeQueue = recipeQueue}