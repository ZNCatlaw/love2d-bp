-- Threads have a new environment, so globals/modules need to be loaded
require('love.timer')
require('love.joystick')
require('love.keyboard')
local JSON = require('vendor/dkjson')
local Set = require('vendor/set')

local path = string.match(debug.getinfo(1).short_src,"(.-)[^\\/]-%.?[^%.\\/]*$")
local InputMapper = require(path..'inputmapper').new()

local insert = table.insert
local remove = table.remove

local active_states = Set()
local pressCount = 0
local releaseCount = 0

-- All the important numbers/counters

local _stop = false
local _epsilon = 0.0001
local _throttle = 1250 -- Faster than 1ms precision
local _time = love.timer.getTime()
local _threadStart = _time
local _dt = 0
local _loopStart = _time
local _threadTime = 0
local _loopCount = 0
local _loopRate = _epsilon
local _debugAcc = 0

local cChannel = love.thread.getChannel("input_commands")
local eChannel = love.thread.getChannel("input_events")

local pChannel = love.thread.getChannel("input_pollstate")
local rChannel = love.thread.getChannel("input_pollresponse")

local dChannel = love.thread.getChannel("input_debug")
local callbacks = {}

-- Callbacks

callbacks['status'] = function()
    return dChannel:push({"STATUS",
        loopCount = _loopCount,
        threadTime =_threadTime,
        loopRate = _loopRate,
        pressCount = pressCount,
        releaseCount = releaseCoun
    })
end

callbacks['setStateMap'] = function(mapstring)
    local map = JSON.decode(mapstring)
    InputMapper:setStateMap(map)
end

callbacks['updateJoysticks'] = function()
    InputMapper:updateJoysticks()
end

local updateStates = function()
    local new_states = Set(InputMapper:getStates())
    local pressed = new_states - active_states
    local released = active_states - new_states
    active_states = new_states

    local numPressed = pressed:size()
    if(numPressed > 0) then
        pressCount = pressCount + numPressed
        eChannel:push({'pressed', unpack(pressed:items())})
    end

    local numReleased = released:size()
    if(numReleased > 0) then
        releaseCount = releaseCount + numReleased
        eChannel:push({'released', unpack(released:items())})
    end
end

-- Main Thread Loop

while not _stop do
    _time = love.timer.getTime()
    _dt = _time - _loopStart
    _threadTime = _time - _threadStart
    _loopStart = _time
    _loopCount = _loopCount + 1
    _loopRate = _loopCount / _threadTime

    updateStates()

    local pollstate = pChannel:pop()
    if (pollstate == 'all') then
        rChannel:push(InputMapper:getStates())
    elseif pollstate then
        rChannel:push(InputMapper:isState(pollstate))
    end

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

    -- Debug / EndLoop
    _debugAcc = _debugAcc + _dt
    if(_debugAcc > 10) then

        _debugAcc = 0
    end

    --Throttle
    if (_loopRate > _throttle) then love.timer.sleep(0.001) end
end
