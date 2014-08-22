--[[
    Pure-lua Math Round v0.1.3

    Copyright 2014 Tim Bellefleur

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    USAGE: round(value, [precision:int = 0], [mode:str = 'HALFEVEN'])

    Order of 2nd and 3rd argument don't matter.

    Allowable modes:
        'HALFEVEN'    - Round half to even (default)
        'HALFUP'      - Round half up
        'HALFDOWN'    - Round half down
        'HALFAWAY'    - Round half away from zero
        'HALFTOWARDS' - Round half towards zero
        'HALFODD'     - Round half to odd
        'UP'          - Round up
        'DOWN'        - Round down
        'STOCHASTIC'  - Stochastic (random) rounding of halves
]]

-- Rounding function locals to import
local max    = math.max
local abs    = math.abs
local floor  = math.floor
local ceil   = math.ceil
local modf   = math.modf
local random = math.random

-- Make sure random will work
math.randomseed(os.time()); for i=1,10 do random() end

local function odd(i)
    return (i % 2 == 0)
end

local function halfup(f)
    return floor(f + 0.5)
end

local function halfdown(f)
    return ceil(f - 0.5)
end

local function away(f)
    return (f > 0) and halfup(f) or halfdown(f)
end

local function toward(f)
    return (f > 0) and halfdown(f) or halfup(f)
end

local function pickarg(ltype, arg1, arg2, default)
    if(type(arg1) == ltype) then
        return arg1
    elseif(type(arg2) == ltype) then
        return arg2
    else
        return default
    end
end

local function round(value, arg2, arg3)
    if(type(value) ~= 'number') then return end

    local precision = pickarg('number', arg2, arg3, 0)
    local mode = pickarg('string', arg2, arg3, 'HALFEVEN')
    local mult = 10^floor(max(0, precision))
    local i, f = modf(value * mult)

    if(mode == 'HALFEVEN') then
        f = odd(i) and toward(f) or away(f)
    elseif(mode == 'HALFUP') then
        f = halfup(f)
    elseif(mode == 'HALFDOWN') then
        f = halfdown(f)
    elseif(mode == 'HALFAWAY') then
        f = away(f)
    elseif(mode == 'HALFTOWARD') then
        f = toward(f)
    elseif(mode == 'HALFODD') then
        f = odd(i) and away(f) or toward(f)
    elseif(mode == 'STOCHASTIC') then
        f = (random(0,1) == 0) and halfup(f) or halfdown(f)
    elseif(mode == 'UP') then
        f = ceil(f)
    elseif(mode == 'DOWN') then
        f = floor(f)
    else
        return
    end

    return (i + f) / mult
end

---------------
-- Unit Tests
---------------
--[[
assert(round(0.5) == 0)
assert(round(1.5) == 2)
assert(round(-0.5) == 0)
assert(round(-1.5) == -2)

assert(round(23.49) == 23)
assert(round(23.50) == 24)
assert(round(24.50) == 24)
assert(round(24.51) == 25)

assert(round(-23.49) == -23)
assert(round(-23.50) == -24)
assert(round(-24.50) == -24)
assert(round(-24.51) == -25)

assert(round(23.49, 'HALFUP') == 23)
assert(round(23.50, 'HALFUP') == 24)
assert(round(24.50, 'HALFUP') == 25)
assert(round(24.51, 'HALFUP') == 25)
assert(round(24.51, 'HALFUP', 1) == 24.5)
assert(round(24.51, 'HALF', 1) == nil)

assert(round(-23.49, 0, 'HALFUP') == -23)
assert(round(-23.50, 0, 'HALFUP') == -23)
assert(round(-24.50, 0, 'HALFUP') == -24)
assert(round(-24.51, 0, 'HALFUP') == -25)

assert(round(23.49, 0, 'HALFDOWN') == 23)
assert(round(23.50, 0, 'HALFDOWN') == 23)
assert(round(24.50, 0, 'HALFDOWN') == 24)
assert(round(24.51, 0, 'HALFDOWN') == 25)

assert(round(-23.49, 0, 'HALFDOWN') == -23)
assert(round(-23.50, 0, 'HALFDOWN') == -24)
assert(round(-24.50, 0, 'HALFDOWN') == -25)
assert(round(-24.51, 0, 'HALFDOWN') == -25)

assert(round(23.49, 0, 'HALFAWAY') == 23)
assert(round(23.50, 0, 'HALFAWAY') == 24)
assert(round(24.50, 0, 'HALFAWAY') == 25)
assert(round(24.51, 0, 'HALFAWAY') == 25)

assert(round(-23.49, 0, 'HALFAWAY') == -23)
assert(round(-23.50, 0, 'HALFAWAY') == -24)
assert(round(-24.50, 0, 'HALFAWAY') == -25)
assert(round(-24.51, 0, 'HALFAWAY') == -25)

assert(round(23.49, 0, 'HALFTOWARD') == 23)
assert(round(23.50, 0, 'HALFTOWARD') == 23)
assert(round(24.50, 0, 'HALFTOWARD') == 24)
assert(round(24.51, 0, 'HALFTOWARD') == 25)

assert(round(-23.49, 0, 'HALFTOWARD') == -23)
assert(round(-23.50, 0, 'HALFTOWARD') == -23)
assert(round(-24.50, 0, 'HALFTOWARD') == -24)
assert(round(-24.51, 0, 'HALFTOWARD') == -25)

assert(round(0.5, 0, 'HALFODD') == 1)
assert(round(-0.5, 0, 'HALFODD') == -1)
assert(round(1.5, 0, 'HALFODD') == 1)
assert(round(-1.5, 0, 'HALFODD') == -1)

assert(round(22.49, 0, 'HALFODD') == 22)
assert(round(22.50, 0, 'HALFODD') == 23)
assert(round(23.50, 0, 'HALFODD') == 23)
assert(round(23.51, 0, 'HALFODD') == 24)

assert(round(-22.49, 0, 'HALFODD') == -22)
assert(round(-22.50, 0, 'HALFODD') == -23)
assert(round(-23.50, 0, 'HALFODD') == -23)
assert(round(-23.51, 0, 'HALFODD') == -24)

local accumulator, rounds = 0, 100000
for i=1,rounds do
    accumulator = accumulator + round(23.5, 0, 'STOCHASTIC')
end
assert(abs(accumulator/rounds - 23.5) < 0.01)

assert(round(22.49, 0, 'UP') == 23)
assert(round(22.50, 0, 'UP') == 23)
assert(round(23.50, 0, 'UP') == 24)
assert(round(23.51, 0, 'UP') == 24)

assert(round(-22.49, 0, 'UP') == -22)
assert(round(-22.50, 0, 'UP') == -22)
assert(round(-23.50, 0, 'UP') == -23)
assert(round(-23.51, 0, 'UP') == -23)

assert(round(22.49, 0, 'DOWN') == 22)
assert(round(22.50, 0, 'DOWN') == 22)
assert(round(23.50, 0, 'DOWN') == 23)
assert(round(23.51, 0, 'DOWN') == 23)

assert(round(-22.49, 0, 'DOWN') == -23)
assert(round(-22.50, 0, 'DOWN') == -23)
assert(round(-23.50, 0, 'DOWN') == -24)
assert(round(-23.51, 0, 'DOWN') == -24)
-- End Test Block ]]--

--

return round
