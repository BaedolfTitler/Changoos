---
--- Created by baedolf.
--- DateTime: 2/9/23 11:04 PM
---

targs = { ... }



function TryMineMove(direction, variable)
    -- Description: Tries to mine and make the bot move in a direction one time until it is successful
    -- direction = F(front), U(up), D(down)
    -- variable = The passed in variable that contains the move command


    if direction == 'F' then -- execute when going forward
        while variable ~= true do
            turtle.dig()
            variable = turtle.forward()
        end
    elseif direction == 'U' then -- execute when going up
        while variable ~= true do
            turtle.digUp()
            variable = turtle.up()
        end
    elseif direction == 'D' then -- execute when going down
        while variable ~= true do
            turtle.digDown()
            variable = turtle.down()
        end
    else do
        print('Cant Find Direction...?')
        return false
        end
    end
    return true
end


function MineRoom(length, width, height)
    -- Description: Mines out a room of the desired dimensions from the bottom-right most block of said room
    -- length = Length of the room
    -- width = Width of the room
    -- height = Height of the room

    local lMined = 0
    local wMined = 0
    local hMined = 0
    flipSwitch = false -- A switch to let the robot determine which direction to turn in the zig-zag
    function lengthMine()
        -- Description: Bot mines the length of the room in a long strip

        while lMined < length do
            l = turtle.forward()
            TryMineMove('F', l)
            lMined = lMined+1
        end
    end

    function widthMine()
        -- Description: Bot sets itself up for another lengthMine
        lengthMine()
        while wMined < width do
            if flipSwitch == false then do
                turtle.turnRight()
                w = turtle.forward()
                TryMineMove('F', w)
                turtle.turnRight()
                flipSwitch = true
            end
            else do
                turtle.turnLeft()
                w = turtle.forward()
                TryMineMove('F', w)
                turtle.turnLeft()
                flipSwitch = false
                end
            end
            lMined = 1 -- reset LengthCount
            lengthMine()
            wMined = wMined+1
        end
    end

    function heightMine()
        -- Description: Bot changes its height and continues mining

        while hMined < height do
            if hMined == 0 then do -- Skip the MoveUp segment for the first loop. Prevents bot from turning around on startup
                hMined = hMined
                end
            else do
                h = turtle.up()
                TryMineMove('U', h)
                turtle.turnLeft()
                turtle.turnLeft()
                end
            end

            wMined = 1 -- reset WidthCount
            lMined = 1 -- reset LengthCount cause it's occupied

            widthMine()
            hMined = hMined+1
        end
    end

    heightMine()

end


MineRoom(64, 3, 3)


turtle.turnLeft()
for i=1, 3 do
    local l = turtle.forward()
    TryMineMove("F", l)
end

for i=1, 2 do
    local d = turtle.down()
    TryMineMove("D", d)
end
turtle.turnRight()

MineRoom(5, 5, 4)
