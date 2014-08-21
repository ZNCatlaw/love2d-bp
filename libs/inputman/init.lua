local InputMan = {}
local metatable = {__index = InputMan}

local path = debug.getinfo(1).short_src:match("(.-)[^\\/]-%.?[^%.\\/]*$")

-- Add callbacks to love.handlers
love.handlers['inputpressed'] = function(a, b, c, d)
  if love.inputpressed then love.inputpressed(a, b, c, d) end
end

love.handlers['inputreleased'] = function(a, b, c, d)
  if love.inputreleased then love.inputreleased(a, b, c, d) end
end

-- InputMan object

InputMan = setmetatable(InputMan, {__call = function(_, mapping)
    local self = setmetatable({}, metatable)

    self.thread = love.thread.newThread(path..'/thread.lua')
    self.eChannel = love.thread.getChannel('input_events')
    self.cChannel = love.thread.getChannel('input_commands')
    self.pChannel = love.thread.getChannel('input_pollstate')
    self.rChannel = love.thread.getChannel('input_pollresponse')
    self.dChannel = love.thread.getChannel('input_debug')
    self.thread:start()

    if mapping then self:setStateMap(mapping) end

    return self
end})

function InputMan:sendCommand(msg)
    if (msg == nil) then return end
    if self.thread:isRunning() then self.cChannel:push(msg) end
end

function InputMan:setStateMap(mapping)
    self.mapping = mapping or {}
    local jsonstr = JSON.encode(self.mapping)
    self:sendCommand({"setStateMap", jsonstr})
end

function InputMan:updateJoysticks()
    self:sendCommand({'updateJoysticks'})
end

function InputMan:killThread()
    if self.thread:isRunning() then
        self.cChannel:supply({'kill'})
        self.cChannel:demand()
    end
    return not self.thread:isRunning()
end

function InputMan:reInitialize()
    if not self.thread:isRunning() then
      self.thread:start()
      self:setStateMap(self.mapping)
    end
    return self.thread:isRunning()
end

function InputMan:processEventQueue(cb)
    while self.eChannel:getCount() > 0 do
        local msg = self.eChannel:pop()
        local event = table.remove(msg, 1)
        cb(event, msg)
    end
end

function InputMan:printDebugQueue()
    while self.dChannel:getCount() > 0 do
        local msg = self.dChannel:pop()
        love.debug.print("[InputMan-D]", msg)
    end
end

function InputMan:getStates()
    if not self.thread:isRunning() then
        self:reInitialize()
    end
    self.pChannel:supply('all')
    return self.rChannel:demand()
end

function InputMan:isState(state)
    if not self.thread:isRunning() then
        self:reInitialize()
    end
    self.pChannel:supply(state)
    return self.rChannel:demand()
end

function InputMan:threadStatus()
    return self:sendCommand({'status'})
end

--

return InputMan
