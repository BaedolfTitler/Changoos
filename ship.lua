---
--- Created by baedolf.
--- DateTime: 2/25/23 5:54 AM
---
-- simple argument parser for cc programs

local str = require("stringTools")


--- KeyReg - A register for keys that a program may want to look for arguments with
--- @return table
local function keyReg()
    local keyReg = {}
    keyReg.registerKey = function(tick, name, comment)
        keyReg[tick] = {}
        keyReg[tick].name = name
        keyReg[tick].comment = comment
    end
    return keyReg
end



--- Takes all the arguments for a function and places them into their own tables
local function parseArgs(key_reg, program_args)
    local t = {}

    -- search for tickmark arguments
    for k, v in pairs(program_args) do
        -- search all arguments passed for a leading tickmark
        if string.match(string.sub(v, 1, 1), "-") == "-" then
            local s = string.sub(v, 2) -- get what the tick actually is

            -- is a single tick, place the following argument's value in the argTable
            if string.len(s) == 1 then
                local k_n, v_n = next(program_args, k)
                if k_n ~= nil then
                    local keyName = key_reg[s].name
                    t[keyName] = v_n
                end


            -- if it's a compound argument, set values of the ticks to true
            else
                for _, b in pairs(str.split(s)) do
                    local keyName = key_reg[b].name
                    t[keyName] = true
                end
            end
        end
    end
    return t
end

return {parseArgs=parseArgs, keyReg=keyReg}
