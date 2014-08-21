-- Set-up global Input objects.
local InputMan = require('libs/inputman')
love.inputman = InputMan()

-- Screw the literally zillions of input callbacks, we're going to use two
-- custom events instead.
--
function love.inputpressed(state)
    love.debug.printIf('input', 'pressed:', state)

    -- An example of input/sound
    if(state == 'select') then love.soundman:run('select') end
end

function love.inputreleased(state)
    love.debug.printIf('input', 'released:', state)

end

-- Maybe we want to use keypressed as well for a few global
--
function love.keypressed(key)
    if(key == 'f10') then
        love.event.quit()
    elseif(key == 'f11') then
        love.viewport:setFullscreen()
        love.viewport:setupScreen()
    elseif(key == 'f12') then
        love.inputman:threadStatus()
        love.soundman:threadStatus()
    end
end

function love.joystickadded(j)
    love.inputman:updateJoysticks()
end

function love.joystickremoved(j)
    love.inputman:updateJoysticks()
end
