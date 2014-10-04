require('love.timer')
require('love.filesystem')
require('love.audio')
require('love.sound')

local insert = table.insert
local remove = table.remove
local gmatch = string.gmatch

local SoundObject, SoundObjects, SoundResources = unpack(require('libs/soundman/soundobject'))

-- All the important numbers/counters

local _stop = false
local _epsilon = 0.0001
local _throttle = 72000 -- 50% above 44100khz
local _time = love.timer.getTime()
local _threadStart = _time
local _dt = 0
local _loopStart = _time
local _threadTime = 0
local _loopCount = 0
local _loopRate = _epsilon
local _debugAcc = 0

local cChannel = love.thread.getChannel("sound_commands")
local dChannel = love.thread.getChannel("sound_debug")
local callbacks = {}

local parseTagString = function(tags)
    if not tags then return end
    tagTable = {}
    if tags then
        for token in gmatch(tags,"([^%,%;%s]+)") do
            insert(tagTable, token)
        end
    end
    return tagTable
end

-- Callbacks

callbacks['status'] = function()
    return dChannel:push({
        "STATUS",
        loopCount = _loopCount,
        threadTime =_threadTime,
        loopRate = _loopRate
    })
end

callbacks['touchResource'] = function(src, srcType)
    SoundObject.getResource(src, srcType)
end

callbacks['playSound'] = function(...)
    local snd = SoundObject.new(...)
    snd:play()
end

callbacks['playSoundLoop'] = function(...)
    local snd = SoundObject.new(...)
    snd.source:setLooping(true)
    snd:play()
end

callbacks['playSoundRegionLoop'] = function(...)
    local args = {...}
    local regionEnd = remove(args)
    local regionStart = remove(args)
    local source, tags, volume, srcType = unpack(args)

    local cb = function(self, dt)
        if(self.source:tell("seconds") >= regionEnd) then
            self.source:seek(regionStart, "seconds")
        end
    end

    local snd = SoundObject.new(source, tags, volume, srcType, {onTick = cb})
    snd:play()
end

callbacks['playSoundPartialLoop'] = function(...)
    local args = {...}
    local regionStart = remove(args)
    local source, tags, volume, srcType = unpack(args)

    local cb = function(self, dt)
        self.source:play()
        self.source:seek(regionStart, "seconds")
        return true
    end

    local snd = SoundObject.new(source, tags, volume, srcType, {onStop = cb})
    snd:play()
end

callbacks['stop'] = function(tags)
    tags = parseTagString(tags) or 'all'
    for i, sound in ipairs(SoundObjects) do
        if (tags == "all" or sound:hasTag(tags)) then sound:stop() end
    end
end

callbacks['pause'] = function(tags)
    tags = parseTagString(tags) or 'all'
    for i, sound in ipairs(SoundObjects) do
        if (tags == "all" or sound:hasTag(tags)) then sound:pause() end
    end
end

callbacks['resume'] = function(tags)
    tags = parseTagString(tags) or 'all'
    for i, sound in ipairs(SoundObjects) do
        if (tags == "all" or sound:hasTag(tags)) then sound:resume() end
    end
end

callbacks['kill'] = function()
    _stop = true
    callbacks['stop']()
end

-- Tick Function

local soundTick = function(dt)
    for k, v in ipairs(SoundObjects) do
        if v.source:isStopped() then
            if v.callbacks['onStop'] and v.callbacks['onStop'](v, dt) then
                -- no-op
            else
                remove(SoundObjects, k)
            end
        elseif v.callbacks['onTick'] then
            v.callbacks['onTick'](v, dt)
        end
    end
end

-- Main Thread Loop
dChannel:push('Sound thread started.')

while not _stop do
    _time = love.timer.getTime()
    _dt = _time - _loopStart
    _threadTime = _time - _threadStart
    _loopStart = _time
    _loopCount = _loopCount + 1
    _loopRate = _loopCount / _threadTime

    soundTick(_dt)

    local msg = cChannel:pop()
    if (type(msg) == 'table') then
        local callback = remove(msg, 1)
        dChannel:push({"COMMAND", callback, unpack(msg)})

        if(callbacks[callback]) then
            callbacks[callback](unpack(msg))
        else
            dChannel:push({"ERROR", callback, "doesn't exist"})
        end
    end

    --Throttle
    if (_loopRate > _throttle) then love.timer.sleep(0.001) end
end

dChannel:push('Sound thread terminated.')
cChannel:push('Sound thread terminated.')
