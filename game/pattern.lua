game.objects.EGA_PALETTE = {
    { 0,   0,   0   }, -- black
    { 0,   0,   170 }, -- blue
    { 0,   170, 0   }, -- green
    { 0,   170, 170 }, -- cyan
    { 170,   0, 0   }, -- red
    { 170,   0, 170 }, -- magenta
    { 170,  85, 0   }, -- brown
    { 170, 170, 170 }, -- white / light grey
    {  85,  85,  85 }, -- dark grey / bright black
    {  85,  85, 255 }, -- bright blue
    {  85, 255,  85 }, -- bright green
    {  85, 255, 255 }, -- bright cyan
    { 255,  85,  85 }, -- bright red
    { 255,  85, 255 }, -- bright magenta
    { 255, 255,  85 }, -- bright yellow
    { 255, 255, 255 }  -- bright white
}

game.objects.pattern = {}

function regenerate_pattern()
    local grid = {}
    local palette = game.objects.EGA_PALETTE
    for x = 1, game.gameWidth do
        for y = 1, game.gameHeight do
            grid[x] = grid[x] or {}
            grid[x][y] = palette[love.math.random(1, 16)]
        end
    end
    game.objects.pattern = grid
end

hump.Timer.every(1, regenerate_pattern)
