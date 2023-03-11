--- Compound tank object that can be used and indexed like a normal smeltery drain



local str = require("lib/stringTools")
local inv = require("lib/storangeMan")



--- @todo make this thing?
local function compoundTank()
    local ct = {}
    

    -- the compound tank is intended to be used in the exact same way that a normal drain peripheral can be used

    ct.tanks = {}
    ct.registerTanks = function(tankNames)
    end


    return ct
end

return {compoundTank=compoundTank}