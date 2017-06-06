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

    -- Demo: Draw the pattern object if it exists (see game/pattern.lua)
    local grid = game.objects.pattern
    if (grid) then
      for x = 1, #grid do
         for y = 1, #grid[x] do
             love.graphics.setColor(grid[x][y])
             love.graphics.rectangle('fill', x - 1, y - 1, 1, 1)
         end
      end
    end

    love.viewport:finish()
end
