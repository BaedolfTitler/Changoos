
TARGS = { ... }

local recipeQueue = require("lib/recipeQueue")
local smelterStack = require("lib/smelterStack")
local argulator = require("lib/argulator")
local inv = require("lib/storageMan")
local log = require("lib/loggerizer")

local argKeys = argulator.keyReg()
argKeys.registerKey("b", "Blocks", "Numeric, Smelts n blocks of all items")
argKeys.registerKey("i", "Ingots", "Numeric, Smelt n Ingots from the smeltery, following number optional")
argKeys.registerKey("n", "Nuggets", "Numeric, Smelt n Nuggets, following number optional")
argKeys.registerKey("f", "Fluid", "Smelts specified fluids ")
argKeys.registerKey("h", "Help", "Prints this help dialogue")
argKeys.registerKey("R", "Redstone", "Numeric, Redstone mode, will loop the specified functionality until either the specified threshold is reached, or until the signal is turned off")
argKeys.registerKey("F", "FluidCrafting", "Numeric, Crafts n items using only fluids, will prompt for specification")
argKeys.registerKey("c", "CraftMode", "Numeric, Will craft n items in an order using a process specified")
argKeys.registerKey("X", "IntPurge", "Purges all fluids and items from the interfaces and returns them to the smeltery")
argKeys.registerKey("q", "Quiet", "Will not print most messages")
local pargs = argulator.parseArgs(argKeys, TARGS)

-- Important values
INVENTORY = inv.softFindPeripheral("chest")
SMELTERY = inv.softFindPeripheral("drain")




-- ItemCrafting Functionality
function CraftItems(amount)
    -- implicit all
    if type(amount) ~= "number" or amount == 0 then
        amount = -1
    end

    local ss = smelterStack.smelterStack(INTERFACES)
    local rq = recipeQueue.recipeQueue()

    -- prompt for the recipe process
    log.happy("Please specify the recipe to be crafted, separated by commas. e.g. `obsidian, molten_iron`")
    rq.getUserRequest(amount)
    
    
    -- Get table type from user
    log.happy("Please specify an interface type to craft in (table, basin, *_cast)")
    local tt = string.lower(io.read())
    
    
    ss.setSmeltery(SMELTERY)
    ss.setInventory(INVENTORY)
    ss.filterInterfaces(tt)
    local resRecipe = rq.resolveItems(ss, rq.queue[1]) -- assume the queue only has the first recipe installed

    ss.calibrate(resRecipe)

    -- craftingLoop
    ss.dumpAttributes()


end


--- Program Initialization
function FindInterfaces()

    -- Returns all interfaces in wrapped form
    local ints = {}
    for _, v in ipairs(peripheral.getNames()) do
        table.insert(ints, peripheral.wrap(v))
    end
    return ints
end

INTERFACES = FindInterfaces()




-- run
RUNNING = true
while RUNNING do
    if pargs.IntPurge then
        print("IntPurge")
    end



    if pargs.CraftMode then
        CraftItems(pargs.CraftMode)
    end




    RUNNING = false
end