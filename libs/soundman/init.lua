local SoundMan = {}
local metatable = {__index = SoundMan}

local path = string.match(debug.getinfo(1).short_src,"(.-)[^\\/]-%.?[^%.\\/]*$")

function SoundMan.new()
    local self = setmetatable({}, metatable)

    self.shortcuts = {}
    self.thread = love.thread.newThread(path..'thread.lua')
    self.cChannel = love.thread.getChannel('sound_commands')
    self.dChannel = love.thread.getChannel('sound_debug')
    self.thread:start()

    return self
end

function SoundMan:killThread()
    if self.thread:isRunning() then
        self.cChannel:supply({'kill'})
        self.cChannel:demand()
    end
    return not self.thread:isRunning()
end

function SoundMan:reInitialize()
    if not self.thread:isRunning() then
      self.thread:start()
    end
    return self.thread:isRunning()
end

function SoundMan:sendCommand(msg)
    if (msg == nil) then return end
    if self.thread:isRunning() then self.cChannel:push(msg) end
end

function SoundMan:printDebugQueue()
    while self.dChannel:getCount() > 0 do
        local msg = self.dChannel:pop()
        love.debug.print("[SoundMan-D]", msg)
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
    local msg = table.deepcopy(self.shortcuts[name])
    if msg and tags then msg[3] = table.concat({tags, ';', msg[3]}) end
    self:sendCommand(msg)
end

--
--
--
function SoundMan:threadStatus()
    return self:sendCommand({'status'})
end

--

return SoundMan
