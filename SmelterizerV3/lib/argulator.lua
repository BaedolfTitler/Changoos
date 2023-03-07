---
--- Created by baedolf.
--- DateTime: 2/25/23 5:54 AM
---
-- simple argument parser for cc programs

local str = require("stringTools")


--- KeyReg - A register for keys that a program may want to look for arguments with
--- @return table swouse 
local function keyReg()
    local keyReg = {}
    keyReg.registerKey = function(tick, name, comment)
        keyReg[tick] = {}
        keyReg[tick].name = name
        keyReg[tick].comment = comment
    end
    return keyReg
end
-- >> kr = keyReg()
-- >> kr.registerKey("k", "keyName", "keyDesc")



-- Checks to see if the argument has a leading tickmark
local function hastick(str_in)
    if string.match(string.sub(str_in, 1, 1), "-") == "-" then
        return true, string.sub(str_in, 2)
    end
end



--- Takes all the arguments for a function and places them into their own tables
local function parseArgs(key_reg, program_args)
    -- Maps found tickmark values to their registered names
    local t = {}

    -- search for tickmark arguments
    for k, v in pairs(program_args) do
        -- search all arguments passed for a leading tickmark
        local has_tick, tickval = hastick(v)
        if has_tick then
            -- is a single tick, place the following argument's value in the argTable
            if string.len(tickval) == 1 then
                local k_n, v_n = next(program_args, k)
                local keyName = key_reg[tickval].name

                if hastick(v_n) == true then -- if the next argument is a tick, set current to true
                    t[keyName] = true

                elseif k_n ~= nil then
                    t[keyName] = v_n
                end


            -- if it's a compound argument, set values of the ticks to true
            else
                for _, b in pairs(str.split(tickval, nil)) do
                    local keyName = key_reg[b].name
                    t[keyName] = true
                end
            end
        end
    end
    return t
end
-- >> p = parseArgs(kr, targs)
-- >> p -> {... name = value }


return {parseArgs=parseArgs, keyReg=keyReg}