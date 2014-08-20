local InputMan = {}
InputMan.__index = InputMan

local stringspect = require('vendor/inspect')
local json = require('vendor/dkjson')

local path = debug.getinfo(1).short_src:match("(.-)[^\\/]-%.?[^%.\\/]*$")
local InputMapper = require(path..'/inputmapper')

function InputMan.new(mapping)
    local self = {}
    setmetatable(self, InputMan)

    self.thread = love.thread.newThread(path..'/thread.lua')
    self.eChannel = love.thread.getChannel('input_events')
    self.cChannel = love.thread.getChannel('input_commands')
    self.pChannel = love.thread.getChannel('input_pollstate')
    self.rChannel = love.thread.getChannel('input_pollresponse')
    self.dChannel = love.thread.getChannel('input_debug')
    self.thread:start()

    self:setStateMap(mapping)

    return self
end

function InputMan:sendCommand(msg)
    if (msg == nil) then return end
    self.cChannel:push(msg)
end

function InputMan:setStateMap(mapping)
    self.mapping = mapping or {}
    self:sendCommand({"setStateMap", json.encode(self.mapping)})
end

function InputMan:updateJoysticks()
    self:sendCommand({'updateJoysticks'})
end

function InputMan:reInitialize()
    if self.thread and self.thread:isRunning() then
        self.cChannel:supply({'kill'})
    end
    self.thread = love.thread.newThread(path..'/thread.lua')
    self.thread:start()

    self:setStateMap(self.mapping)
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
        if(type(msg) == 'string') then print(msg) else
            print("INPUT-D", stringspect(msg))
        end
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

--

return InputMan
