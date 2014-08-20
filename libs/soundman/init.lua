local SoundMan = {}
SoundMan.__index = SoundMan

local stringspect = require('vendor/inspect')

local path = string.match(debug.getinfo(1).short_src,"(.-)[^\\/]-%.?[^%.\\/]*$")

function SoundMan.new()
    local self = {}
    setmetatable(self, SoundMan)

    self.shortcuts = {}
    self.thread = love.thread.newThread(path..'thread.lua')
    self.cChannel = love.thread.getChannel('sound_commands')
    self.dChannel = love.thread.getChannel('sound_debug')
    self.thread:start()

    return self
end

function SoundMan:reInitialize()
    if self.thread and self.thread:isRunning() then
        self.tChannel:supply({'kill'})
    end
    self.thread = love.thread.newThread(path..'thread.lua')
    self.thread:start()
end

function SoundMan:sendCommand(msg)
    if (msg == nil) then return end
    self.cChannel:push(msg)
end

function SoundMan:printDebugQueue()
    while self.dChannel:getCount() > 0 do
        local msg = self.dChannel:pop()
        if(type(msg) == 'string') then print(msg) else
            print("SOUND-D", stringspect(msg))
        end
    end
end

--
-- playSound(source, tags, [volume, srcType])
--
function SoundMan:playSound(source, tags, ...)
    self:sendCommand({'playSound', source, tags, unpack({...})})
end

--
-- playSoundLooping(source, tags, [volume, srcType])
--
function SoundMan:playSoundLoop(source, tags, ...)
    self:sendCommand({'playSoundLoop', source, tags, unpack({...})})
end

--
-- playSoundRegionLoop(source, tags, [volume, srcType,] regionStart, regionEnd)
--   Sound plays until it reaches "regionEnd" then seeks to "regionStart"
--
function SoundMan:playSoundRegionLoop(source, tags, ...)
    self:sendCommand({'playSoundRegionLoop', source, tags, unpack({...})})
end

--
-- playSoundRegionLoop(source, tags, [volume, srcType,] regionStart)
--   Sound plays until end, then seeks to "regionStart
--
function SoundMan:playSoundPartialLoop(source, tags, ...)
    self:sendCommand({'playSoundPartialLoop', source, tags, unpack({...})})
end

--
--
--
function SoundMan:stop(...)
    local tags = {...}
    if #tags > 0 then tags = table.concat(tags, ';') else tags = nil end
    self:sendCommand({'stop', tags})
end

--
--
--
function SoundMan:pause(...)
    local tags = {...}
    if #tags > 0 then tags = table.concat(tags, ';') else tags = nil end
    self:sendCommand({'pause', tags})
end

--
--
--
function SoundMan:resume(...)
    local tags = {...}
    if #tags > 0 then tags = table.concat(tags, ';') else tags = nil end
    self:sendCommand({'resume', tags})
end

--
--
--
function SoundMan:add(name, command, source, tags, ...)
    tags = table.concat({name, ';', tags})
    self.shortcuts[name] = {command, source, tags, unpack({...})}
    self:sendCommand({'touchResource', source, tags, unpack({...})})
    return self.shortcuts[name]
end

--
--
--
function SoundMan:run(name, tags)
    local msg = deepcopy(self.shortcuts[name])
    if msg and tags then msg[3] = table.concat({tags, ';', msg[3]}) end
    self:sendCommand(msg)
end

--

return SoundMan
