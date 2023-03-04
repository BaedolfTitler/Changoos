---
--- Created by baedolf.
--- DateTime: 2/25/23 4:47 AM
---


-- Uses the monitor's blitting function to make cool log things
--- Prints a message to the user
local function message(msg, text_color, bg_color, ending)
    term.blit(msg, string.rep(text_color, #msg), string.rep(bg_color, #msg))
    if ending ~= nil then
        term.write(ending)
    else
        term.write("\n")
    end
end


local function anger(msg) -- prints in a dark red color
    local color = "e"
    message(msg, color, "f", nil)
end

local function happy(msg) -- prints in a green color
    if _G.q ~= true then
        local color = "d"
        message(msg, color, "f", nil)
    end
end


local function tell_amount(msg, number) -- prints in a blue color
    if _G.q ~= true then
        local text_color = "b"
        local  number_color = "a"
        number = string.rep(number, 1) -- convert number to string using dumb string method

        term.blit(msg.." [", string.rep(text_color, #msg), string.rep("f", #msg))
        term.blit(number, string.rep(number_color, #number), string.rep("f", #number))
        term.blit("]\n", string.rep(text_color, 2), string.rep("f", 2))
    end
end

local function info(msg) -- prints in a dull grey color, with special values
    if _G.q ~= true then
        local color = "8"
        message(msg, color, "f", nil)
    end
end

return {message = message, anger = anger, happy = happy, tell_amount = tell_amount, info = info}
