love.viewport = require('libs/viewport').newSingleton()

function love.draw()
    love.viewport.pushScale()

    -- Draw here

    love.viewport.popScale()
end
