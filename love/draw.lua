-- Game resolution settings
game.gameWidth = 256
game.gameHeight = 224

-- Graphics Default Settings
love.graphics.setDefaultFilter('nearest', 'nearest', 0)

-- Viewport Setup
love.viewport = require('vendor/push')
love.viewport:setupScreen(game.gameWidth, game.gameHeight,
                          conf.window.width, conf.window.height,
                          {resizable = true, pixelperfect = true})

-- Draw callback
function love.draw()
    love.viewport:start()
    -- Draw here
    love.viewport:finish()
end
