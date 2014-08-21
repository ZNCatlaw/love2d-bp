local Viewport = require('libs/viewport')
love.viewport = Viewport()

function love.draw()
    love.viewport:pushScale()

    -- Draw here

    love.viewport:popScale()
end
