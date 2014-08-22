local Class = require('vendor/nomoon/class')
local InputMapper = Class.new('InputMapper')

-- Private variables/methods

local default_deadzone = 0.25
local joysticks = love.joystick.getJoysticks()

-- Public class

function InputMapper:initialize(map, deadzone)
    self.deadzone = math.max(deadzone or default_deadzone, 0.05)
    self:setStateMap(map)
end

function InputMapper:setStateMap(map)
    if(type(map) == 'table') then
        self.stateMap = map
    else
        self.stateMap = {}
    end
    self:genFlatMap()
end

function InputMapper:genFlatMap()
    local flatMap = {}
    for state, keys in pairs(self.stateMap) do
        for key, val in pairs(keys) do
            if (not flatMap[val]) then
                flatMap[val] = state
            else
                love.debug.print(true, string.format("WARN: `%s` already bound to `%s`, can't bind to `%s`",
                                    val, flatMap[val], state))
            end
        end
    end
    self.flatMap = flatMap
end

function InputMapper:updateJoysticks()
    joysticks = love.joystick.getJoysticks()
end

function InputMapper:getJoyNum(hid)
    for i, joystick in pairs(joysticks) do
        if (joystick == hid) then return i end
    end
end

function InputMapper:mappingToKey(mapping)
    local a, b, c, d = string.match(mapping, "(%a+)(%d?)_(%a+)([%+%-%.0-9]*)")
    b = tonumber(b)
    if (b and joysticks[b]) then
        b = joysticks[b]
    else
        b = nil
    end
    if (d ~= '+' and d ~= '-') then
        d = tonumber(d)
    end
    return a, b, c, d
end

function InputMapper:keyToMapping(...)
    local arguments = {...}
    local num_args = #arguments
    local device, key, direction = '', '', ''

    if (num_args == 1) then -- keypressed/released(key)
        device = "k"
        key = arguments[1]
    elseif (num_args > 1) then -- gamepadpressed/released(joystick, button)
        device = table.concat({'j', self:getJoyNum(arguments[1])})
        key = arguments[2]
    end

    if (num_args == 3) then -- gamepadaxis(joystick, axis, value)
        direction = tonumber(arguments[3])
        if (direction and direction > 0) then
            direction = table.concat({'+', direction})
        end
    end

    return table.concat{device, "_", key, direction or ''}
end

function InputMapper:mappingToState(mapping)
    local find = string.find
    local match = string.match
    for keys, state in pairs(self.flatMap) do
        if (mapping == keys) then
            return state
        elseif(find(mapping, "^j.*[%+%-]")) then
            local mm, ms, ma = match(mapping, "^j(.*)([%+%-])([%.0-9]*)$")
            local km, ks, ka = match(keys, "^j(.*)([%+%-])([%.0-9]*)$")
            if(mm == km and ms == ks and ma >= ka) then
                return state
            end
        end
    end
end

function InputMapper:keyToState(...)
    local mapping = self:keyToMapping(...)
    return self:mappingToState(mapping)
end

function InputMapper:axisToState(j, a, v)
    if(math.abs(v) < self.deadzone) then return end

    local mapping = self:keyToMapping(j, a, v)
    return self:mappingToState(mapping)
end

function InputMapper:getStates()
    local states = {}
    for state, v in pairs(self.stateMap) do
        if self:isState(state) then table.insert(states,state) end
    end
    return states
end

function InputMapper:isState(state)
    if not self.stateMap[state] then return false end

    local result = false
    local abs = math.abs

    for k, v in pairs(self.stateMap[state]) do
        local device, joy, key, dir = self:mappingToKey(v)

        if (device == 'k') then
            if love.keyboard.isDown(key) then result = true end
        elseif (device == 'j' and joy) then
            if (dir) then
                local axis = joy:getGamepadAxis(key)
                if (dir == '+') then
                    dir = self.deadzone
                elseif (dir == '-') then
                    dir = -self.deadzone
                end
                local deadzone = tonumber(dir) and dir or self.deadzone
                local range = 1 - abs(deadzone)
                axis = axis - deadzone
                if ((dir > 0 and axis >= 0) or (dir < 0 and axis <= 0)) then
                    result = axis / range
                end
            else
                if (joy:isGamepadDown(key)) then result = true end
            end
        end
    end

    return result
end

--

return InputMapper
