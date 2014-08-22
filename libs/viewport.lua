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
        scale  = 0,
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
    if(self:setFullscreen(self.fs)) then
        love.window.setMode(0, 0, {fullscreen = true, fullscreentype = "desktop"})
    else
        love.window.setMode(self.width * self.r_scale,
                            self.height * self.r_scale,
                            {resizable = true})
    end
    self.r_width  = self.width * self.r_scale
    self.r_height = self.height * self.r_scale
    self.draw_ox  = (love.graphics.getWidth() -  (self.r_width)) / 2
    self.draw_oy  = (love.graphics.getHeight() - (self.r_height)) / 2
end

function Viewport:setScale(scale)
    local scale = roundDownToNearest(scale, self.multiple)
    self.scale = scale

    local screen_w, screen_h = love.window.getDesktopDimensions()
    if (not self.fs) then
        -- subtract some height so that windowed mode doesn't scale
        -- beyond titlebar + application bar height in windows
        screen_w = screen_w - 64
        screen_h = screen_h - 96
    end

    local max_scale = math.min(roundDownToNearest(screen_w / self.width, self.multiple),
                               roundDownToNearest(screen_h / self.height, self.multiple))

    if (self.fs or (scale or 0) <= 0 or (scale or 0) > max_scale) then
        self.r_scale = max_scale
    else
        self.r_scale = scale
    end

    return self.r_scale
end

function Viewport:fixSize(w, h)
    local screen_w, screen_h = love.window.getDesktopDimensions()
    if (not self.fs) then
        -- subtract some height so that windowed mode doesn't scale
        -- beyond titlebar + application bar height in windows
        screen_w = screen_w - 64
        screen_h = screen_h - 96
    end

    local cur_scale = math.max(roundDownToNearest(w / self.width, self.multiple),
                               roundDownToNearest(h / self.height, self.multiple))

    local max_scale = math.min(roundDownToNearest(screen_w / self.width, self.multiple),
                               roundDownToNearest(screen_h / self.height, self.multiple))

    if (cur_scale < 1) then
        self.scale = 1
    elseif(cur_scale > max_scale) then
        self.scale = max_scale
    else
        self.scale = cur_scale
    end

    self:setupScreen()
end

function Viewport:getWidth()
    return self.width
end

function Viewport:setWidth(width)
    local screen_w, screen_h = love.window.getDesktopDimensions()
    self.width = math.floor(math.min(width, screen_w))
    return self.width
end

function Viewport:getHeight()
    return self.height
end

function Viewport:setHeight(height)
    local screen_w, screen_h = love.window.getDesktopDimensions()
    self.height = math.floor(math.min(height, screen_h))
    return self.height
end

function Viewport:getScaleMultiple()
    return self.multiple
end

function Viewport:setScaleMultiple(multiple)
    self.multiple = multiple
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
    return x
end

function Viewport:top(y)
    return y
end

function Viewport:lefttop(x, y)
    return x, y
end

function Viewport:right(x, w)
    w = tonumber(w) or 0
    return self.width - x - w
end

function Viewport:righttop(x, y, w, h)
    w = tonumber(w) or 0
    return self.width - x - w, y
end

function Viewport:bottom(y, h)
    h = tonumber(h) or 0
    return self.height - y - h
end

function Viewport:leftbottom(x, y, w, h)
    h = tonumber(h) or 0
    return x, self.height - y - h
end

function Viewport:rightbottom(x, y, w, h)
    w = tonumber(w) or 0
    h = tonumber(h) or 0
    return self.width - x - w, self.height - y - h
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
