--
-- FIXME: This isn't working very well right now so I've replaced it with Push
--

local Viewport = Class.new('Viewport')

local roundDownToNearest = function(val, multiple)
    return multiple * (math.floor(val/multiple))
end

--
-- Instantiate a viewport with Viewport(options)
--
function Viewport:initialize(opts)
    opts = Class.defaults({
        width  = 720,
        height = 405,
        scale  = 1,
        multiple = 1,
        filter = {'nearest', 'nearest', 0},
        fs     = false
    }, opts)

    self:setWidth(opts.width)
    self:setHeight(opts.height)
    self:setScaleMultiple(opts.multiple)
    self:setScale(opts.scale)
    self:setFilter(opts.filter)
    self:setFullscreen(opts.fs)
    self:setupScreen()
end

function Viewport:setupScreen()
    self:setScale(self.scale)
    love.graphics.setDefaultFilter(unpack(self:getFilter()))
    love.debug.print(self:getParams())
    if(self:setFullscreen(self.fs)) then
        love.window.setMode(self.width * self.r_scale,
                            self.height * self.r_scale,
                            {highdpi=true, fullscreen = true, fullscreentype = "desktop"})
    else
        love.window.setMode(self.width * self.r_scale,
                            self.height * self.r_scale,
                            {highdpi = true, resizable = true})
    end
    self.r_width  = love.window.toPixels(self.width) * self.r_scale
    self.r_height = love.window.toPixels(self.height) * self.r_scale
    self.draw_ox  = (love.graphics.getWidth() - (self.r_width)) / 2
    self.draw_oy  = (love.graphics.getHeight() - (self.r_height)) / 2
end

function Viewport:setScale(scale)
    local max_scale = self:maxScale()
    local scale = roundDownToNearest(scale, self.multiple)
    self.scale = math.max(1, scale)

    if (self.fs or (scale or 0) <= 0 or (scale or 0) > max_scale) then
        self.r_scale = max_scale
    else
        self.r_scale = math.min(scale, max_scale)
    end
    return self.r_scale
end

function Viewport:fixSize(w, h)
    local p_width, p_height = love.window.toPixels(self.width, self.height)

    local cur_scale = math.max(roundDownToNearest(w / p_width, self.multiple),
                               roundDownToNearest(h / p_height, self.multiple))
    self.scale = math.max(1, cur_scale)
    self:setupScreen()
end

function Viewport:getWidth()
    return self.width
end

function Viewport:setWidth(width)
    local screen_w, screen_h = love.window.getDesktopDimensions()
    local p_width = love.window.toPixels(width)
    self.width = love.window.fromPixels(math.floor(math.min(p_width, screen_w)))
    return self.width
end

function Viewport:getHeight()
    return self.height
end

function Viewport:setHeight(height)
    local screen_w, screen_h = love.window.getDesktopDimensions()
    local p_height = love.window.toPixels(height)
    self.height = love.window.fromPixels(math.floor(math.min(p_height, screen_h)))
    return self.height
end

function Viewport:getScaleMultiple()
    return self.multiple
end

function Viewport:setScaleMultiple(multiple)
    self.multiple = multiple / love.window.getPixelScale()
    return self.multiple
end

function Viewport:getFilter()
    return self.filter
end

function Viewport:setFilter(min, mag, anisotropy)
    if(type(min) == 'table') then
        self.filter = min
    else
        self.filter = {min, mag, anisotropy}
    end
    return self.filter
end

function Viewport:getParams()
    return {
        width    = self.width,
        height   = self.height,
        scale    = self.scale,
        multiple = self.multiple,
        filter   = self.filter,
        fs       = self.fs,
        r_scale  = self.r_scale,
        r_width  = self.r_width,
        r_height = self.r_height,
        draw_ox  = self.draw_ox,
        draw_oy  = self.draw_oy
    }
end

function Viewport:setFullscreen(mode)
    if (mode == nil) then
        self.fs = not self.fs
    elseif (mode) then
        self.fs = true
    else
        self.fs = false
    end

    return self.fs
end

function Viewport:left(x)
    return love.window.toPixels(x)
end

function Viewport:top(y)
    return love.window.toPixels(y)
end

function Viewport:lefttop(x, y)
    return love.window.toPixels(x, y)
end

function Viewport:right(x, w)
    w = tonumber(w) or 0
    return love.window.toPixels(self.width - x - w)
end

function Viewport:righttop(x, y, w, h)
    w = tonumber(w) or 0
    return love.window.toPixels(self.width - x - w, y)
end

function Viewport:bottom(y, h)
    h = tonumber(h) or 0
    return love.window.toPixels(self.height - y - h)
end

function Viewport:leftbottom(x, y, w, h)
    h = tonumber(h) or 0
    return love.window.toPixels(x, self.height - y - h)
end

function Viewport:rightbottom(x, y, w, h)
    w = tonumber(w) or 0
    h = tonumber(h) or 0
    return love.window.toPixels(self.width - x - w, self.height - y - h)
end

function Viewport:maxScale()
    local screen_w, screen_h = love.window.toPixels(love.window.getDesktopDimensions())
    if (not self.fs) then
        -- subtract some height so that windowed mode doesn't scale
        -- beyond titlebar + application bar height in windows
        screen_w = screen_w - 80
        screen_h = screen_h - 80
    end

    local p_width, p_height = love.window.toPixels(self.width, self.height)
    local max_scale = math.min(roundDownToNearest(screen_w / p_width, self.multiple),
                               roundDownToNearest(screen_h / p_height, self.multiple))

    return math.max(1, max_scale)
end

function Viewport:pushScale()
    love.graphics.push()
    love.graphics.translate(self.draw_ox, self.draw_oy)
    love.graphics.scale(self.r_scale, self.r_scale)
    love.graphics.setScissor(self.draw_ox, self.draw_oy, self.r_width, self.r_height)
end

function Viewport:popScale()
    love.graphics.scale(1)
    love.graphics.pop()
    love.graphics.setScissor()
end

--

return Viewport
