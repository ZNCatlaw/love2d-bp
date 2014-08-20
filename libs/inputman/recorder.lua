local VHS = {}
VHS.__index = VHS

if not stringspect then stringspect = require('vendor/inspect/inspect') end
if not json then json = require('vendor/dkjson') end

local path = string.match(debug.getinfo(1).short_src,"(.-)[^\\/]-%.?[^%.\\/]*$")

function VHS.new(inputMan, world)
    local self = {}
    setmetatable(self, VHS)

    local data = love.filesystem.read("track_list.lua")
    if data then
        self.track_list = json.decode(data, 1, null, nil, nil)
    else
        self.track_list = {}
    end

    self.inputMan = inputMan
    self.recording = PaddedQueue({})

    self._playback = false
    self._record   = false

    return self
end

function VHS:sendCommand(msg)
    self.inputMan:sendCommand(msg)
end

function VHS:setStateMap(mapping)
    self.inputMan:setStateMap(mapping)
end

function VHS:updateJoysticks()
    self.inputMan:updateJoysticks()
end

function VHS:reInitialize()
    self.inputMan:reInitialize()
end

function VHS:processEventQueue(cb)
    if self._playback and self.recording.isEmpty() then self._playback = false end

    local update

    if self._playback then
        -- Process Input events in order
        update = self.recording.dequeue()

        if #update > 0 then
            local expect = table.remove(update, #update)

            while update and #update > 0 do
                local msg = table.remove(update, 1)
                local event = table.remove(msg, 1)
                cb(event, msg)
            end

            local actual = world:serialize()

          if global.DEBUG then
            for i = 1, #expect do
                local e = expect[i]
                local a = actual[i]

                for j = 1, #e do
                    if (math.abs(e[j] - a[j]) > 1) then
                        inspect({ "diff", e, a })
                        assert(false)
                    end
                end
            end
          end
        end
    else
        -- play the game normally, but remember the events
        self.inputMan:processEventQueue(function (event, states)
            if update == nil then update = {} end

            table.insert(update, { event, unpack(states) })

            cb(event, states)
        end)

        if update then
            table.insert(update, world:serialize())
        end

        if self._record then self.recording.enqueue(update) end
    end
end

function VHS:printDebugQueue()
    self.inputMan:printDebugQueue()
end

function VHS:getStates()
    return self.inputMan:getStates()
end

function VHS:isState(state)
    return self.inputMan:isState(state)
end

function VHS:loadTrack(track)
    return self.recording.init(self.track_list[track])
end

function VHS:playback(track)
    self.recording = self:loadTrack(track)

    self._record   = false
    self._playback = true
end

function VHS:save(track)
    self._record = false
    self.track_list[track] = self.recording.serialize()

    local hfile = io.open("track_list.lua", "w")
    local data = json.encode(self.track_list, {indent = true})

    if hfile == nil then bob.go() end

    hfile:write(data)

    io.close(hfile)
end

function VHS:startRecording()
    self._record = true
    self._playback = false
end

function VHS:isRecording()
    return self._record
end

function VHS:isPlayback()
    return self._playback
end

return VHS
