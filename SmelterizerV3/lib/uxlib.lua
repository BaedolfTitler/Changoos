---
--- Created by baedolf.
--- DateTime: 3/4/23 8:01 AM
---

local function waitUntil(cond, value, interval)
    -- Wait until a condition is met, testing it occasionally
    -- The condition is ultimately just a function that gets evaluated every `interval` seconds

    while cond() ~= value do
        os.sleep(interval)
    end
end

return {waitUntil = waitUntil}