local Class = require('vendor/nomoon/class')
local SoundObject = Class('SoundObject')

local SoundObjects = {}
local SoundResources = {}

local concat = table.concat
local insert = table.insert
local remove = table.remove
local match = string.match
local gmatch = string.gmatch

function SoundObject.getResource(source, srcType)
    if(srcType ~= 'static') then srcType = 'stream' end
    local key = source..'-'..srcType
    if SoundResources[key] then return SoundResources[key] end

    local resource
    if(srcType == 'stream') then
        resource = love.sound.newDecoder(source)
    elseif(srcType == 'static') then
        resource = love.sound.newSoundData(source)
    end

    SoundResources[key] = resource

    return resource
end

function SoundObject:initialize(source, tags, volume, srcType, callbacks)
    local resource = SoundObject.getResource(source, srcType)
    self.source = love.audio.newSource(resource, srcType)
    self.source:setVolume(volume or 1)

    self.tags = {}
    if tags then
        for token in gmatch(tags,"([^%,%;%s]+)") do
            insert(self.tags, token)
        end
    end

    self.callbacks = callbacks or {}

    insert(SoundObjects, self)
end

function SoundObject:hasTag(tags)
    if(type(tags) == "string") then tags = {tags} end
    local toFind = #tags
    for _, v in ipairs(self.tags) do
        if table.find(tags, v) then toFind = toFind - 1 end
        if (toFind == 0) then return true end
    end
end

function SoundObject:setVolume(volume)
    self.source:setVolume(volume)
end


function SoundObject:pause()
    self.source:pause()
end

function SoundObject:play()
    self.source:play()
end

function SoundObject:resume()
    self.source:resume()
end

function SoundObject:stop()
    self.callbacks = {}
    self.source:stop()
end

function SoundObject:finish()
    self.callbacks = {}
    self.source:setLooping(false)
end

function SoundObject:fadeOut(time)
    time = time or 5
    self.source:setLooping(false)
    self.callbacks["onStop"] = nil

    self.callbacks["_onTick"] = self.callbacks["onTick"] or (function() return end)
    self.callbacks["onTick"] = function(self, dt)
        self.callbacks["_onTick"](self, dt)
        local volume = self.source:getVolume()
        if (volume <= 0) then
            self.callbacks = {}
            self.source:stop()
        else
            self.source:setVolume(volume - (dt / time))
        end
    end
end

--

return {SoundObject, SoundObjects, SoundResources}
